#!/bin/sh

CURRENT_DIR=$PWD
# locate
if [ -z "$BASH_SOURCE" ]; then
    SCRIPT_DIR=`dirname "$(readlink -f $0)"`
elif [ -e '/bin/zsh' ]; then
    F=`/bin/zsh -c "print -lr -- $BASH_SOURCE(:A)"`
    SCRIPT_DIR=`dirname $F`
elif [ -e '/usr/bin/realpath' ]; then
    F=`/usr/bin/realpath $BASH_SOURCE`
    SCRIPT_DIR=`dirname $F`
else
    F=$BASH_SOURCE
    while [ -h "$F" ]; do F="$(readlink $F)"; done
    SCRIPT_DIR=`dirname $F`
fi
# change pwd
cd $SCRIPT_DIR

set -o allexport
source .env
set +o allexport

mkdir -p $PG_DATA $PG_DIR
[ -e "$PG_DIR/$PGVERSION" ] || ln -s /opt/target/pgsql "$PG_DIR/$PGVERSION"

gen_pg_hba_conf() {
cat << EOF
local   all     postgres                  trust
host    all     pgz_user_clear            all            password
host    all     pgz_user_nopass           all            trust
host    all     pgz_user_scram_sha256     all            scram-sha-256
host    all     all                       all            scram-sha-256
EOF
}

gen_pg_hba_conf > 'target/pg_hba.conf'

UNAME=`uname`
if [ "$UNAME" = 'Linux' ]; then
EPG_BIN=`realpath $(which epg)`
EPG_DIR=`dirname $EPG_BIN`
TARGET_DIR=`dirname $EPG_DIR`
export LD_LIBRARY_PATH="$TARGET_DIR/openssl/lib"
fi

PGCONF='{ "hba_file": "target/pg_hba.conf", "wal_level": "logical", "timezone": "UTC", "log_timezone": "UTC", "log_statement": "none", "datestyle": "iso", "default_text_search_config": "pg_catalog.english", "shared_preload_libraries": "pg_stat_statements,uids" }' \
epg
