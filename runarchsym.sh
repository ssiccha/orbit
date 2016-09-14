#!/bin/bash

if [ "$#" != "3" ]; then
   echo "Usage: runarchsym.sh <app-name> <arch-name> <input-filename>"
   exit 1
fi;

gap -o 50g -L ~/.gap/emptyWorkspace -r -b -q << EOI
Read("read.g");
tmp := GET_REAL_TIME_OF_FUNCTION_CALL( wrapperForExamples, [ "$1", "$2", "$3" ], rec( passResult := true ) );;
res := tmp.result;;
t := tmp.time;;
res.sizeOmega;
res.numberOrbits;
t;
EOI

