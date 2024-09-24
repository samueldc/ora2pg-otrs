#!/bin/sh
docker exec -i -e PGPASSFILE=.pgpass ${PWD##*/}-ora2pg-1 bash -c "pg_dump --host \$PG_HOST --port 5432 --username \$PG_USER --format custom --verbose --schema=public --file /var/tmp/docker/postgres/otrs.backup \$PG_DATABASE"
