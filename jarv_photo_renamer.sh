#!/bin/sh

#Automagic Photo renamer 
#JMF 2016 - based on prior Bash scripts + my cluster Gaussian job launcher (!) 
#Bash is a stranger in an open car...

#Get Options

#Defaults
Photographer="JarvistMooreFrost"
Camera="CanonS95"

function USAGE()
{
 cat << EOF
Jarv's Automagic Photo Renamer 

SUPER ALPHA VERSION; NOT EVERYTHING IMPLEMENTED; YOU HAVE TO COPY AND PASTE THE MV COMMANDS CURRENTLY :^)

USAGE: ./jarv_photo_renamer.sh JPEGS 

OPTIONS:
    -p Photographer (Default: ${Photographer})
    -c Camera (Default: ${Camera}) 
EOF
}

while getopts ":p:c:?" Option
do
    case $Option in
        p    )  Photographer=$OPTARG;;
        c    )  Camera=$OPTARG;;
	    n    )  DRYRUN=$OPTARG;;
        ?    )  USAGE
                exit 0;;
        *    )  echo ""
                echo "Unimplemented option chosen."
                USAGE   # DEFAULT
    esac
done

#OK, now we should have our options
cat <<EOF
Well, here's what I understood / defaulted to:
    Photographer  =  ${Photographer}
    Camera        =  ${Camera}
EOF

if [ ${CaveName}=="" ]
then
    echo  "No CaveName set. Please enter a CaveName: "
    read CaveName
fi

shift $(($OPTIND - 1))
#  Decrements the argument pointer so it points to next argument.
#  $1 now references the first non option item supplied on the command line
#+ if one exists.

PWD=` pwd `

for JPEG in $*
do
# Use exiftool to read Create Date directly form within JPEG
# Awk selects fourth non-whitespace bit (the actual date)
# Nb: Could use exiftool itself to rename files + act on a stream, probably faster
    DateTime=` exiftool -d "%Y-%m-%d_%Hh%Mm" -createdate "${JPEG}" | awk '{print $4}'`

    new="${DateTime}-${Photographer}-${Camera}-${CaveName}-${JPEG}"

    echo mv "${JPEG}" "${new}"
done
