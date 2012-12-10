for i in *.log
do
 SCF=` grep "SCF Done" "${i}" | tail -n1 | awk '{print $5}' `
 echo $i $SCF
done
