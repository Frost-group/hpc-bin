#!/bin/sh

#monitor_cluster.sh
#Jarv's little script to print useful info on the HPC

echo "Filespace and limits: quota -s"
quota -s
echo

echo "Logged on and active in last hour: w | grep -v days | grep -v m\ | wc -l "
w | grep -v days | grep -v m\ | wc -l
echo

qstat > ~/q.tmp

running=` grep \ R\  ~/q.tmp | wc -l `
qd=` grep \ Q\  ~/q.tmp | wc -l `

echo "My Jobs: ${running} running, ${qd} queued."
echo
#echo "Queues with less than 25 jobs backed up:"
#qstat -q | grep "E R" | awk '$8 != "--" && $7<25{ print $1,$2,$4,$6,$7,$8}' -
qstat -q | grep pqjk
qstat -q | grep q48
echo

echo "Job IDs:"
grep \ R\  ~/q.tmp

echo

echo "Checking load of jobs (in case Zombies eating CPU brains)"
echo
for i in ` grep \ R\  ~/q.tmp | awk '{print $1}' `
do
 load=` qstat -f "${i}" | grep cpupercent `
 exec_host=`qstat -f "${i}" |grep exec_host | awk '{print $3}' `
 echo $i $load "ssh" ${exec_host%/*} 
done
