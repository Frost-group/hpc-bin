#!/bin/bash
#  Must run under full featured bash; to use associative arrays. 
#  Don't call with 'sh delta_scf_from_neutral_geom.sh' !
#Jarv ~ 26-4-12
#   & 27-3-15
#Generate .com files from a base .log file for the necessary jobs for DELTA-SCF IP/EA

METHOD="b3lyp/6-31g*"

for i
do
#OK; Need: Geom opts in the neutral and charged state
#SP energy calcs for each of these in n + c state

# Using associative arrays; relies on Bash > v.4
    declare -A DSCF
    DSCF=( ["NEUTRAL"]="0 1" ["ANION"]="-1 2" ["CATION"]="+1 2")


    for STATE in "${!DSCF[@]}" 
    do
        filename="${i%.*}_${STATE}.com"
        MULTIPLICITY="${DSCF["${STATE}"]}"

        echo $MULTIPLICITY " --> " "${filename}"

cat > "${filename}" << EOF
%Mem=8Gb
%nproc=24
#p sp ${METHOD}

B3lyp auto opt job - neutral state

${MULTIPLICITY}
EOF

        jkp_extract_geom.awk "${i}" >> "${filename}"
        echo "" >> "${filename}"

    done
done

