"""Shared pytest fixtures and constants for the whirl test suite.

This module is intentionally free of any ``airflow`` import so that lightweight
suites (e.g. the setup-script convention checks) can run with only ``pytest``
installed. DAG-parsing tests import airflow lazily inside their own fixtures.
"""

import os
import tempfile
from pathlib import Path

# Repo layout anchors (this file lives at <repo>/tests/conftest.py).
REPO_ROOT = Path(__file__).resolve().parent.parent
EXAMPLES_DIR = REPO_ROOT / "examples"
ENVS_DIR = REPO_ROOT / "envs"

# Hermetic Airflow settings for DAG-parsing tests. These must be in place before
# airflow is imported anywhere, so they are set at collection time here. They are
# harmless for tests that never import airflow.
os.environ.setdefault("AIRFLOW_HOME", tempfile.mkdtemp(prefix="whirl-airflow-test-"))
os.environ.setdefault("AIRFLOW__CORE__LOAD_EXAMPLES", "False")
os.environ.setdefault("AIRFLOW__CORE__DAGS_FOLDER", str(EXAMPLES_DIR))


def example_dirs_with_dag():
    """Return example directories that contain a top-level ``dag.py``."""
    return sorted(p for p in EXAMPLES_DIR.iterdir() if p.is_dir() and (p / "dag.py").is_file())