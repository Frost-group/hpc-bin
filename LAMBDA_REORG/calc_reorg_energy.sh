for i
do
 N_ion=` grep "SCF Done" "${i}"*neutral_opt_ion_E.log | awk '{print $5}' `
 N_neu=` grep "SCF Done" "${i}"*neutral_opt_neutral_E.log |  awk '{print $5}' `
 I_ion=` grep "SCF Done" "${i}"*ion_opt_ion_E.log | awk '{print $5}' `
 I_neu=` grep "SCF Done" "${i}"*ion_opt_neutral_E.log | awk '{print $5}' `

 echo "N_ion: " $N_ion "N_neu: " $N_neu "I_ion: " $I_ion "I_neu: " $I_neu

# 'we follow the method of Sakanou' - JKP Thesis 2.2 Reorganisation Energy
 echo "(($I_neu - $N_neu) + ($N_ion - $I_ion) ) * 27.211 " | bc -l

done
