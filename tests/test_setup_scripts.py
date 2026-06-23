"""Structural/convention checks for whirl's bash setup scripts.

These run with only ``pytest`` installed (no airflow). They lock in conventions
that the end-to-end CI runs depend on but never assert directly:

* every setup script is a ``#!/usr/bin/env bash`` script with the ``NN_name.sh``
  ordering-prefix naming convention;
* every ``whirl.setup.d`` script enables ``set -e`` near the top, so a failing
  setup step aborts container startup instead of silently continuing.

``compose.setup.d`` / ``compose.teardown.d`` scripts are *sourced* by the
``whirl`` script (which already runs under ``set -e``), so the errexit check is
scoped to ``whirl.setup.d`` only.
"""

import re

import pytest

from conftest import REPO_ROOT

SETUP_ROOTS = (REPO_ROOT / "envs", REPO_ROOT / "examples")
ALL_SETUP_DIRS = ("whirl.setup.d", "compose.setup.d", "compose.teardown.d")
NAME_RE = re.compile(r"^\d{2,}_[a-z0-9_]+\.sh$")
SET_E_RE = re.compile(r"^\s*set -e")


def _collect(*subdirs):
    scripts = []
    for root in SETUP_ROOTS:
        for sub in subdirs:
            scripts.extend(root.glob(f"*/{sub}/*.sh"))
    return sorted(scripts)


ALL_SCRIPTS = _collect(*ALL_SETUP_DIRS)
WHIRL_SETUP_SCRIPTS = _collect("whirl.setup.d")


def _id(path):
    return str(path.relative_to(REPO_ROOT))


def test_setup_scripts_are_discovered():
    # Guard against the glob silently matching nothing (which would make every
    # parametrized check below vacuously pass).
    assert len(ALL_SCRIPTS) >= 50


@pytest.mark.setup_scripts
@pytest.mark.parametrize("script", ALL_SCRIPTS, ids=_id)
def test_has_bash_shebang(script):
    first_line = script.read_text().splitlines()[0]
    assert first_line == "#!/usr/bin/env bash", (
        f"{_id(script)}: unexpected shebang {first_line!r}"
    )


@pytest.mark.setup_scripts
@pytest.mark.parametrize("script", ALL_SCRIPTS, ids=_id)
def test_filename_follows_ordering_convention(script):
    assert NAME_RE.match(script.name), (
        f"{script.name}: setup scripts must be named NN_lowercase_name.sh"
    )


@pytest.mark.setup_scripts
@pytest.mark.parametrize("script", WHIRL_SETUP_SCRIPTS, ids=_id)
def test_whirl_setup_scripts_enable_errexit(script):
    head = script.read_text().splitlines()[:5]
    assert any(SET_E_RE.match(line) for line in head), (
        f"{_id(script)}: whirl.setup.d scripts must enable `set -e` near the top"
    )