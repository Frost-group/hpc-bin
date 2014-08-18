#!/bin/sh

#Outputs Energies of first 5 unoccupied orbitals, relative to first unocc.
for FILE
do
    echo -n "${FILE} HOMOs "
    grep "occ. eigenvalues" ${FILE} | tail -n1 | awk '{for (i=5;i<=NF;i++) {printf("%f ",($i-$NF)*27.211)}}'
    echo

    echo -n "${FILE} LUMOs "
    grep "virt. eigenvalues" ${FILE} | head -n1 | awk '{print 0.0,($5-$6)*27.211,($5-$7)*27.211,($5-$8)*27.211,($5-$9)*27.211}'

    echo -n "${FILE} TDDFT "
    grep "Excited" ${FILE}

    echo
done
