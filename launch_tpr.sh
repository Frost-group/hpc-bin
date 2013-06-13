#!/bin/sh

#Automagic .com CX1 job submitter. A WIP. 
#JMF 2007-09
#2013-06-11 - added option to run double precision version of MDRUN; it was late and I was tired.
#Bash is a stranger in an open car...

#Get Options

NCPUS=8
MEM=11800mb   #Simon Burbidge correction - lots of nodes with 12GB physical memory, leaves no overhead for OS
QUEUE="" #default route
TIME="71:58:02" # Two minutes to midnight :^)

function USAGE()
{
 cat << EOF
Jarv's Gaussian^H^H^H^H^H^H^H^H Gromacs com^H^H^H tpr file runner.

USAGE: ./launch_coms.sh [-nm]

OPTIONS:
	-n number of cpus
	-m amount of memory
	-q queue
	-t time
    -d run double precision (generally for energy minimisation)

DEFAULTS (+ inspect for formatting):
	NCPUS = ${NCPUS}
	MEM   = ${MEM}
	QUEUE = ${QUEUE}
	TIME = ${TIME}
EOF
}

MDRUN="mdrun"

while getopts ":n:m:q:t:d?" Option
do
    case $Option in
        n    ) NCPUS=$OPTARG;;
        m    ) MEM=$OPTARG;;
	q    ) QUEUE=$OPTARG;;
	t    ) TIME="${OPTARG}";;
    d   )  MDRUN="mdrun_mpi_d";;
        ?    ) USAGE
               exit 0;;
        *    ) echo ""
               echo "Unimplemented option chosen."
               USAGE   # DEFAULT
    esac
done

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

module load gromacs/4.6 gromacs/4.5.4 mpi intel-suite

cp ${PWD}/${WD}/${FIL} ./

pbsexec mpiexec ${MDRUN} -s ${FIL}

cp *.*  ${PWD}/${WD}/ 

EOF

 #echo "CAPTURED QSUB COMMAND: "
 qsub -q "${QUEUE}" ${COM%.*}.sh
done
