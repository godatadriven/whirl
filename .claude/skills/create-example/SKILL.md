---
name: create-example
description: Create a new Whirl example project in the examples/ directory. Use when the user wants to scaffold, add, or create a new Airflow DAG example for the Whirl local development tool. Triggers on requests like "create a new example", "add an example", "scaffold an example for X".
---

# Create Whirl Example

Scaffold a new Whirl example in `examples/`. Gather requirements interactively, then generate all files.

## Workflow

### 1. Gather Requirements

Ask the user for:

1. **Example name** - short kebab-case name (e.g. `api-to-s3`, `sftp-mysql-example`)
2. **Use case** - what the example demonstrates (1-2 sentences)
3. **Environment** - which environment from `envs/` to use. Present the available options:
   - `just-airflow` - Minimal Airflow only
   - `api-python-s3` - Airflow + S3 (LocalStack) + MockServer
   - `api-s3-dataset` - Airflow + S3 + PostgreSQL + MockServer
   - `postgres-s3-spark` - Airflow + PostgreSQL + S3 + Spark cluster
   - `dbt-example` - DBT + PostgreSQL + S3 + Spark
   - `sftp-mysql-example` - Airflow + MySQL + SFTP server
   - `local-ssh` - Airflow + SSH
   - `external-airflow-db` - Airflow with external PostgreSQL
   - `external-smtp-config` - Airflow + MailDev SMTP
   - `airflow-s3-logging` - Airflow with S3-based logging
   - `ha-scheduler` - High availability scheduler setup
   - `s3-spark-delta-sharing` - Spark + Delta Sharing + S3
   - **Custom environment** - if none of the above fit, use the `create-environment` skill to create a new environment first
4. **Optional extras** - whether the example needs:
   - Setup scripts (`whirl.setup.d/`) for installing providers, adding connections, loading mock data
   - Mock data directory (`mock-data/`)
   - Additional Python dependencies

### 2. Create Files

Create `examples/<name>/` with these files:

#### `.whirl.env` (required)

Minimum content:
```
WHIRL_ENVIRONMENT=<environment-name>
```

Add extra variables only when needed:
```
MOCK_DATA_FOLDER=${DAG_FOLDER}/mock-data
```

#### `README.md` (required)

Follow this structure:
```markdown
#### <Descriptive Title> Example

<1-2 paragraphs describing what this example demonstrates.>

The default environment (`<env>`) includes containers for:

 - <list services from the chosen environment>

## Setup scripts

The environment contains setup scripts in the `whirl.setup.d/` folder:

 - `<script>` which <description>

## Running

\`\`\`bash
$ cd ./examples/<name>
$ whirl
\`\`\`

Open your browser to [http://localhost:5000](http://localhost:5000) to access the Airflow UI. Manually enable the DAG and watch the pipeline run.
```

#### `dag.py` (required)

Create a DAG file demonstrating the use case. Follow these conventions:
- Use `os.environ.get()` for connection details and configuration
- Use Airflow templating (`{{ ds_nodash }}`, `{{ logical_date }}`) where appropriate
- Use providers matching the chosen environment's services
- Set `schedule=None` unless a specific schedule is needed
- Include a descriptive `dag_id` and `description`

#### `whirl.setup.d/` scripts (optional)

Numbered shell scripts executed inside the container at startup. Naming convention:
- `01_add_connection_<name>.sh` - add Airflow connections
- `01_add_mockdata_to_<service>.sh` - load mock data
- `02_install_<packages>.sh` - install extra Python packages

Scripts use `#!/usr/bin/env bash` and run after environment setup scripts.

Common patterns:
```bash
# Add a connection
airflow connections add <conn_id> --conn-type <type> --conn-host <host> --conn-port <port>

# Install providers
pip install apache-airflow-providers-<name>

# Create S3 bucket and upload mock data
aws s3 mb s3://<bucket> --endpoint-url http://localstack:4566
aws s3 cp /mock-data/<file> s3://<bucket>/ --endpoint-url http://localstack:4566
```

#### `mock-data/` (optional)

Test data files (JSON, CSV, etc.) referenced by setup scripts or DAGs. Set `MOCK_DATA_FOLDER=${DAG_FOLDER}/mock-data` in `.whirl.env` when using this.

#### `.airflowignore` (optional)

Add when the example directory contains Python files that are not DAGs (e.g. `include/` or `src/` directories):
```
include/
src/
```

### 3. Verify

After creating files, verify:
- The example directory exists in `examples/`
- `.whirl.env` references a valid environment from `envs/`
- The DAG file has no syntax errors: `python -c "import ast; ast.parse(open('examples/<name>/dag.py').read())"`
- Setup scripts (if any) are executable
