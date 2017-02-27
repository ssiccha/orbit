#!/bin/bash
# runarchsym.sh

if [ "$#" != "4" -a "$#" != "5" ]; then
    echo -en "Usage: runarchsym.sh <app-name> <arch-name>"
    echo -en " <in-pipe-filename> <out-pipe-filename> <debug>"
    echo -en "\nAny 5th argument will trigger debug mode.\n"
    exit 1
fi;

GAP_BIN='gap'
SCRIPTSDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASEDIR=${SCRIPTSDIR%'/scripts'} # remove script directory
GAPDIR=${BASEDIR}"/gap"
cd ${GAPDIR}

## DEBUG MODE ##
if [ "$#" == "5" ]; then
    echo "Start GAP:"
    echo "gap read.g"
    xsel --clear --clipboard
    echo -n "MappingsCacheLookup( \"${1}\", \"${2}\", \"${3}\", \"${4}\" );" \
        | xsel --append --clipboard
    echo "Run (copied into clipboard):"
    echo ""
    echo "MappingsCacheLookup( \"${1}\", \"${2}\", \"${3}\", \"${4}\" );"
    exit 1
fi;

## NORMAL RUN ##
$GAP_BIN -o 50g -L ~/.gap/emptyWorkspace -r -b -q read.g << EOI
tmp := GET_REAL_TIME_OF_FUNCTION_CALL(
    MappingsCacheLookup,
    [ "$1", "$2", "$3", "$4" ],
    rec( passResult := true )
);;
if IsBound( tmp ) then
    res := tmp.result;;
    t := tmp.time;;
    res.sizeOmega;
    res.numberOrbits;
    t;
fi;
EOI

