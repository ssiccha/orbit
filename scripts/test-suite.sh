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
            >&2 echo "Error. File $pipe exists but is not a pipe!"
            exit 1
        fi
    fi
}

execute_on_data () {
    inpipe="$BASEDIR/pipes/"$1"-in-pipe"
    outpipe="$BASEDIR/pipes/"$1"-out-pipe"
    make_pipe $inpipe
    make_pipe $outpipe
    cat ${DATADIR}/$1 >> ${inpipe} && echo "" >> ${inpipe} &
    OUTFILE="$OUTPUTDIR/results${1#${APP}.${ARCH}}"
    echo "$1 ($OUTFILE)"
    $GAPSCRIPT $APP $ARCH ${inpipe} ${outpipe} 2>$OUTPUTDIR/errors.txt > $OUTFILE
    rm ${inpipe} ${outpipe}
}

if [ ! -e ~/.gap/emptyWorkspace ]; then
    $BASEDIR/scripts/create-empty-workspace.sh
fi

mkdir -p $OUTPUTDIR
mkdir -p $BASEDIR"/pipes"


## DEBUG RUN ##
if [ "$#" == "3" ]; then
    for filename in $DATAFILENAMES; do
        inpipe="$BASEDIR/pipes/"${filename}"-in-pipe"
        outpipe="$BASEDIR/pipes/"${filename}"-out-pipe"
        echo "Creating pipes."
        make_pipe $inpipe
        make_pipe $outpipe
        echo "Writing data to in-pipe."
        cat ${DATADIR}/${filename} >> ${inpipe} && echo "" >> ${inpipe} &
        $GAPSCRIPT $APP $ARCH ${inpipe} ${outpipe} 1
        echo -n "Hit Enter when done: "
        read DONE
        rm ${inpipe} ${outpipe}
        exit 1
    done
fi;


## NORMAL RUN ##
cd $GAPDIR/

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
