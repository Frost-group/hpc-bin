#!/bin/sh

for file in "$@"
do
 echo
 echo -n "${file} "
 grep "occ" "${file}" | tail -n 1 | awk '{printf "\t%.3f\t",$NF*27.211}'
 grep Triplet-A "${file}" | awk '{printf "%.3f\t",$5}'
 grep Singlet-A "${file}" | awk '{printf "%.3f\t",$5}'
done
