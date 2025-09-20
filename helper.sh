#!/bin/bash

error() {
    echo "$@"
    exit 1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$1" ]; then
    echo "helper.sh - bundle script and, if desired, compile to native executable"
    echo "Usage: helper.sh directoryname [option]"
    echo ""
    echo "Note: directoryname must either be the name of a folder in the working directory, or '.' which will use the working directory instead"
    echo ""
    echo "Options:"
    echo "  build  -  build to an executable instead of run"
    echo "  wine   -  build, but use wine to build a windows executable"
    exit 0
fi

BUILD=0
WINE=0

if [ -n "$2" ]; then
    if [ "$2" = "build" ]; then
        BUILD=1
    elif [ "$2" = "wine" ]; then
        BUILD=1
        WINE=1
    else
        error "unexpected option" "'$2'" "; expected 'build' or 'wine'"
    fi
fi

TARGET_PROGRAM=$1
TARGET_DIR=./"$TARGET_PROGRAM"
if [ "$TARGET_PROGRAM" = "." ]; then
    TARGET_PROGRAM="${PWD##*/}"
    TARGET_DIR=.
elif [ ! -d "$TARGET_DIR" ]; then
    error "no directory at" "'$TARGET_PROGRAM'"
fi

if [ ! -f "$TARGET_DIR"/main.luau ]; then
    error "no main.luau inside" "'$TARGET_PROGRAM'"
fi

LUTE_PATH1="$SCRIPT_DIR/../build/release/lute/cli/lute"
LUTE_PATH2="$SCRIPT_DIR/../bootstrap/lute"
if [ $WINE = 1 ]; then
    LUTE_PATH1=$LUTE_PATH1".exe"
    LUTE_PATH2=$LUTE_PATH2".exe"
fi
LUTE_PATH=

if [ -f "$LUTE_PATH1" ]; then
    LUTE_PATH=$LUTE_PATH1
elif [ -f "$LUTE_PATH2" ]; then
    LUTE_PATH=$LUTE_PATH2
else
    error "failed to find lute executable neither at" "'$LUTE_PATH1'" "nor at " "'$LUTE_PATH2'"
fi

COMPILED_SUFFIX=
if [ $WINE = 1 ]; then
    LUTE_PATH="wine "$LUTE_PATH
    COMPILED_SUFFIX=".exe"
fi

echo "bundling..."
darklua process -c "$SCRIPT_DIR"/darkluabundle.json "$TARGET_DIR"/main.luau ./build/"$TARGET_PROGRAM".luau || exit 1

if [ $BUILD = 1 ]; then
    if [ ! -d "./build" ]; then
        mkdir build || exit 1
    fi
    $LUTE_PATH compile ./build/"$TARGET_PROGRAM".luau ./build/"$TARGET_PROGRAM"$COMPILED_SUFFIX || exit 1
fi
