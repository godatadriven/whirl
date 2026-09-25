# SSH to localhost

A single Airflow container that can SSH to itself. This gives `SSHOperator` and
friends something to talk to without adding a second container — useful for
testing SSH-based tasks in isolation.

## Services

| Service | Image | Ports | Purpose |
|---|---|---|---|
| `airflow` | `docker-whirl-airflow:py-${PYTHON_VERSION}-local` | 5000 | Airflow, single machine, also runs sshd |

## Setup scripts

- `01_enable_local_ssh.sh` — registers the `local_ssh` connection, installs
  openssh client and server, generates a keypair, authorises it for the
  `airflow` user with the permissions sshd insists on, starts sshd, and installs
  `paramiko` plus the SSH provider.

## Used by

`localhost-ssh-example`.
