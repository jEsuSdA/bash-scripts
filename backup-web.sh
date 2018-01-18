#!/bin/bash
# Bash Script for making a website backup (only files)
#
# Requires: wget p7zip
#
# 20180118 - jEsuSdA

# Edit these vars and 
# put your site connection data:
SITENAME="myweb"
SITEURL="myweb.com/htdocs/" # The ftp URL
USER="ftp-user"
PASS="ftp-password"





# Some script vars. Do not change them.
DATE=`date +%Y%m%d`
OUTPUT="$SITENAME-$DATE"
REMOTE="--user=$USER --password=$PASS ftp://$SITEURL"

# Create backup directory
mkdir $OUTPUT
cd $OUTPUT

# Get the entire site files
wget -m $REMOTE

# Compress the files
cd ..
7za a -mx=9 "$OUTPUT".7z "$OUTPUT"

# Clean files and exit
rm -rf "$OUTPUT"
exit 

