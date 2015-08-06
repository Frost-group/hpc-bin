#!/bin/sh

for i 
do
 echo "GNUPLOT \`stats\` on ${i}"
 echo "stats(\"${i}\")" | gnuplot
done
