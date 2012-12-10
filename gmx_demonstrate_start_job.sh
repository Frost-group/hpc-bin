#!/bin/sh
#PBS -l walltime=71:59:02
#PBS -l select=1:ncpus=8:mem=8000mb

module load intel-suite
module load mpi
module load gromacs/4.0.2

cp /work/jmf02/gmx_p3ht_pcbm/topol.tpr ./

pbsexec mpiexec  mdrun 

cp * /work/jmf02/gmx_p3ht_pcbm/
