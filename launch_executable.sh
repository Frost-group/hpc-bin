#!/bin/sh

#Automagic .com CX1 job submitter. A WIP. 
#JMF 2007-09
#2013-07-08 extended to run arbitrary executable (for Fabian)
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
Jarv's executable job runner.

USAGE: ./launch_executable.sh [-nm]

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

while getopts ":n:m:q:t:d?" Option
do
    case $Option in
        n    ) NCPUS=$OPTARG;;
        m    ) MEM=$OPTARG;;
	    q    ) QUEUE=$OPTARG;;
	    t    ) TIME="${OPTARG}";;
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


COM="${1}"
 FIL=${COM#*/} #strip filetype off
 echo $PWD $FIL

 cat  > ${COM%.*}.sh << EOF
#!/bin/sh
#PBS -l walltime=${TIME}
#PBS -l select=1:ncpus=${NCPUS}:mem=${MEM}

module load intel-suite

cp ${PWD}/* ./

pbsexec ./${*} 

cp *.*  ${PWD} 

echo "For us, there is only the trying. The rest is not our business. ~T.S.Eliot"

EOF

#NB: this is a bit of a hack - you can only run one executable per directory
#Weird things may happen if you have any subdirectories (current in copies PWD/*, to get the executable / any run files without extensions)
#It assumes you only want the *.* files back at the end of day
#It does, however, work, and allows you to stop worrying about your directory to get files to pass to qsub / bash

 #echo "CAPTURED QSUB COMMAND: "
 qsub -q "${QUEUE}" ${COM%.*}.sh
