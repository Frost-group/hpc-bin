#! /bin/tcsh
rm -f map_nodes
set tot_usage = 0
set tot_power = 0
foreach first ( `seq 1 12` )
       foreach second (`seq 1 12`)
               foreach third (`seq 1 12`)
                       ssh cx1-${first}-${second}-${third} ls > /dev/null
                       if ( $? == 0 ) then
                           ssh cx1-${first}-${second}-${third} top -n1 -b -i -1 > fo_node.tmp
                           set usage_node = `grep "^[0-9]" fo_node.tmp | awk '{tot += $9} END{print tot/100}'`
                           set power_node = `ssh cx1-${first}-${second}-${third}  grep processor /proc/cpuinfo | xargs | awk '{print $NF+1}'`
                           set tot_usage = ` echo "${tot_usage} + ${usage_node}" | bc -l`
                           set tot_power = ` echo "${tot_power} + ${power_node}" | bc -l`

                           echo "cx1-${first}-${second}-${third}" >> map_nodes
                           ssh cx1-${first}-${second}-${third}  grep "model\ name" /proc/cpuinfo >> map_nodes

                           echo $tot_usage, $tot_power
                       endif
               end
       end
end
set usage = ` echo "${tot_usage} / ${tot_power} " | bc -l `

echo "TOTAL USAGE: $usage"
is the script
sorry
 
