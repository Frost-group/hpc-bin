#! /bin/awk -f
BEGIN{j=0
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
at_symbol[64]="Pt"
at_symbol[65]="Au"
at_symbol[66]="Hg"
at_symbol[67]="Tl"
at_symbol[68]="Pb"
at_symbol[69]="Bi"
}
{
 if (($1=="Standard" && $2=="orientation:") || ($1 == "Z-Matrix" && $2 == "orientation:")) {
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
   }
  if ($1=="SCF" && $2=="Done:") {
    energy=$5
    j++
    }

}
END{
          for (k=1;k<=i;k++) {
             print at_symbol[at[k]], x[k], y[k], z[k]
          }
}


