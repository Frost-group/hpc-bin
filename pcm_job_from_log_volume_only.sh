#This crazy little script runs a ~few second Gaussian job, basd on coordinates from a previous job, to hijack the PCM code and get a 'solute' volume out of Gaussian

#cp ../template.sh ./

header='pcmvolume'

for i #c1 c2 c3 e1 t1 t2 t3 t4 
do
#echo "Making directory: " td_dft/$i
# mkdir td_dft/$i
 #cp ${i} ${header}/${header}-${i}

comfile="${header}-${i%.*}.com"

 echo "Building comfile: ${comfile}"

# cp ${i%.*}.chk td_dft
#oops - misnamed files!
# head -n 2 $comfile > td_dft/tddft_${comfile}

cat >> ${comfile} <<EOF
%chk=tmp.chk
%Mem=8Gb
%nproc=8
#p sp am1 scrf=(pcm,solvent=ChloroBenzene)

PCM Solute size estimate (only!)

0 1
EOF

jkp_extract_geom.awk "${i}" >> ${comfile}
echo >> ${comfile}

# . ../write_scripts.sh td_dft/${i}/tddft_${comfile}

done
