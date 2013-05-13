#!/bin/sh
for i
do
 ~/bin/jkp_extract_geom.awk "${i}" > "${i%.*}.xyz"
done
