#Jarv ~ 26-4-12
#Generate .com files from a base .chk file for the necessary jobs to calc polaron reorg energy

echo "WARNING: Be careful, don't run these jobs till you actually have the checkpoints returned!"

CHARGE="-1" #holes...
METHOD="b3lyp/6-31g*"

for i
do
#OK; Need: Geom opts in the neutral and charged state
#SP energy calcs for each of these in n + c state

cp "${i}" "${i%.*}_ion_E.chk" 
cp "${i}" "${i%.*}_neutral_E.chk"

cat > "${i%.*}_ion_E.com" << EOF
%chk=${i%.*}_ion_E.chk
%Mem=8Gb
%nproc=8
#p geom=check guess=read sp ${METHOD}

B3lyp auto opt job - neutral state

${CHARGE} 2

EOF

cat > "${i%.*}_neutral_E.com" << EOF
%chk=${i%.*}_neutral_E.chk
%Mem=8Gb
%nproc=8
#p geom=check guess=read sp ${METHOD}

B3lyp auto opt job - neutral state

0 1

EOF

done
