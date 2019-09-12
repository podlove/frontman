#!/usr/bin/env sh
# Reference: https://medium.com/@hex337/running-a-phoenix-1-3-project-with-docker-compose-d82ab55e43cf

# FIXME: find out why psql wait script is not working

# Wait for Postgres to become available
# until psql -h db -U "postgres" -c '\q' 2>/dev/null; do
#   >&2 echo "Postgres is unavailable - sleeping"
#   sleep 1
# done

./prod/rel/frontman/bin/frontman eval "Frontman.Release.create"
./prod/rel/frontman/bin/frontman eval "Frontman.Release.migrate"

# Start the Phoenix server
./prod/rel/frontman/bin/frontman start
