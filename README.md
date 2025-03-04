# HomeLab infra

A repo for collecting the deployed homelab services.


## Installation

Create an env file based on the latest env.template, fill out the necessary information, and launch the services using docker compose:

```
cd /srv/repos/infra/services && docker compose -p services -f paperless/compose.yml -f actualbudget/compose.yml -f homepage/compose.yml --env-file ../docker.env up -d
```