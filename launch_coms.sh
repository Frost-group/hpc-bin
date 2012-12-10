#!/bin/sh

#Automagic .com CX1 (Imperial College London HPC) job submitter. A WIP. 
#JMF 2007-09
#Bash is a stranger in an open car...
#2012-04-27: Finally got around to adding single CPU defaults (for quick semi-empirical QC)
#2012-06-19: Merged in 'these are my options' echo from the NWCHEM branch of this script, as it is well useful

#Get Options

NCPUS=8
MEM=11800mb   #Simon Burbidge correction - lots of nodes with 12GB physical memory, leaves no overhead for OS
QUEUE="" #default route
TIME="71:58:02" # Two minutes to midnight :^)

function USAGE()
{
 cat << EOF
Jarv's Gaussian com file runner.

USAGE: ./launch_coms.sh [-nmqtsl] COMFILE(S)

OPTIONS:
    -n number of cpus
    -m amount of memory
    -q queue
    -t time
    -s short queue (-n 1 -m 1899mb -t 0:59:59)
    -l long  queue (-n 1 -m 1899mb -t 21:58:00)

DEFAULTS (+ inspect for formatting):
    NCPUS = ${NCPUS}
    MEM   = ${MEM}
    QUEUE = ${QUEUE}
    TIME = ${TIME}

The defaults above will require something like the following in your COM files:
    %mem=8GB
    %nprocshared=8
EOF
}

while getopts ":n:m:q:t:sl?" Option
do
    case $Option in
        n    )  NCPUS=$OPTARG;;
        m    )  MEM=$OPTARG;;
	    q    )  QUEUE=$OPTARG;;
	    t    )  TIME="${OPTARG}";;
        s    )  NCPUS=1
                TIME="0:59:59"
                MEM="1899mb";;
        l    )  NCPUS=1
                TIME="21:58:00"
                MEM="1899mb";;
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
EOF

shift $(($OPTIND - 1))
#  Decrements the argument pointer so it points to next argument.
#  $1 now references the first non option item supplied on the command line
#+ if one exists.

PWD=` pwd `

for COM in $*
do
 WD=${COM%/*} #subdirectory that .com file is in
 FIL=${COM#*/} #strip filetype off
 echo $PWD $WD $FIL

 if [ "${WD}" = "${FIL}" ]
 then
 echo "WD: ${WD} equiv to File: ${FIL}. Resetting WD to null."
  WD=""
 fi
 #filth to prevent error when .com is in current directory

 cat  > ${COM%.*}.sh << EOF
#!/bin/sh
#PBS -l walltime=${TIME}
#PBS -l select=1:ncpus=${NCPUS}:mem=${MEM}

module load gaussian

cp ${PWD}/${WD}/${FIL} ./
cp ${PWD}/${WD}/${FIL%.*}.chk ./

c8609 "${FIL%.*}.chk"   #convert old checkpoints to latest (i.e. for g03 checkpoints generated before ~Dec 2009)

pbsexec g03 ${FIL}

cp *.log  ${PWD}/${WD}/ 
cp *.chk  ${PWD}/${WD}/

echo "For us, there is only the trying. The rest is not our business. ~T.S.Eliot"

EOF

 #echo "CAPTURED QSUB COMMAND: "
 qsub -q "${QUEUE}" ${COM%.*}.sh
done
