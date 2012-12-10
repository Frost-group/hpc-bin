#!/bin/sh

echo "Beware: Dragons!"
echo "Oh dear, you've queued a load of non working jobs haven't you? :)"

for id in ` qstat | grep "0 Q " | cut -f1 -d\ `
do
    echo -n "${id} "
   qdel "${id}"
done
