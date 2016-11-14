#!/bin/sh

#Automagic .com CX1 (Imperial College London HPC) job submitter. A WIP. 
#JMF 2007-09
#Bash is a stranger in an open car...
#2012-04-27: Finally got around to adding single CPU defaults (for quick semi-empirical QC)
#2012-06-19: Merged in 'these are my options' echo from the NWCHEM branch of this script, as it is well useful

#Get Options

NCPUS=12 # New standard, circa, 2016
MEM=11800mb   #Simon Burbidge correction - lots of nodes with 12GB physical memory, leaves no overhead for OS
QUEUE="" #default route
TIME="71:58:02" # Two minutes to midnight :^)

function USAGE()
{
 cat << EOF
Jarv's Gaussian com file runner.

USAGE: ./launch_coms.sh [-nmqtsle] COMFILE(S)

OPTIONS:
    -n number of cpus
    -m amount of memory
    -q queue
    -t time
    -s short single-CPU queue (-n 1 -m 1899mb -t 0:59:59)
    -l long  single-CPU queue (-n 1 -m 1899mb -t 21:58:00)
    -e pqexss 'full node' job (-q pqexss -n 20 -m 125GB -t 89:58:00 ) 
    -x taskfarm! Serialise all jobs within a single taskfarm.sh submission script.

DEFAULTS (+ inspect for formatting):
    NCPUS = ${NCPUS}
    MEM   = ${MEM}
    QUEUE = ${QUEUE}
    TIME = ${TIME}

The defaults above will require something like the following in your COM files:
    %mem=8GB
    %nprocshared=12
EOF
}

while getopts ":n:m:q:t:slex?" Option
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
        e    )  QUEUE="pqexss"
                NCPUS=20
                TIME="89:58:00"
                MEM="125GB";;
        x    )  TASKFARM=TRUE;;
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

# Task farming! serialise all these jobs into taskfarm.sh
if [ $TASKFARM ]
then
    cat > taskfarm.sh << EOF
#!/bin/sh
#PBS -l walltime=${TIME}
#PBS -l select=1:ncpus=${NCPUS}:mem=${MEM}

EOF

for COM
do
    FIL=${COM#*/} #strip filetype off
    cat >> taskfarm.sh << EOF
cp "${PWD}/${FIL}" ./ # Copy run file in
g03 "${FIL}" # Run Gaussian on it
cp "${FIL%.*}.log" "${PWD}" # Copy log file home once we've finished
date >> taskfarm.log
echo "${FIL} finished" >> taskfarm.log

EOF
done

cat >> taskfarm.sh << EOF

cp -a taskfarm.log "${PWD}" # Copy log file home
cat taskfarm.log # will also end up in PBS .s file

echo "For us, there is only the trying. The rest is not our business. ~T.S.Eliot"

EOF

echo "OK; serialised jobs written to taskfarm.sh. Have fun!"

else # Not task farming, create and submit separate jobs for each .COM

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

fi
