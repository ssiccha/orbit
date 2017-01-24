#!/bin/bash
# test-suite.sh

if [ "$#" != "2" ]; then
    echo -en "Usage: \ttest-suite.sh <app-name> <arch-name>\n"
    echo -en "app-name: \taudio_filter_3, jpeg, "
    echo -en "mjpeg_compaan, sobel, mandelbrot\n"
    echo -en "arch-name: \ts4, s4xs8\n"
    exit 1
fi;

APP="$1"
ARCH="$2"
PWD=`pwd`
BASEDIR=${PWD%'/scripts'} # remove script directory
DATADIR=${BASEDIR}"/data"
OUTPUTDIR=${BASEDIR}"/results"
GAPDIR=${BASEDIR}"/gap"
GAPSCRIPT=${BASEDIR}"/scripts/runarchsym.sh"

DATAFILES=""
for file in `ls $DATADIR/${APP}.$ARCH*`; do
    DATAFILES="${DATAFILES} ${file#$DATADIR/}"
done
echo "Running experiments for architecture ${ARCH} and"
echo ${DATAFILES}

#OUTPUTDIR=$OUTPUTDIR/results-`date +%F-%H-%M`
OUTPUTDIR=$OUTPUTDIR/${APP}--`date +%F--%H-%M`
mkdir -p $OUTPUTDIR

cd $GAPDIR/

for file in $DATAFILES; do
    outfile="$OUTPUTDIR/results${file#${APP}.${ARCH}}"
    ## DEBUG ##
    #$GAPSCRIPT $APP $ARCH ${file#$DATADIR/}
    #exit 1
    ## DEBUG ##
    $GAPSCRIPT $APP $ARCH ${file} 2>$OUTPUTDIR/errors.txt > $outfile&
done

wait

for file in $DATAFILES; do
    outfile="$OUTPUTDIR/results${file#${APP}.${ARCH}}"
    allresults="$OUTPUTDIR/allresults.${APP}.${ARCH}.txt"
    echo "=========================" >> $allresults
    echo $file >> $allresults
    echo "-------------------------" >> $allresults
    tail -n 3 $outfile >> $allresults
done
