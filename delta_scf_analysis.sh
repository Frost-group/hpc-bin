#!/bin/sh

for i
do
 
    NEUTRAL=` grep "SCF Done" ${i}NEUTRAL.log | awk {'print $5}'  `
    ANION=` grep "SCF Done" ${i}ANION.log    |  awk {'print $5}'  `
    CATION=` grep "SCF Done" ${i}CATION.log  |  awk {'print $5}'  `

    echo "NEUTRAL: $NEUTRAL Hartree ANION: $ANION Hartree CATION: $CATION Hartree"
    echo -n "IP: "
    echo "($ANION - $NEUTRAL) * 27.211" | bc -l
    echo -n "EA: "
    echo "($NEUTRAL - $CATION) * 27.211" | bc -l
done
