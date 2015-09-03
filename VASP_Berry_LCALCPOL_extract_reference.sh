#!/bin/sh -xv

# Grep command produces something like:
# AFE/OUTCAR:            Ionic dipole moment: p[ion]=(   -31.13848    -0.00523   -44.81342 ) electrons Angst
# AFE/OUTCAR: Total electronic dipole moment: p[elc]=(    -2.42673    -0.00118     6.16094 ) electrons Angst
# FE/OUTCAR:            Ionic dipole moment: p[ion]=(   -31.13961    -0.00523   -44.63369 ) electrons Angst
# FE/OUTCAR: Total electronic dipole moment: p[elc]=(    -2.47871    -0.00123     5.83513 ) electrons Angst

AWKPROGRAM='
/^AFE/ && /ion/ { afe_ion_x=$6; afe_ion_y=$7; afe_ion_z=$8; }
/^FE/ && /ion/  { fe_ion_x=$6; fe_ion_y=$7; fe_ion_z=$8; }
/^AFE/ && /elc/ { afe_elc_x=$7; afe_elc_y=$8; afe_elc_z=$9; }
/^FE/  && /elc/  { fe_elc_x=$7; fe_elc_y=$8; fe_elc_z=$9; }
END {
# See http://cms.mpi.univie.ac.at/wiki/index.php/LCALCPOL
    p_elc = (fe_elc_x + fe_elc_y + fe_elc_z) - (afe_elc_x + afe_elc_y + afe_elc_z )
    p_ion= (fe_ion_x + fe_ion_y + fe_ion_z) - (afe_ion_x + afe_ion_y + afe_ion_z )
    p_tot= p_elc + p_ion

    printf("p_elc: %f p_ion: %f p_tot: %f \n", p_elc, p_ion, p_tot);
}
'

grep "dipole moment" */OUTCAR
grep "dipole moment" */OUTCAR | awk "${AWKPROGRAM}"
