#!/bin/sh
echo "Running fix sequences script"
PGPASSFILE=/.pgpass psql -h $PG_HOST -p 5432 -U $PG_USER -d $PG_DATABASE -f /opt/otrs/docker/postgres/fixsequences.sql