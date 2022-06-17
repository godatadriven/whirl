from airflow.models import DAG
from airflow.exceptions import AirflowClusterPolicyViolation

def dag_policy(dag: DAG):
    """Ensure that DAG has at least one tag"""
    if not dag.tags:
        raise AirflowClusterPolicyViolation(
            f"DAG {dag.dag_id} has no tags. At least one tag required. File path: {dag.fileloc}"
        )

