# Run with a list of VASP OUTCARS; I'll echo to STDOUT a very basic single-line convergence check
# Currently just # of SCF steps; and last two TOTENs

for i
do
 echo -n "${i} SCF Steps: " 
 grep "free energy" "${i}" | wc -l | awk '{printf "%d",$1}'
 echo -n " Last two TOTEN: "
 grep "free energy" "${i}" | tail -n2 | awk '{printf "\t%f",$5}'
 echo
done
