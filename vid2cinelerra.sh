#!/bin/bash
# Bash Script for creating a MJPEG low compressed videofile
# That kind of video is very convenient to be included in Cinelerra Projects
#
# Requires: ffmpeg
#
# 20171207 - jEsuSdA


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

	echo "Usage: vid2cinelerra.sh <video to convert>"

else 

	origen="$1"
	cambiaext "$1"
	vidout=$namefich"avi"

	ffmpeg -y -i "$origen" -vcodec mjpeg -qscale 1 -acodec pcm_s16le "$vidout"

fi
