# SFTP and MySQL

An SFTP server to read files from and a MySQL database to load them into — the
shape of a classic file-drop ingestion pipeline.

## Services

| Service | Image | Ports | Purpose |
|---|---|---|---|
| `airflow` | `docker-whirl-airflow:py-${PYTHON_VERSION}-local` | 5000 | Airflow, single machine |
| `ftp-server` | `iowoi/sftp-server:latest` | — | SFTP source |
| `mysql` | `mysql:8` | — | Target database |

Credentials for the two services live in `sftp.env` and `mysql.env` beside the
compose file, rather than in `.whirl.env`, because both images read them
directly.

## Setup scripts

- `01_prepare_sftp.sh` — adds the `ftp_server` connection (as an SSH connection)
  and prepares the remote directory.
- `02_prepare_mysql.sh` — adds the `mysql_connection` connection and creates the
  target schema.

## Configuration

`MOCK_DATA_FOLDER=${DAG_FOLDER}/mock-data` — the example supplies the files that
get dropped on the SFTP server, so the data lives with the DAG, not the
environment.

## Used by

`sftp-mysql-example`.
