#!/bin/bash
docker compose down
docker system prune -f
docker volume rm rust-keylime_keylime-volume rust-keylime_swtpm-volume
docker compose up
