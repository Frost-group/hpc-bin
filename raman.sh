#!/usr/bin/awk -f
BEGIN{j=0 
a=0}
{
   if (($1=="Frequencies")) 
       { 
           freq[j]=$3
           j++
           freq[j]=$4
           j++
           freq[j]=$5
           j++
        }
   if (($1=="Raman"))
       {
           activ[a]=$4
           a++
           activ[a]=$5
           a++
           activ[a]=$6
           a++
        }
}
END{
     for (k=1;k<=j;k++) 
         {
             print freq[k], activ[k]
         }
}
