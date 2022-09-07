#!/bin/sh

#Automagic .com CX1 (Imperial College London HPC) job submitter. A WIP. 
#JMF 2007-09
#Bash is a stranger in an open car...
# 2012-04-27: Finally got around to adding single CPU defaults (for quick semi-empirical QC)
# 2012-06-19: Merged in 'these are my options' echo from the NWCHEM branch of this script, as it is well useful
# 2017-03-02: Adding options for Gaussian 2016
# 2022-04: GPFS hack to run on the Intel CX1 queues
# 2022-09-07: deleted taskfarm, added direct run (e.g. from Ephemerel, or WORK) option

# Defaults
NCPUS=32 # New standard, circa, 2020 (General queue)
MEM=64GB # New standard, circa 2020
QUEUE="" #default route
TIME="71:58:02" # Two minutes to midnight :^)
MODULE="gaussian/g16-c01-avx"
TMPDIR=true
SUBMIT=true

function USAGE()
{
 cat << EOF
Jarv's Gaussian COM file runner, for IC HPC CX1.

USAGE: ./launch_coms.sh [-nmqtsle] COMFILE(S)

OPTIONS:
    -n number of cpus
    -m amount of memory
    -q queue
    -t time
    -d don't submit the launch script (for hand editing)

    -6 -9 -3 -- choose Gaussian version; default is ${MODULE}
    3  )  MODULE="gaussian/g03-e01";;
    9  )  MODULE="gaussian/g09-e01";; 
    6  )  MODULE="gaussian/g16-a03";;

    Private queues:
        -e pqexss 'full node' job (-q pqexss -n 20 -m 125GB -t 89:58:00 )
    
    Experimental features:
        -x Run directly from current (network filesystem) directory
           Gaussian sometimes has issues doing this, but enables you to e.g.
           make massive checkpoints in situ, and monitor your job live. 

DEFAULTS (+ inspect for formatting):
    NCPUS = ${NCPUS}
    MEM   = ${MEM}
    QUEUE = ${QUEUE}
    TIME = ${TIME}
    MODULE = ${MODULE}

The defaults above will require something like the following in your COM files:
%mem=${MEM}
%nprocshared=${NCPUS}
# p MaxDisk=200GB 
(Request slightly less memory in your Gaussian job file than allocated. It sometimes overshoots!)
EOF
}

while getopts ":n:m:q:t:396vslewxd?" Option
do
    case $Option in
        n    )  NCPUS=$OPTARG;;
        m    )  MEM=$OPTARG;;
	    q    )  QUEUE=$OPTARG;;
	    t    )  TIME="${OPTARG}";;
        
        3  )  MODULE="gaussian/g03-e01" ;;
        9  )  MODULE="gaussian/g09-e01" ;;
        6  )  MODULE="gaussian/g16-a03" ;;

        e    )  QUEUE="pqexss"
                NCPUS=20
                TIME="89:58:00"
                MEM="125GB";;
        
        x    )  TMPDIR=false;;
        d    )  SUBMIT=false;;
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
    NCPUS   =  ${NCPUS}
    MEM     =  ${MEM}
    QUEUE   =  ${QUEUE}
    TIME    =  ${TIME}
    MODULE  =  ${MODULE}
EOF

shift $(($OPTIND - 1))
#  Decrements the argument pointer so it points to next argument.
#  $1 now references the first non option item supplied on the command line
#+ if one exists.

PWD=` pwd `

for COM 
do
 WD=${COM%/*} #subdirectory that .com file is in
 FIL=${COM#*/} #strip filetype off
 echo $PWD $WD $FIL

 if [ "${WD}" = "${FIL}" ]
 then
 echo "WD: ${WD} equiv to File: ${FIL}. Resetting WD to null."
  WD=""
 fi
 #this is a bit kludgy, but prevents an error when .com is in current directory

cat  > ${COM%.*}.sh << EOF
#!/bin/sh
#PBS -l walltime=${TIME}
#PBS -l select=1:ncpus=${NCPUS}:mem=${MEM}:gpfs=false
# gpfs=false recommend by RCS 2022-04-24 to bias scheduler to running on Intel CX1
# Otherwise you sit in the medium queue, and run on the AMD EPYC (which is much
# lower performance for Gaussian).
# Subject to change as they 'optimise' the queues

module load "${MODULE}" 

EOF

if [[ "$TMPDIR" == true ]]
then
    cat >> ${COM%.*}.sh << EOF
cp ${PWD}/${WD}/${FIL} ./
cp ${PWD}/${WD}/${FIL%.*}.chk ./
EOF
else
    cat >> ${COM%.*}.sh << EOF
cd ${PWD}/${WD}/
EOF
fi

cat  >> ${COM%.*}.sh << EOF

#convert old checkpoints to latest (i.e. for g03 checkpoints generated before ~Dec 2009)
#c8609 "${FIL%.*}.chk"   

# no more pbsexec... running directly. 
# g03 is sym-linked to whatever version you've loaded :^)
g03 ${FIL}

EOF

if [[ "$TMPDIR" == true ]]
then
    cat >> ${COM%.*}.sh << EOF
cp *.log  ${PWD}/${WD}/ 
cp *.chk  ${PWD}/${WD}/

EOF
fi

cat  >> ${COM%.*}.sh << EOF
echo "For us, there is only the trying. The rest is not our business. ~T.S.Eliot"
EOF

if [[ "$SUBMIT" == true ]]
then
    qsub -q "${QUEUE}" ${COM%.*}.sh
fi

done

