"""Parse-and-validate every example DAG.

For each ``examples/*/dag.py`` this builds an Airflow ``DagBag`` and asserts the
folder parses with no import errors and yields at least one DAG. ``DagBag`` also
enforces unique task ids and rejects cycles (both surface as import errors), so
structural validation comes for free.

Examples needing packages outside the curated ``test`` dependency group are
skipped with an explicit reason, so skips stay visible and a newly added example
with missing deps fails loudly rather than passing silently.
"""

import importlib.util
import re
from pathlib import Path

import pytest

from conftest import example_dirs_with_dag

# whirl's CI mode auto-detects the dag_id from dag.py with this pattern
# (see the `whirl` script). Keep the suite honest about that contract.
DAG_ID_RE = re.compile(r"""dag_id=['"](.+?)['"]""")

# Examples whose dag.py imports packages we deliberately do not install in the
# curated `test` group (heavy / niche). Skipped with a clear reason.
SKIP_PARSE = {
    "dbt-example": "requires the airflow_dbt_python package",
    "dbt-spark-example": "requires the airflow_dbt_python package",
    "spark-delta-sharing": "requires the delta_sharing package",
}

# Examples that import a local package installed from the example itself.
# name -> (importable module, path passed to `uv pip install` for validation).
CUSTOM_PKG_EXAMPLES = {
    "airflow-deferrable-operator-custom": ("custom", "examples/airflow-deferrable-operator-custom"),
    "airflow-timetable": ("custom_plugins", "examples/airflow-timetable/whirl.setup.d/plugins"),
}

EXAMPLES = example_dirs_with_dag()


@pytest.mark.dag_validation
@pytest.mark.parametrize("example_dir", EXAMPLES, ids=lambda p: p.name)
def test_example_dag_parses(example_dir: Path):
    name = example_dir.name
    if name in SKIP_PARSE:
        pytest.skip(f"{name}: {SKIP_PARSE[name]}")
    if name in CUSTOM_PKG_EXAMPLES:
        module, path = CUSTOM_PKG_EXAMPLES[name]
        if importlib.util.find_spec(module) is None:
            pytest.skip(f"{name}: install its package first — `uv pip install ./{path}`")

    # Imported lazily so the airflow-free suites don't require the `test` group.
    from airflow.models.dagbag import DagBag

    bag = DagBag(dag_folder=str(example_dir), include_examples=False, safe_mode=True)
    assert bag.import_errors == {}, f"import errors in {name}: {bag.import_errors}"
    assert len(bag.dags) >= 1, f"no DAGs found in {name}"


@pytest.mark.dag_validation
@pytest.mark.parametrize("example_dir", EXAMPLES, ids=lambda p: p.name)
def test_dag_id_is_whirl_detectable(example_dir: Path):
    """Every example's dag_id must be greppable the way `whirl ci` detects it."""
    text = (example_dir / "dag.py").read_text()
    assert DAG_ID_RE.search(text), (
        f"whirl could not auto-detect a dag_id in {example_dir.name}/dag.py"
    )