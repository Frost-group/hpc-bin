# This was based on JMF 'noodles.sh'; 
#   adapted for .xyz files as generated from Gaussian .log file with jkp_extract_geom.awk or similar
# Everyone loves a bit of Raman

# This program, when given a list of .xyz files, will generate a massive matrix of new SP calculations
#  With QC method and basis as specified in these DO loops

for file
do

    for METHOD in b3lyp CAM-b3lyp PBE1PBE PBEPBE 
    do
        for BASIS in "6-31g*" AUG-cc-pVDZ AUG-cc-pVTZ AUG-cc-pVQZ 
        do


            suffix=` echo "_${METHOD}_${BASIS}" | tr "*+" "sp" `
                # NB: Armour file names, convert * -> s, + -> p
            instruct="#p opt(VeryTight,CalcAll) Integral(Grid=UltraFine)  ${METHOD}/${BASIS} "

            echo "OK; suffix is ${suffix}"
            echo "    Run line is ${instruct}"

            echo "Generating COM file ${file%.*}${suffix}.com"
            cat > "${file%.*}${suffix}.com" << EOF
%Chk=${file%.*}${suffix}.chk
%Mem=8Gb
%nproc=8
${instruct}

Autjob by noodles.sh | Great noodly basis sets! 8)

0 1
EOF

cat $file >>  "${file%.*}${suffix}.com"
echo ""   >> "${file%.*}${suffix}.com"


#            echo "Copying Checkpoint... (disks grind into dust)... ${file%.*}.chk --> ${file%.*}${suffix}.chk"
#            cp "${file%.*}.chk" "${file%.*}${suffix}.chk"

            echo
        done

    done
done

