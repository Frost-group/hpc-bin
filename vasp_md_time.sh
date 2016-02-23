#!/bin/sh
echo "# Tot up number of Ionic Steps in OUTCAR from VASP; and turn into # ps, assuming 0.5 fs time step "

for i
do
 IonicSteps=` grep "LOOP+" "${i}" | wc -l `
 PicoSeconds=` echo "${IonicSteps} / (2*1000)" | bc -l `

 echo "${i} IonicSteps ${IonicSteps} ; PicoSeconds ${PicoSeconds}"
done
