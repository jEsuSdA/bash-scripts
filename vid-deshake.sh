#!/bin/bash
# Bash Script for deshaking a videofile
#
# Requires: ffmpeg
#
# 20171119 - jEsuSdA


# Function to obtain the filename without extension
# e.g:
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


# ----------------------------------------------------------
# The FFMPEG VIDSATAB way
#
# More info at: https://github.com/georgmartius/vid.stab



# Obtain the namefile
cambiaext "$1"



ffmpeg -i "$1" -vf vidstabdetect=shakiness=10:accuracy=15:result="mytransforms.trf" -f null -



ffmpeg -i "$1" -vf unsharp=5:5:0.8:3:3:0.4,vidstabtransform=zoom=5:smoothing=30:input="mytransforms.trf" "$namefich"stabilized.mkv

rm -rf "mytransforms.trf"


done

# ----------------------------------------------------------
# Old way with transcode (does not work at all now)

#transcode -J stabilize=shakiness=8=mincontrast=0.04=fieldsize=60 -i "$1"
#transcode -J transform=crop=1=optzoom=4 --mplayer_probe -i "$1" -y raw -o "$1""-stabilized.avi"

# info:
# http://www.transcoding.org/transcode?Filter_Plugins/Filter_Stabilize
# http://www.transcoding.org/transcode?Filter_Plugins

# http://isenmann.wordpress.com/2011/03/22/deshaking-videos-with-linux/
# http://public.hronopik.de/vid.stab/features.php?lang=en

# http://blog.hamoid.com/stabilize-video-in-ubuntu-linux
# http://mcfrisk.kapsi.fi/linux/video/#index2h2


