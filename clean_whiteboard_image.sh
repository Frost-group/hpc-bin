#!/bin/sh

# via: https://gist.github.com/lelandbatey/8677901
# This version of the script takes a list of files (i.e. IMG_XXX.JPG IMG_YYY.JPG) and generates whiteboard_ and bw_ versions of them.
# The first convert line takes a lot of CPU to run! So expect 10-20 s for a moderate 10MB image.

# The BW ones in particular are very useful for photographing pages of old journals in the library

for f
do
    echo "${f}..."
    convert "${f}" -morphology Convolve DoG:15,100,0 -negate -normalize -blur 0x1 -channel RBG -level 60%,91%,0.1 "whiteboard_${f}"
    convert "whiteboard_${f}" -monochrome "bw_${f}"
done
