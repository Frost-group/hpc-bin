total=0

for i in ` find ./ -name "*.log" ` 
do
 if [ -n "` tail $i | grep Normal `" ]
 then
 calc="$total + ` tail $i | grep "cpu time" | awk '{print $4*24+$6+$8/60+$10/3600}' `  "
 echo $calc
 total=` echo $calc | bc -l `
fi
done

echo $total "Hours CPU Time"
