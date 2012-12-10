#!/bin/sh

echo "Beware: Dragons!"
echo "Chucking: $1 jobs onto queue: $2"

qstat | tail -n $1 | cut -f1 -d\   | xargs -L1 qmove $2 

