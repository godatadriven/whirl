#!/usr/bin/env bash
#
# ci_impact.sh - Work out which whirl example/environment combinations need a CI
# run based on the files that changed on this branch / in the working tree.
#
# An example is normally verified against its DEFAULT environment (the one in its
# own .whirl.env). But the GitHub Actions workflow also runs a few examples against
# NON-DEFAULT environments via `whirl ci -e <env>` (separate "extra-env" jobs).
# Those (example, env) combinations are parsed straight from the workflow so this
# script stays in sync, and they are verified too when the example OR that env
# changes.
#
# The mapping rules:
#   examples/<name>/...        -> run <name> against every env CI runs it with
#                                 (its default env + any non-default extra-env runs)
#   envs/<env>/...             -> run every (example, <env>) combination CI runs,
#                                 whether <env> is that example's default or extra
#   whirl | docker/ |          -> CORE change: affects every example. We do NOT
#   docker-compose.yaml |         expand this to "run everything" automatically;
#   ./.whirl.env (repo root)      we flag it so a human decides the scope.
#   everything else            -> no CI impact (docs, .claude/, logos, READMEs)
#
# Usage:
#   ci_impact.sh [--base <ref>]
#     --base <ref>   git ref to diff committed branch work against (default: master)
#
# Output is a human-readable plan plus ready-to-run commands. It NEVER runs CI
# itself - selecting and running are deliberately separate steps.

set -euo pipefail

BASE="master"
while [ $# -gt 0 ]; do
  case "$1" in
    --base) BASE="$2"; shift 2 ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

WORKFLOW=".github/workflows/whirl-ci.yml"

# ---------------------------------------------------------------------------
# 1. Collect changed files: committed-on-branch + uncommitted + untracked.
# ---------------------------------------------------------------------------
changed="$(
  {
    # committed work that is on this branch but not on the base
    if git rev-parse --verify --quiet "$BASE" >/dev/null; then
      git diff --name-only "$(git merge-base HEAD "$BASE" 2>/dev/null || echo "$BASE")...HEAD" 2>/dev/null || true
    fi
    # staged + unstaged + untracked, relative to repo root
    git status --porcelain --untracked-files=all | sed 's/^...//' | sed 's/.* -> //'
  } | sed 's#^"##; s#"$##' | sort -u | grep -v '^$' || true
)"

if [ -z "$changed" ]; then
  echo "No changed files detected (base: $BASE). Nothing to verify."
  exit 0
fi

# ---------------------------------------------------------------------------
# 2. Build the (example, env) run combinations CI knows about.
#    EXAMPLE_ENV[example]   = the example's default environment ("" if unknown)
#    ENV_EXAMPLES[env]      = examples that run with that env (default OR extra)
#    EXAMPLE_ENVS[example]  = envs that example runs with (default + extras)
# ---------------------------------------------------------------------------
declare -A EXAMPLE_ENV
for dir in examples/*/; do
  name="$(basename "$dir")"
  env=""
  if [ -f "${dir}.whirl.env" ]; then
    env="$(grep -E '^WHIRL_ENVIRONMENT=' "${dir}.whirl.env" 2>/dev/null | head -1 | cut -d= -f2- | tr -d '[:space:]')"
  fi
  EXAMPLE_ENV["$name"]="$env"
done

declare -A ENV_EXAMPLES
declare -A EXAMPLE_ENVS
add_pair() {  # example env
  local ex="$1" env="$2"
  [ -z "$env" ] && return
  case " ${EXAMPLE_ENVS[$ex]:-} " in *" $env "*) ;; *) EXAMPLE_ENVS[$ex]="${EXAMPLE_ENVS[$ex]:-} $env" ;; esac
  case " ${ENV_EXAMPLES[$env]:-} " in *" $ex "*) ;; *) ENV_EXAMPLES[$env]="${ENV_EXAMPLES[$env]:-} $ex" ;; esac
}

# Default combinations: each example with the env from its own .whirl.env.
for ex in "${!EXAMPLE_ENV[@]}"; do
  add_pair "$ex" "${EXAMPLE_ENV[$ex]}"
done

# Extra (non-default) combinations: parse `whirl ci -e <env>` jobs from the
# workflow. The example comes from an inline `-x <example>` if present, otherwise
# from the job's `working-directory: ./examples/<example>`.
EXTRA_PAIRS="$(
  awk '
    /working-directory:[[:space:]]*\.\/examples\// {
      wd=$0; sub(/.*\/examples\//,"",wd); sub(/[\/[:space:]]*$/,"",wd)
    }
    /whirl/ && /[[:space:]]ci([[:space:]]|$)/ && /[[:space:]]-e[[:space:]]/ {
      ex=wd
      if (match($0,/-x[[:space:]]+[A-Za-z0-9._-]+/)) { ex=substr($0,RSTART,RLENGTH); sub(/-x[[:space:]]+/,"",ex) }
      env=""
      if (match($0,/-e[[:space:]]+[A-Za-z0-9._-]+/)) { env=substr($0,RSTART,RLENGTH); sub(/-e[[:space:]]+/,"",env) }
      if (ex!="" && env!="") print ex"|"env
    }
  ' "$WORKFLOW" 2>/dev/null | sort -u
)"
while IFS= read -r p; do
  [ -z "$p" ] && continue
  add_pair "${p%%|*}" "${p##*|}"
done <<< "$EXTRA_PAIRS"

# Examples excluded from the GitHub Actions DEFAULT matrix (parsed from the
# workflow so this stays in sync). These still run locally but the default-env CI
# matrix skips them - usually memory limits or a separate job - so we surface them
# as caveats on their default-env run.
EXCLUDED="$(grep -hoE 'example(_dir)?: (\./examples/)?[a-z0-9-]+' "$WORKFLOW" 2>/dev/null \
  | sed -E 's#.*[:/] *##' | sort -u || true)"
is_excluded() { echo "$EXCLUDED" | grep -qx "$1"; }

# ---------------------------------------------------------------------------
# 3. Classify changed files into a set of (example, env) runs with reasons.
#    Run set is keyed "example|env"; env "" means "default, env unknown".
# ---------------------------------------------------------------------------
declare -A RUN_REASON
CORE_FILES=""
IGNORED=""

add_run() {  # key reason
  local key="$1" reason="$2"
  if [ -n "${RUN_REASON[$key]:-}" ]; then
    case "${RUN_REASON[$key]}" in *"$reason"*) ;; *) RUN_REASON[$key]="${RUN_REASON[$key]}; $reason" ;; esac
  else
    RUN_REASON[$key]="$reason"
  fi
}

while IFS= read -r f; do
  [ -z "$f" ] && continue
  case "$f" in
    examples/*/*|examples/*)
      ex="$(echo "$f" | cut -d/ -f2)"
      [ -n "${EXAMPLE_ENV[$ex]+x}" ] || continue   # only real example dirs
      if [ -n "${EXAMPLE_ENVS[$ex]:-}" ]; then
        for env in ${EXAMPLE_ENVS[$ex]}; do
          add_run "$ex|$env" "own files changed"
        done
      else
        add_run "$ex|" "own files changed (env unknown)"
      fi
      ;;
    envs/*/*|envs/*)
      env="$(echo "$f" | cut -d/ -f2)"
      for ex in ${ENV_EXAMPLES[$env]:-}; do
        add_run "$ex|$env" "uses env '$env' (changed)"
      done
      ;;
    whirl|docker/*|docker-compose.yaml|.whirl.env)
      CORE_FILES="${CORE_FILES}  - $f"$'\n'
      ;;
    *)
      IGNORED="${IGNORED}  - $f"$'\n'
      ;;
  esac
done <<< "$changed"

# ---------------------------------------------------------------------------
# 4. Report.
# ---------------------------------------------------------------------------
file_count="$(echo "$changed" | grep -c '^' || true)"
echo "== Changed areas (base: $BASE, ${file_count} files) =="
echo "$changed" \
  | sed -E 's#^(examples/[^/]+)/.*#\1/#; s#^(envs/[^/]+)/.*#\1/#' \
  | sort | uniq -c \
  | sed -E 's/^ *([0-9]+) (.*)$/  \2  (\1 file(s))/'
echo

if [ -n "$CORE_FILES" ]; then
  echo "== CORE change detected =="
  echo "These files affect ALL examples:"
  printf '%s' "$CORE_FILES"
  echo "A human should decide scope: run a representative subset, or all examples."
  echo "Representative subset suggestion: api-to-s3 (S3+API), spark-s3-to-postgres (Spark),"
  echo "dbt-example (dbt), sftp-mysql-example (DB+SFTP), airflow-cluster-policy (just-airflow)."
  echo
fi

if [ ${#RUN_REASON[@]} -eq 0 ]; then
  if [ -z "$CORE_FILES" ]; then
    echo "== No example/env combinations need a CI run =="
    echo "Only non-functional files changed (docs, .claude/, etc.)."
  fi
else
  echo "== Example/env combinations to verify in CI =="
  for key in $(printf '%s\n' "${!RUN_REASON[@]}" | sort); do
    ex="${key%%|*}"; env="${key#*|}"
    default="${EXAMPLE_ENV[$ex]:-}"
    note=""
    if [ -z "$env" ]; then
      envlabel="default env"
    elif [ "$env" = "$default" ]; then
      envlabel="env: $env (default)"
      is_excluded "$ex" && note="  [NOTE: excluded from GitHub CI matrix - verify locally]"
    else
      envlabel="env: $env (NON-default)"
    fi
    printf '  %-26s %-30s %s%s\n' "$ex" "$envlabel" "(${RUN_REASON[$key]})" "$note"
  done
  echo
  echo "== Commands (run from repo root) =="
  for key in $(printf '%s\n' "${!RUN_REASON[@]}" | sort); do
    ex="${key%%|*}"; env="${key#*|}"
    default="${EXAMPLE_ENV[$ex]:-}"
    if [ -z "$env" ] || [ "$env" = "$default" ]; then
      echo "  ./whirl -x $ex ci"
    else
      echo "  ./whirl -x $ex ci -e $env"
    fi
  done
fi

if [ -n "$IGNORED" ]; then
  echo
  echo "== Ignored (no CI impact) =="
  printf '%s' "$IGNORED"
fi