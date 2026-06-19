#### Airflow Cluster Policy Example

In this example we demonstrate how to enforce an [Airflow cluster
policy](https://airflow.apache.org/docs/apache-airflow/stable/administration-and-deployment/cluster-policies.html).
Cluster policies let an operator apply organisation-wide rules to every DAG or
task that is loaded, for example to enforce tagging, naming or resource
conventions.

The policy in this example (`whirl.setup.d/policies/dag_policy.py`) implements a
`dag_policy` that requires every DAG to have at least one tag. When a DAG does
not comply it raises an `AirflowClusterPolicyViolation`, which surfaces as a DAG
import error.

The bundled DAG (`example_bash_operator`) deliberately has **no tags**, so
loading it violates the policy. This example therefore *expects* an import
error: the `.whirl.env` sets `WHIRL_CI_EXPECT_IMPORTERRORS=true` so that the
import error is treated as the successful outcome in CI mode.

The default environment (`just-airflow`) only contains the core Airflow
component.

The environment contains a setup script in the `whirl.setup.d/` folder:

 - `01_configure_cluster_policies.sh` which installs `policies/dag_policy.py`
   as `${AIRFLOW_HOME}/config/airflow_local_settings.py`, the file Airflow reads
   cluster policies from.

To run this example:

```bash
$ cd ./examples/airflow-cluster-policy
$ whirl
```

Open your browser to [http://localhost:5000](http://localhost:5000) to access
the Airflow UI. The DAG will show up as a broken DAG / import error, proving the
cluster policy is being enforced.