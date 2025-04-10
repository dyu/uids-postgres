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

UNAME=`uname`
if [ "$UNAME" = 'Darwin' ]; then
    export MACOSX_DEPLOYMENT_TARGET='13.3'
    SDK_DIR='/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk'
    [ -e "$SDK_DIR" ] && export BINDGEN_EXTRA_CLANG_ARGS="-I $SDK_DIR/usr/include"
fi

LD_LIBRARY_PATH='/opt/target/openssl/lib' cargo pgrx package -c /opt/target/pgsql/bin/pg_config
