#!/bin/sh
echo "HERE BE DRAGONS..."
for i
do
 NW=${i%.*}.nw
 echo $NW
 cat HEADER > $NW
 jkp_extract_geom.awk $i >> $NW
 cat FOOTER >> $NW
done
