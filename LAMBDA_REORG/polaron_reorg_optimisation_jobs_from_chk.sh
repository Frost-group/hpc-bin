#Jarv ~ 26-4-12
#Generate .com files from a base .chk file for the necessary jobs to calc polaron reorg energy

CHARGE="-1" #holes...

for i
do
#OK; Need: Geom opts in the neutral and charged state
#SP energy calcs for each of these in n + c state

cp "${i}" "${i%.*}_ion_opt.chk" 
cp "${i}" "${i%.*}_neutral_opt.chk"

cat > "${i%.*}_ion_opt.com" << EOF
%chk=${i%.*}_ion_opt.chk
%Mem=8Gb
%nproc=8
#p geom=check guess=read opt b3lyp/6-31g*

B3lyp auto opt job - neutral state

${CHARGE} 2

EOF

cat > "${i%.*}_neutral_opt.com" << EOF
%chk=${i%.*}_neutral_opt.chk
%Mem=8Gb
%nproc=8
#p geom=check guess=read opt b3lyp/6-31g*

B3lyp auto opt job - neutral state

0 1

EOF

done
