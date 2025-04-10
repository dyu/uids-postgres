#!/bin/sh

if [ "$#" -eq 0 ]; then
/opt/target/pgsql/bin/psql -U postgres
else
/opt/target/pgsql/bin/psql -U postgres -v ON_ERROR_STOP=1 $@
fi
