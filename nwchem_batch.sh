#!/bin/sh

echo "Attempt to run NWCHEM as batch interactive job... (no qsub)..."
echo "Give me a list of .nw files & I'll make a directory for all the output & attempt to run it. "

for f
do
 echo "... ${f} ..."
 newdir="${f%.*}"
 mkdir "${newdir}"
 cp -a "${f}" "${newdir}"
 cd "${newdir}"

 echo "... running NWCHEM on ${f}..."
 mpirun -np 24 nwchem "${f}" > "${newdir}.log" 
 echo "... Finished! ..."

 cd -
done
