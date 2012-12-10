#!/bin/sh

#Outputs Energies of first 5 unoccupied orbitals, relative to first unocc.
for FILE
do
    echo -n "${FILE} LUMOs "
    grep "virt. eigenvalues" ${FILE} | head -n1 | awk '{print 0.0,($5-$6)*27.211,($5-$7)*27.211,($5-$8)*27.211,($5-$9)*27.211}'

done
