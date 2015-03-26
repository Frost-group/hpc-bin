for i #in */*.out
do
#    echo -n "${i}"

#'sed -n 1p' will print 1st line, etc.
    ELECTRONS=` grep "No. of electrons :" "${i}" | sed -n 1p | awk '{print $5/2}' `
    #OK, this is now orbitals, not electrons (i.e. #electrons / 2)
    ENERGY=` grep "Total DFT energy" "${i}" | sed -n 1p | awk '{print $5}' `

    CAM=` grep " cam " "${i}" | sed -n 1p | awk '{print $2}' `

#    echo "${i} Electrons: $ELECTRONS Energy: $ENERGY"

#Molecular orbitals we get
#Neutral: Just alpha
#Cation: Alpha then Beta
#Anion: Alpha then Beta
#Believe we just want the Alpha orbitals?

    echo -n "${i} ${CAM}"
#echo "NEUTRAL"
    grep "Vector  ${ELECTRONS}" "${i}" | sed -n 1p | sed s/=/\ /g | sed s/D/E/g | awk '{printf(" %f ",$6*27.211)}'
let LUMO=${ELECTRONS}+1
    grep "Vector  ${LUMO}" "${i}" | sed -n 1p | sed s/=/\ /g | sed s/D/E/g | awk '{printf(" %f ",$6*27.211)}'
#echo "CATION"
#    grep "Vector  ${ELECTRONS}" "${i}" | sed -n 2p | sed s/=/\ /g | awk '{printf (" %f ",$6*0.27211)}'
grep "Total DFT energy" "${i}" | sed -n 2p | awk '{printf (" %f ",27.211*-($5-('$ENERGY')))}'
#echo "ANION"
#    grep "Vector  ${ELECTRONS+1}" "${i}" | sed -n 4p | sed s/=/\ /g | awk '{printf (" %f ",$6*0.27211)}'
grep "Total DFT energy" "${i}" | sed -n 3p | awk '{printf (" %f ",27.211*($5-('$ENERGY')))}'
    echo
    #    grep "Root  1" "${i}" 

done
