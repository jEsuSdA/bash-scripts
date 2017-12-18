#!/bin/bash
# Bash Script list broken symlinks in the folder passed as parameter.
#
# Requires: find
#
# 20171218 - jEsuSdA


if [ $# -eq 0 ]
then

	echo "Usage: find-broken-links.sh <folder url>"

else 

	find . -xtype l -print

fi
