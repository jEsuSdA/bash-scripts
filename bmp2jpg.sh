#!/bin/bash
# Bash Script for converting ALL the BMP image files to JPG
#
# Requires: imagemagick
#
# 201701101 - jEsuSdA


# Function to obtain the filename without extension
function cambiaext {
    str=$1
    ext=`echo ${str:(-5)} | cut -d . -f 2`
    len_ext=${#ext}
    len_cad=${#str}
    titulo=$[len_cad-len_ext]
    namefich=${str:0:($titulo)}
}


# Operate with ALL the BMP files:
for i in *.bmp
do

	# Obtain the namefile
	cambiaext "$i"

	# Convert BMP file to JPG 
	convert -quality 90 -transparent-color white -flatten "$i" "$namefich"jpg

done 
