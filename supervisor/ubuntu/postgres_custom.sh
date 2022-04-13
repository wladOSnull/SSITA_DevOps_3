#!/bin/bash

# This script is run by Supervisor to start PostgreSQL in foreground mode

function shutdown()
{
    echo "Shutting down PostgreSQL"
    pkill postgres
}

if [ -d /var/run/postgresql ]; then
    chmod 2775 /var/run/postgresql
else
    install -d -m 2775 -o postgres -g postgres /var/run/postgresql
fi

# Allow any signal which would kill a process to stop PostgreSQL
trap shutdown HUP INT QUIT ABRT KILL ALRM TERM TSTP

exec sudo -u postgres /usr/lib/postgresql/12/bin/postgres -D /var/lib/postgresql/12/main --config-file=/etc/postgresql/12/main/postgresql.conf