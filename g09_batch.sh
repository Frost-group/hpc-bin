#!/bin/sh

# Jarv's terrible Gaussian runner; for 'interactive' use on a set of jobs

for i
do
 echo "Running \"g09 ${i}\"..."
 g09 "${i}"
done
