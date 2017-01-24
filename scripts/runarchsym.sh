#!/bin/bash
# runarchsym.sh

if [ "$#" != "3" ]; then
   echo "Usage: runarchsym.sh <app-name> <arch-name> <input-filename>"
   exit 1
fi;

cd ../gap

## DEBUG ##
#echo "gap read.g"
#echo "MappingsCacheLookup( \"${1}\", \"${2}\", \"${3}\", \"dummyOutStream\" );"
#exit 1
## DEBUG ##

gap -o 50g -L ~/.gap/emptyWorkspace -r -b -q read.g << EOI
tmp := GET_REAL_TIME_OF_FUNCTION_CALL(
    MappingsCacheLookup,
    [ "$1", "$2", "$3", "dummyOutStream" ],
    rec( passResult := true )
);;
res := tmp.result;;
t := tmp.time;;
res.sizeOmega;
res.numberOrbits;
t;
EOI

