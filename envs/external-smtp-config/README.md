# External SMTP server

Airflow wired to a real SMTP server so failure emails actually get delivered
somewhere you can read them. MailDev catches everything and serves it over a web
UI — no mail leaves your machine.

## Services

| Service | Image | Ports | Purpose |
|---|---|---|---|
| `airflow` | `docker-whirl-airflow:py-${PYTHON_VERSION}-local` | 5000 | Airflow, single machine |
| `smtp-server` | `maildev/maildev:2.0.5` | 1080 (web UI), 2525 (SMTP) | Catches all outbound mail |

## Setup scripts

None — the wiring is entirely `AIRFLOW__SMTP__*` variables in `.whirl.env`.

## Configuration

SMTP on `smtp-server:2525`, STARTTLS and SSL both off (MailDev accepts plain).
Credentials are dummy values; MailDev does not check them.

## Trying it

Open <http://localhost:1080> for the mailbox, trigger a failing task, and the
notification appears there.

## Used by

`external-smtp-for-failure-emails`.
