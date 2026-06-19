---
name: create-environment
description: Create a new Whirl environment in the envs/ directory. Use when the user wants to add, scaffold, or create a new Docker Compose environment for the Whirl local Airflow development tool. Also invoked by the create-example skill when the user needs a custom environment. Triggers on requests like "create a new environment", "add an environment for Kafka", "I need an environment with Redis and S3".
---

# Create Whirl Environment

Scaffold a new Whirl environment in `envs/`. Gather requirements interactively, then generate all files.

## Workflow

### 1. Gather Requirements

Ask the user for:

1. **Environment name** - short kebab-case name describing the services (e.g. `postgres-s3-spark`, `sftp-mysql-example`)
2. **Services needed** - which external services to include. Common options:
   - **S3** - LocalStack (`localstack/localstack:3.0.2`, port 4566)
   - **PostgreSQL** - (`postgres:16`, port 5432)
   - **MySQL** - (`mysql:8`, port 3306)
   - **MockServer** - REST API mocking (`mockserver/mockserver:5.15.0`, port 1080)
   - **Spark** - Master + Worker cluster
   - **SFTP** - (`atmoz/sftp`, port 22)
   - **SMTP** - MailDev (`maildev/maildev:2.0.5`, ports 1080/1025)
   - **Redis**, **Kafka**, or other custom services
3. **Airflow mode** - how Airflow should run:
   - `singlemachine` (default) - scheduler + webserver in one container, simplest setup
   - Distributed - separate `api-server`, `scheduler`, `dag-processor`, `triggerer` containers (for testing HA or distributed setups)

### 2. Create Files

Create `envs/<name>/` with these files:

#### `docker-compose.yml` (required)

Follow these patterns:

**Airflow service (singlemachine mode):**
```yaml
services:
  airflow:
    image: docker-whirl-airflow:py-${PYTHON_VERSION}-local
    command: ["singlemachine"]
    ports:
      - '5000:5000'
    env_file:
      - .whirl.env
    environment:
      - WHIRL_SETUP_FOLDER
      - AIRFLOW__FAB__AUTH_BACKENDS
      - AIRFLOW__CORE__EXECUTION_API_SERVER_URL
      - AIRFLOW__API_AUTH__JWT_SECRET
    volumes:
      - ${DAG_FOLDER}:/opt/airflow/dags/$PROJECTNAME
      - ${ENVIRONMENT_FOLDER}/whirl.setup.d:${WHIRL_SETUP_FOLDER}/env.d/
      - ${DAG_FOLDER}/whirl.setup.d:${WHIRL_SETUP_FOLDER}/dag.d/
```

**Adding service dependencies:**
```yaml
    depends_on:
      - s3server
      - postgresdb
    links:
      - s3server:${DEMO_BUCKET}.s3server  # Only for S3 virtual-host style access
```

**Common service definitions:**

S3 (LocalStack):
```yaml
  s3server:
    image: localstack/localstack:3.0.2
    ports:
      - "4566:4566"
    environment:
      - SERVICES=s3
    env_file:
      - .whirl.env
```

PostgreSQL:
```yaml
  postgresdb:
    image: postgres:16
    ports:
      - 5432:5432
    environment:
      - POSTGRES_HOST=postgresdb
      - POSTGRES_PORT=5432
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_DB=${POSTGRES_DB}
```

MockServer:
```yaml
  mockserver:
    image: mockserver/mockserver:5.15.0
    ports:
      - 1080:1080
    environment:
      - LOG_LEVEL=ERROR
      - SERVER_PORT=1080
```

MySQL:
```yaml
  mysql:
    image: mysql:8
    ports:
      - 3306:3306
    env_file:
      - mysql.env
```

SMTP (MailDev):
```yaml
  smtp-server:
    image: maildev/maildev:2.0.5
    ports:
      - "1080:1080"
      - "1025:1025"
```

**Mock data volume (when needed):**
Add to the airflow service volumes:
```yaml
      - ${MOCK_DATA_FOLDER}:/mock-data
```

#### `.whirl.env` (required)

Standard variables always included:
```
AIRFLOW_VERSION=3.2.1
AIRFLOW__CORE__EXPOSE_CONFIG=True
AIRFLOW__API__EXPOSE_CONFIG=True
AIRFLOW__API__SECRET_KEY=webser_secret_key
AIRFLOW__DATABASE__LOAD_DEFAULT_CONNECTIONS=False
AIRFLOW__CORE__LOAD_EXAMPLES=False
```

Add service-specific variables based on chosen services:

For S3:
```
AWS_ACCESS_KEY_ID=bar
AWS_SECRET_ACCESS_KEY=foo
DEMO_BUCKET=demo-s3-output
AWS_SERVER=s3server
AWS_PORT=4566
```

For PostgreSQL:
```
POSTGRES_HOST=postgresdb
POSTGRES_PORT=5432
POSTGRES_PASSWORD=p@ssw0rd
POSTGRES_USER=postgres
POSTGRES_DB=postgresdb
```

For SMTP:
```
AIRFLOW__SMTP__SMTP_HOST=smtp-server
AIRFLOW__SMTP__SMTP_PORT=2525
AIRFLOW__SMTP__SMTP_MAIL_FROM=sender@example.com
```

For distributed Airflow (add fernet key and DB connection):
```
AIRFLOW__CORE__FERNET_KEY=YlCImzjge_TeZc7jPJ7Jz2pgOtb4yTssA1pVyqIADWg=
AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}
```

#### `whirl.setup.d/` scripts (optional but typical)

Create numbered shell scripts for environment initialization. Common scripts:

**S3 connection setup** (`01_add_connection_s3.sh`):
```bash
#!/usr/bin/env bash

echo "=========================="
echo "== Configure S3 =========="
echo "=========================="

pip install awscli

export AWS_ENDPOINT_URL="http://${AWS_SERVER}:${AWS_PORT}"

while [[ "$(curl -s -o /dev/null -w '%{http_code}' ${AWS_ENDPOINT_URL})" != "200" ]]; do
  echo "Waiting for S3 server..."
  sleep 2
done

aws s3 mb s3://${DEMO_BUCKET}

airflow connections add aws_default \
  --conn-type aws \
  --conn-extra "{\"endpoint_url\": \"http://${AWS_SERVER}:${AWS_PORT}\"}"
```

**PostgreSQL connection setup** (`02_add_connection_postgres.sh`):
```bash
#!/usr/bin/env bash

echo "=============================="
echo "== Configure PostgreSQL ======"
echo "=============================="

airflow connections add postgres_default \
  --conn-type postgres \
  --conn-host ${POSTGRES_HOST} \
  --conn-port ${POSTGRES_PORT} \
  --conn-login ${POSTGRES_USER} \
  --conn-password ${POSTGRES_PASSWORD} \
  --conn-schema ${POSTGRES_DB}
```

Scripts must use `#!/usr/bin/env bash` and include wait loops for service readiness when needed.

#### `compose.setup.d/` scripts (optional)

Host-side scripts executed before Docker Compose starts. Use for:
- Cleaning persistent data directories (e.g., `.pgdata/`)
- Building custom Docker images
- Pre-provisioning resources

#### Additional env files (optional)

For services needing separate env files (e.g., `mysql.env`, `sftp.env`).

### 3. Verify

After creating files:
- Confirm `docker-compose.yml` is valid YAML
- Ensure `.whirl.env` variable names match service names in `docker-compose.yml`
- Setup scripts are executable: `chmod +x envs/<name>/whirl.setup.d/*.sh`
