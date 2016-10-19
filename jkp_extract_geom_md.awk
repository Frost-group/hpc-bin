#! /bin/awk -f
# Extended by Jarv 2016 to extract frames from Gaussian BOMD

BEGIN{
    stride=100
    frame=0
    j=0
at_symbol[0]="Bq"   
at_symbol[1]="H"
at_symbol[2]="He"
at_symbol[3]="Li"
at_symbol[4]="Be"
at_symbol[5]="B"
at_symbol[6]="C"
at_symbol[7]="N"
at_symbol[8]="O"
at_symbol[9]="F"
at_symbol[10]="Ne"
at_symbol[11]="Na"
at_symbol[12]="Mg"
at_symbol[13]="Al"
at_symbol[14]="Si"
at_symbol[15]="P"
at_symbol[16]="S"
at_symbol[17]="Cl"
at_symbol[18]="Ar"
at_symbol[19]="K"
at_symbol[20]="Ca"
at_symbol[21]="Sc"
at_symbol[22]="Ti"
at_symbol[23]="V"
at_symbol[24]="Cr"
at_symbol[25]="Mn"
at_symbol[26]="Fe"
at_symbol[27]="Co"
at_symbol[28]="Ni"
at_symbol[29]="Cu"
at_symbol[30]="Zn"
at_symbol[31]="Ga"
at_symbol[32]="Ge"
at_symbol[33]="As"
at_symbol[34]="Se"
at_symbol[35]="Br"
at_symbol[36]="Kr"
at_symbol[46]="Pd"
at_symbol[47]="Ag"
at_symbol[48]="Cd"
at_symbol[50]="Sn"
at_symbol[51]="Sb"
at_symbol[53]="I"
at_symbol[54]="Xe"
at_symbol[78]="Pt"
at_symbol[79]="Au"
at_symbol[80]="Hg"
at_symbol[81]="Tl"
at_symbol[82]="Pb"
at_symbol[83]="Bi"
}
# Looks like:
#  15  TRJ-TRJ-TRJ-TRJ-TRJ-TRJ-TRJ-TRJ-TRJ-TRJ-TRJ-TRJ-TRJ-TRJ-TRJ-TRJ-TRJ-TRJ
#                           Input orientation:
#  ---------------------------------------------------------------------
#  Center     Atomic      Atomic             Coordinates (Angstroms)
#  Number     Number       Type             X           Y           Z
#  ---------------------------------------------------------------------
#       1          1           0       -0.208875   -2.256122    0.033888
#       2          6           0        0.058559   -1.246079   -0.003553
#       3         16           0       -1.160693   -0.001710    0.000882
#       4          6           0        1.310899   -0.716553   -0.002933
#       5          1           0        2.243953   -1.320468    0.027368
#       6          6           0        1.322122    0.713739   -0.001053
#       7          1           0        2.209425    1.358938    0.024888
#       8          6           0        0.062890    1.245161   -0.005394
#       9          1           0       -0.219895    2.316352    0.039886
#  ---------------------------------------------------------------------

{
 if (($1=="Input" && $2=="orientation:") ) {
   getline
   getline
   getline
   getline
   getline
   i=0
   while (NF!=1) {
      i++
      at[i]=$2
      if (NF==5) {
        x[i]=$3
        y[i]=$4
        z[i]=$5
        }
      else {
        x[i]=$4
        y[i]=$5
        z[i]=$6
        }
      getline
      }
   
      frame++
      if (frame%stride==0)
      {
        # OK, we have just read a trajectory frame, so print it out in XYZ form
        print i
        print "Frame ",frame
        for (k=1;k<=i;k++) {
            print at_symbol[at[k]], x[k], y[k], z[k]
       }
}

}

}
END{
}


