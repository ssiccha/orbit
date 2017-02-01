#!/bin/bash
# runarchsym.sh

if [ "$#" != "3" -a "$#" != "4" ]; then
    echo "Usage: runarchsym.sh <app-name> <arch-name> <in-pipe-filename> <debug>"
    echo -en "\nAny 4th argument will trigger debug mode.\n"
    exit 1
fi;

GAP_BIN='gap'
SCRIPTSDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASEDIR=${SCRIPTSDIR%'/scripts'} # remove script directory
GAPDIR=${BASEDIR}"/gap"
cd ${GAPDIR}

## DEBUG MODE ##
if [ "$#" == "4" ]; then
    echo "Run the following commands to debug:"
    echo "gap read.g"
    echo "MappingsCacheLookup( \"${1}\", \"${2}\", \"${3}\", \"dummyOutStream\" );"
    echo "rm ${3}"
    exit 1
fi;

## NORMAL RUN ##
$GAP_BIN -o 50g -L ~/.gap/emptyWorkspace -r -b -q read.g << EOI
tmp := GET_REAL_TIME_OF_FUNCTION_CALL(
    MappingsCacheLookup,
    [ "$1", "$2", "$3", "dummyOutStream" ],
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

