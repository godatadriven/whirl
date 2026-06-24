"""Smoke tests that verify the test harness itself is wired up correctly.

These run with only ``pytest`` installed and give the new CI ``unit-tests`` job a
green baseline before the DAG-validation (Plan A) and setup-script (Plan B) suites
land on top of this foundation.
"""

from conftest import EXAMPLES_DIR, REPO_ROOT, example_dirs_with_dag


def test_repo_layout_anchors_exist():
    assert REPO_ROOT.is_dir()
    assert (REPO_ROOT / "whirl").is_file()
    assert EXAMPLES_DIR.is_dir()


def test_examples_with_dag_are_discovered():
    examples = example_dirs_with_dag()
    # The repo ships well over a dozen examples with a dag.py.
    assert len(examples) >= 10