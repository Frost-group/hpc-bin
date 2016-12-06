#!/usr/bin/awk -f 
# Pass me an 'OUTCAR' and I'll extract fundamental gaps at all k-points.

# Assumes closed shell calculation (double occupancy)

#Looks like:
# k-point    14 :      -0.3333   -0.3333    0.3333
#  band No.  band energies     occupation 
#      1     -18.3955      2.00000
#      2     -18.3927      2.00000

BEGIN {
    mindirect=1e6
    cbm=1e6
    vbm=-1e6
}
/k-point/ && (NF==6) {
    kpoint=$2
    kx=$4
    ky=$5 
    kz=$6
    printf("k-point: %d kx: %f ky: %f kz: %f ",kpoint,kx,ky,kz)

    getline # Ignore this line 'band No. band energies occupation'
    do 
    {
        getline
        occ=unocc # juggle temporary variables
        unocc=$2 # band energy
    } while ($3 > 1.0) #while more than half occupied
    
    # So now we have a VBM and a CBM, for this k-point
    if (unocc<cbm) { cbm=unocc; cbmkx=kx; cbmky=ky; cbmkz=kz; }
    if (occ>vbm)   { vbm=occ;   vbmkx=kx; vbmky=ky; vbmkz=kz; }
    if (unocc-occ<mindirect) mindirect=unocc-occ

    printf("VBM: %f CBM: %f Bg: %f\n",occ,unocc,unocc-occ)
}
END {
    printf("\nDirect-Bg: %f Indirect-Bg: %f\n",mindirect,cbm-vbm)
    printf("Indirect-Bg: %f from VBM: %f at %f %f %f to CBM: %f at %f %f %f\n",
           cbm-vbm,     
           vbm,vbmkx,vbmky,vbmkz,             
           cbm,cbmkx,cbmky,cbmkz)
}
