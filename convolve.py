#!/usr/bin/python
from math import *

width=15.0

#states=input()

wavelength={}
os={}

#for i in range(states):
#    wavelength[i],os[i]=[ float(x) for x in raw_input().split() ]

states=0
while 1:
    try:
        wavelength[states],os[states]=[ float(x) for x in raw_input().split() ]
        states=states+1
    except ValueError:
        break 

cwavelength=-2000.0

while cwavelength <= 5000.0:
    strength=0.0
    for i in range(states):
        strength+=os[i]*exp( - (cwavelength-wavelength[i])*(cwavelength-wavelength[i]) / (2*width*width))
    print cwavelength, strength
    cwavelength+=1.0


