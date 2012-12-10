#!/bin/sh

#Automagic .com CX1 (Imperial College London HPC) job submitter. A WIP. 
#JMF 2007-09
#Bash is a stranger in an open car...
#2012-04-27: Finally got around to adding single CPU defaults (for quick semi-empirical QC)

#2012-05-26: Forking this code to use for running NWCHEM .nw programs
#2012-06: Now runs multi-host over MPI for NWCHEM
#2012-06-18: Extended to restart NWCHEM jobs. Also, I actually learnt how to use 'getopts' as part of this.

# RUN AS ./executable.sh OTHERWISE OPTIONS WILL NOT BE GATHERED!

#Get Options

NCPUS=8
MEM=11800mb   #Simon Burbidge correction - lots of nodes with 12GB physical memory, leaves no overhead for OS
QUEUE="" #default route
TIME="71:58:02" # Two minutes to midnight :^)
HOSTS=1 #Ah, the Host!
RESTART="NAH"

function USAGE()
{
 cat << EOF
Jarv's NWCHEM .nw file runner.

USAGE: ./launch_nw.sh [-nmqtsl] NWCHEM_RUN_FILES(S)

Suggested memory command for nwchem:
    memory stack 300 mb heap 300 mb global 600 mb
    Nb: Memory is (global seperate from stack and heap) cummulative, and per MPI process

OPTIONS:
	-n number of cpus
	-m amount of memory
	-q queue
	-t time
    -h hosts
    -s short queue (-n 1 -m 1899mb -t 0:59:59)
    -l long  queue (-n 1 -m 1899mb -t 21:58:00)

    -r restart (copies run files, adds restart line to NWCHEM input deck)

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

while getopts ":n:m:q:t:h:slr?" Option
do
    case $Option in
#OPTIONS
        n    )  NCPUS=$OPTARG;;
        m    )  MEM=$OPTARG;;
	    q    )  QUEUE=$OPTARG;;
	    t    )  TIME="${OPTARG}";;
        h    )  HOSTS="${OPTARG}";;
#FLAGS
        s    )  NCPUS=1
                TIME="0:59:59"
                MEM="1899mb";;
        l    )  NCPUS=1
                TIME="21:58:00"
                MEM="1899mb";;
        r    )  RESTART="YEAH";;
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
    HOSTS   =  ${HOSTS}
    NCPUS   =  ${NCPUS}
    MEM     =  ${MEM}
    QUEUE   =  ${QUEUE}
    TIME    =  ${TIME}
    RESTART =  ${RESTART}
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
#PBS -l select=${HOSTS}:ncpus=${NCPUS}:mem=${MEM}

module load nwchem/6.0 intel-suite mpi

#cp ${PWD}/${WD}/${FIL%.*}.chk ./
#collect all the random files dotted around
cp  ${PWD}/${WD}/${FIL%.*}/*.* ./
#Do this before copying the .nw job file, in case (local directory) job file has changes (i.e. a restart / continuation)

cp ${PWD}/${WD}/${FIL} ./
EOF

#RESTART TAH NAUGHTY JOBS
if [ "${RESTART}" = "YEAH" ]
then
     cat  >> ${COM%.*}.sh << EOF

echo >> ${FIL}
echo "restart" >> ${FIL}

EOF
fi

#OK, RUN AND CLEANUP TIME

cat  >> ${COM%.*}.sh << EOF
pbsexec mpiexec /work/jmf02/nwchem-6.1/bin/LINUX64/nwchem ${FIL} >& ${FIL%.*}.out

#nwchem vomits files everywhere, so lets bundle them up into a folder
mkdir "${FIL%.*}"
mv *.* "${FIL%.*}"
cp -a "${FIL%.*}" ${PWD}/${WD}/ 

echo "I CAME SO FAR FOR BEAUTY."

EOF

# echo "CAPTURED QSUB COMMAND: "
# cat ${COM%.*}.sh
 qsub -q "${QUEUE}" ${COM%.*}.sh
done
