#!/bin/sh

#Outputs Energies of first 5 unoccupied orbitals, relative to first unocc.
for FILE
do
    echo -n "${FILE} HOMOs "
    grep "occ. eigenvalues" ${FILE} | tail -n3 | #  Print out last three lines of occupied eigenvalues, as one line with spaces 
    awk 'BEGIN{ORS=" "}{print $5,$6,$7,$8,$9}' | # dump all the text & just keep the numbers
    awk '{for (i=5;i<=NF;i++) {printf("%f ",($i-$NF)*27.211)}}' #print them all out relative to the HOMO, in eV
    # WHAT I LACK IN STYLE I MAKE UP FOR IN INEXACITUDE

    echo

    echo -n "${FILE} LUMOs "
    grep "virt. eigenvalues" ${FILE} | head -n1 | awk '{print 0.0,($5-$6)*27.211,($5-$7)*27.211,($5-$8)*27.211,($5-$9)*27.211}'

    echo -n "${FILE} TDDFT "
    grep "Excited" ${FILE}

    echo
done
