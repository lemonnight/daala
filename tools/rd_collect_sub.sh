#!/bin/bash

ENCODER_EXAMPLE=$1
DUMP_VIDEO=$2
DUMP_PSNRHVS=$3
TMP_DIR=$4
FILE=$5

BASENAME=$(basename $FILE)
rm $BASENAME.out 2> /dev/null
echo $BASENAME

for x in {2..40}; do
  OD_LOG_MODULES='encoder:10' $ENCODER_EXAMPLE -v $x $FILE -o $TMP_DIR/$BASENAME-$x.ogv 2> $TMP_DIR/$BASENAME-$x-enc.out
  PIXELS=$(cat $TMP_DIR/$BASENAME-$x-enc.out | grep 'Plane 0' | sed -re 's/^.*Pixels:\ +([0-9]+).*$/\1/')
  PSNR=$(cat $TMP_DIR/$BASENAME-$x-enc.out | grep 'Plane 0' | sed -re 's/^.*PSNR:\ +([0-9\.]+).*$/\1/')
  SIZE=$(cat $TMP_DIR/$BASENAME-$x-enc.out | grep 'Output' | sed -re 's/^.*Bytes:\ +([0-9]+).*$/\1/')
  $DUMP_VIDEO $TMP_DIR/$BASENAME-$x.ogv -o $TMP_DIR/$BASENAME-$x.y4m 2> /dev/null
  PSNRHVS=$($DUMP_PSNRHVS -y $FILE $TMP_DIR/$BASENAME-$x.y4m 2> /dev/null | grep Total | cut -d\  -f 2)
  rm $TMP_DIR/$BASENAME-$x.ogv $TMP_DIR/$BASENAME-$x.y4m $TMP_DIR/$BASENAME-$x-enc.out
  echo $x $PIXELS $SIZE $PSNR $PSNRHVS >> $BASENAME.out
  #tail -1 $BASENAME.out
done