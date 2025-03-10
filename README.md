# HomeLab infra

A repo for collecting the deployed homelab services.

## Installation

1. Install Loki Docker Log Driver ([Docs](https://grafana.com/docs/loki/latest/send-data/docker-driver/)):
    ```
    docker plugin install grafana/loki-docker-driver:3.4.2-amd64 --alias loki --grant-all-permissions
    ```

2. Configure the log driver in ```/etc/docker/daemon.json

    ```json
    {
        "log-driver": "loki",
        "log-opts": {
            "mode":"non-blocking",
            "loki-url": "http://localhost:3100/loki/api/v1/push",
            "loki-batch-size": "400",
            "loki-retries": "2",
            "loki-max-backoff":"800ms",
            "loki-timeout":"1s"
            }
    }
    ```
4. Restart docker service.

5. Create an env file based on the latest env.template, fill out the necessary information, and launch the services using docker compose:

    ```bash
    cd /srv/repos/infra/services && docker compose -p services -f paperless/compose.yml -f actualbudget/compose.yml -f homepage/compose.yml --env-file ../docker.env up -d
    ```