#!/bin/sh 

qstat -f | grep "Resource_List.ncpus" | awk '{total=total+$3}END{print total}'
 
