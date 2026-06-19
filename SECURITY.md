# Security Policy

## Scope: Whirl is a local development tool

_whirl_ exists to spin up Apache Airflow and supporting services (S3, databases,
Spark, etc.) **on your local machine** for development and testing of DAGs. It
is **not** intended to be deployed as a production service or exposed to a
network.

### Intentional "insecure" defaults

To keep local usage frictionless, _whirl_ ships with hardcoded, well-known
credentials and secrets. **These are intentional and safe only because
everything runs locally and is not exposed to the internet.** They include,
among others:

- The Airflow admin user `admin` / `admin`.
- Default AWS-style access keys/secrets used to talk to the local S3 mock.
- Sample passphrases used when generating throwaway certificates in the Docker
  image build.

Do **not** reuse any of these credentials, keys or certificates outside of a
local _whirl_ environment, and do not expose a running _whirl_ stack (for
example the Airflow UI on `localhost:5000`) to untrusted networks.

## Reporting a vulnerability

If you believe you have found a security issue in the _whirl_ tooling itself
(for example in the `whirl` script, the Docker image build, or a setup script)
that goes beyond the intentional local-development defaults described above,
please report it privately rather than opening a public issue:

- Preferred: use GitHub's
  [private vulnerability reporting](https://github.com/godatadriven/whirl/security/advisories/new)
  to open a security advisory for this repository.
- Alternatively, contact the maintainers through the
  [godatadriven/whirl](https://github.com/godatadriven/whirl) repository.

Please include:

- A description of the issue and its potential impact;
- Steps to reproduce (the example/environment used, commands run);
- Any relevant logs or proof-of-concept.

We will acknowledge your report, investigate, and work with you on a fix and
coordinated disclosure where appropriate.