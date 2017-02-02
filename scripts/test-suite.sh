#!/bin/bash
# test-suite.sh

if [ "$#" != "2" -a "$#" != "3" ]; then
    echo -en "Usage: \ttest-suite.sh <app-name> <arch-name> <debug>\n"
    echo -en "app-name: \taudio_filter_3, jpeg, "
    echo -en "mjpeg_compaan, sobel, mandelbrot\n"
    echo -en "arch-name: \ts4, s4xs8\n\n"
    echo -en "Any 3rd argument will trigger debug mode.\n"
    exit 1
fi;

if [ "$#" == "3" ]; then
    echo "Debug run."
fi;

APP="$1"
ARCH="$2"
SCRIPTSDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASEDIR=${SCRIPTSDIR%'/scripts'} # remove script directory
DATADIR=${BASEDIR}"/data"
OUTPUTDIR=${BASEDIR}"/results"
OUTPUTDIR=${OUTPUTDIR}/${APP}--`date +%F--%H-%M`
GAPDIR=${BASEDIR}"/gap"
GAPSCRIPT=${BASEDIR}"/scripts/runarchsym.sh"

DATAFILENAMES=""
for file in `ls $DATADIR/${APP}.$ARCH*`; do
    DATAFILENAMES="${DATAFILENAMES} ${file#$DATADIR/}"
done
echo "Running experiments for architecture ${ARCH} and"
echo ${DATAFILENAMES}
echo ""

make_pipe () { 
    if [ ! -p $1 ]; then
        if [ ! -e $1 ]; then
            mkfifo $1
        else
            >&2 echo "Error. file $pipe exists but is not a pipe" 
            exit 1
        fi
    fi
}

execute_on_data () {
    pipe="$BASEDIR/pipes/"$1"-in-pipe"
    make_pipe $pipe
    cat ${DATADIR}/$1 >> ${pipe} && echo "" >> ${pipe} &
    OUTFILE="$OUTPUTDIR/results${1#${APP}.${ARCH}}"
    echo "$1 ($OUTFILE)"
    $GAPSCRIPT $APP $ARCH ${pipe} 2>$OUTPUTDIR/errors.txt > $OUTFILE
    rm ${pipe}
}

if [ -e ~/.gap/emptyWorkspace ]; then
    $BASEDIR/scripts/create-empty-workspace.sh
fi

## DEBUG RUN ##
if [ "$#" == "3" ]; then
    for filename in $DATAFILENAMES; do
        pipe="$BASEDIR/pipes/"${filename}"-in-pipe"
        make_pipe $pipe
        cat ${DATADIR}/${filename} >> ${pipe} && echo "" >> ${pipe} &
        $GAPSCRIPT $APP $ARCH ${pipe} 1
        exit 1
    done
fi;

cd $GAPDIR/

mkdir -p $OUTPUTDIR
mkdir -p $BASEDIR"/pipes"

## NORMAL RUN ##

## Prepare parallel execution
if [ ! -z "`which nproc`" ]; then #Linux
  NUM_PROCESSORS=$((`nproc`))
else 
    if [ ! -z "`which sysctl`" ]; then #OSX
        NUM_PROCESSORS=$((`sysctl -n hw.ncpu`))
    fi
fi

if [ -z "$NUM_PROCESSORS" ]; then
 NUM_PROCESSORS=2 #conservative
fi

PARALLEL=`which parallel`
if [ ! -z "$PARALLEL" ]; then
  export -f execute_on_data make_pipe
  export APP DATADIR ARCH GAPSCRIPT OUTPUTDIR BASEDIR
  $PARALLEL -j $NUM_PROCESSORS execute_on_data ::: $DATAFILENAMES
else
    echo "Warning: GNU parallel not found on your system; running sequentially."
    for filename in $DATAFILENAMES; do
        execute_on_data $filename; 
    done
fi

wait

for filename in $DATAFILENAMES; do
    outfile="$OUTPUTDIR/results${filename#${APP}.${ARCH}}"
    allresults="$OUTPUTDIR/allresults.${APP}.${ARCH}.txt"
    echo "=========================" >> $allresults
    echo $filename >> $allresults
    echo "-------------------------" >> $allresults
    tail -n 3 $outfile >> $allresults
done
