# Everyone loves a bit of Raman

# This program, when given a list of .chk files, will generate a massive matrix of new SP calculations
#  With QC method and basis as specified in these DO loops

for file
do

    for METHOD in M06HF #b3lyp M062X CAM-b3lyp BMK
    do
        for BASIS in TZVP #"6-31g*" #"6-311g**"
        do


            suffix=` echo "_${METHOD}_${BASIS}" | tr "*+" "sp" `
                # NB: Armour file names, convert * -> s, + -> p
            instruct="#p guess=read geom=checkpoint scf=verytight ${METHOD}/${BASIS} td(50-50,nstates=6)"

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

            echo "Copying Checkpoint... (disks grind into dust)... ${file%.*}.chk --> ${file%.*}${suffix}.chk"
            cp "${file%.*}.chk" "${file%.*}${suffix}.chk"

            echo
        done

    done
done

