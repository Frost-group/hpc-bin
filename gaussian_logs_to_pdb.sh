#!/bin/sh

module load gaussian intel-suite mpi

for i
do
 babel -i g03 "${i}" -o pdb "${i%.*}.pdb"
done
