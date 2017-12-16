#!/bin/bash
# Bash Script for convert a video to a MP4+AVC+ACC 1920x1080p videofile
# That kind of video is very convenient to be uploaded to Youtube or any
# any other websites.
#
# Requires: ffmpeg
#
# 20171216 - jEsuSdA


# **************************************************************************
# Esta función recibe en $1 un nombre de fichero
# Devuelve en namefich ese mismo nombre pero sin extension.
# ejemplo:
#	cambiaext pepito.grillo.avi
#	namefich=pepito.grillo.

function cambiaext {
    str=$1
    ext=`echo ${str:(-5)} | cut -d . -f 2`
    len_ext=${#ext}
    len_cad=${#str}
    titulo=$[len_cad-len_ext]
    namefich=${str:0:($titulo)}
}



if [ $# -eq 0 ]
then

	echo "Usage: vid2youtube-720p.sh <video to convert>"

else 

	origen="$1"
	cambiaext "$1"
	vidout=$namefich"1080p.mp4"

	ffmpeg -i "$origen" -crf 25.0 -vcodec libx264 -preset slower -acodec aac -ar 48000 -ab 160k -coder 1 -flags +loop -cmp +chroma -partitions +parti4x4+partp8x8+partb8x8 -me_method hex -subq 6 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -b_strategy 1 -threads 0  -filter:v scale=1920:1080 "$vidout"


fi
