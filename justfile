# Whirl task runner. Run `just` to list recipes.
# Tests use uv (Python 3.13 + the `test` dependency group); whirl recipes wrap
# the ./whirl script for running examples locally.

# Show available recipes
default:
    @just --list

# ---------------------------------------------------------------------------
# Tests (uv + pytest)
# ---------------------------------------------------------------------------

# Install the test toolchain (creates .venv)
sync:
    uv sync --group test

# Run the full pytest suite
test *args: sync
    uv run pytest {{args}}

# Run only the DAG-parsing validation layer
test-dag *args: sync
    uv run pytest tests/test_dag_validation.py {{args}}

# Run only the setup-script convention checks
test-setup-scripts *args: sync
    uv run pytest tests/test_setup_scripts.py {{args}}

# Lint the Python code with ruff
lint *args:
    uv run ruff check {{args}}

# ---------------------------------------------------------------------------
# Whirl (run examples locally)
# ---------------------------------------------------------------------------

# Start an example interactively (UI at http://localhost:5000). E.g. `just whirl api-to-s3`
whirl example *args:
    ./whirl -x {{example}} {{args}} start

# Run an example headless in CI mode. E.g. `just ci api-to-s3`
ci example *args:
    ./whirl -x {{example}} {{args}} ci

# Stop running whirl containers
stop:
    ./whirl stop

# Tail whirl logs
logs:
    ./whirl -l