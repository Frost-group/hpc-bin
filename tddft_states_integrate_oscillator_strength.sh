#!/bin/sh

for FILE 
do
    echo -n "${FILE} "
    grep Excited "${FILE}" | sed s/=/\ / |  # get rid of pesky '=' in f=0.23123 
    awk 'BEGIN{count=0.0}{count=count+$10; print $3,$5,count}' 
    # count up the f's ($10), print info with state $3 and transition eV $5
done
