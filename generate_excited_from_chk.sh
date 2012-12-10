check=$1
cube="./${check%.*}_excited.chk"

PWD=` pwd `

tee ${check%.*}_excited.sh << EOW
#!/bin/sh
#PBS -l walltime=71:59:02
#PBS -l select=1:ncpus=8:mem=10000mb

module load gaussian

cp ${PWD}/${check} ./${check%.*}_excited.chk

cat > ./${check%.*}_excited.com << EOF
%chk=./${check%.*}_excited.chk
%Mem=8Gb
%nproc=8
#p sp guess=read geom=checkpoint scf=tight b3lyp/6-31g* td(singlets,root=1)  Density=Current pop=NO

Generates CI and SCF densities...

0 1

EOF

pbsexec g03 ./${check%.*}_excited.com


formchk "${cube}" "${cube%.*}.fchk"

cubegen 0 density=CI "${cube%.*}.fchk" "${cube%.*}_excited_NO.cube" 0 h

#NOW COMES THE FUNK :)

#rip off header from CI file to get gnd state calc in exact form
yz=\` head -n 6 "${cube%.*}_excited_NO.cube" | tail -n2 \`
#neg before first Nx, to force into correct Bohr / Angstrom units - unbelievable gaussian using this as a flag!
x=\` head -n 4 "${cube%.*}_excited_NO.cube" | tail -n1 | awk '{print 0-\$1,\$2,\$3,\$4}' \`
orig=\` head -n 3 "${cube%.*}_excited_NO.cube" | tail -n1 | awk '{print "-1",\$2,\$3,\$4}' \`

# -e adds interpretation of escape characters
echo -e "\$orig \n \${x} \n \$yz" | cubegen 0 density=scf "${cube%.*}.fchk" "${cube%.*}_gnd_NO.cube" -1 h

#Primitive fortran program doesn't even take command line options.
echo -e "su \n"${cube%.*}_excited_NO.cube" \nyes \n"${cube%.*}_gnd_NO.cube" \nyes \n"${cube%.*}_subtr_NO.cube" \nyes" | cubman 

cp *.chk *.log *.com *.cube "${PWD}"

EOW

qsub -q pqexss ${check%.*}_excited.sh
