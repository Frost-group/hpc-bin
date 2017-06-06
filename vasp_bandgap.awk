#!/usr/bin/awk -f 
# Pass me an 'OUTCAR' and I'll extract fundamental gaps at all k-points.
# And then I'll tell you the smallest direct gap, 
#   and smallest indirect gap (along with k-space locations of CBM/VBM)

# Though bare in mind the indirect gap will be spurious if it's a geometry
# optimisation, and the 'direct gap' will be from whatever intermediate
# geometry had the smallest gap

# Assumes closed shell calculation (double occupancy)

#Relevant part of OUTCAR Looks like: (aide memoir for programming...)
# k-point    14 :      -0.3333   -0.3333    0.3333
#  band No.  band energies     occupation 
#      1     -18.3955      2.00000
#      2     -18.3927      2.00000
BEGIN {
    for (i=1;i<ARGC;i++)
    {
        if (ARGV[i]=="-v")
            verbose=1
        else
            break
        delete ARGV[i]
    }
}
# Matches to SCF cycle; so resets counters before plouging through k-points, in geom opt.
/TOTEN/ {
    mindirect=1e6
    cbm=1e6
    vbm=-1e6
}
/k-point/ && (NF==6) {
    kpoint=$2
    kx=$4
    ky=$5 
    kz=$6
    if(verbose)
        printf("k-point: %d kx: %f ky: %f kz: %f ",kpoint,kx,ky,kz)

    getline # Ignore this line 'band No. band energies occupation'
    do 
    {
        getline
        occ=unocc # juggle temporary variables
        unocc=$2 # band energy
    } while ($3 > 0.5) #while more than half occupied
    
    # So now we have a VBM and a CBM, for this k-point
    if (unocc<cbm) { cbm=unocc; cbmkx=kx; cbmky=ky; cbmkz=kz; }
    if (occ>vbm)   { vbm=occ;   vbmkx=kx; vbmky=ky; vbmkz=kz; }
    if (unocc-occ<mindirect) mindirect=unocc-occ
    
    if (verbose)
        printf("VBM: %f CBM: %f Bg: %f\n",occ,unocc,unocc-occ)
}
/total charge-density/ {
    printf("%s Direct-Bg: %f Indirect-Bg: %f\n",FILENAME,mindirect,cbm-vbm)
    printf("\t(Indirect-Bg: %f from VBM: %f at %f %f %f to CBM: %f at %f %f %f)\n",
           cbm-vbm,     
           vbm,vbmkx,vbmky,vbmkz,             
           cbm,cbmkx,cbmky,cbmkz)
}
