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
				>&2 "Error. file $pipe exists but is not a pipe" 
		  fi
	 fi
}

## DEBUG RUN ##
if [ "$#" == "3" ]; then
    for filename in $DATAFILENAMES; do
        pipe="../pipes/"${filename}"-in-pipe"
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
## TODO make it run in parallel!!
for filename in $DATAFILENAMES; do
    echo ${filename}
    pipe="../pipes/"${filename}"-in-pipe"
    make_pipe $pipe
    cat ${DATADIR}/${filename} >> ${pipe} && echo "" >> ${pipe} &
    outfile="$OUTPUTDIR/results${filename#${APP}.${ARCH}}"
    $GAPSCRIPT $APP $ARCH ${pipe} 2>$OUTPUTDIR/errors.txt > $outfile
    rm ${pipe}
done

wait

for filename in $DATAFILENAMES; do
    outfile="$OUTPUTDIR/results${filename#${APP}.${ARCH}}"
    allresults="$OUTPUTDIR/allresults.${APP}.${ARCH}.txt"
    echo "=========================" >> $allresults
    echo $filename >> $allresults
    echo "-------------------------" >> $allresults
    tail -n 3 $outfile >> $allresults
done
