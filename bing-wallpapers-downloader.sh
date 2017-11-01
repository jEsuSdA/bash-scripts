#!/bin/bash
# Bash Script for downloading bing wallpapers
#
# 201701101 - jEsuSdA


# starting index
index=0
end=8
size="1920x1200"


while [  $index -lt $end ]; do

	# Get the XML file with the wallpaper info.
	wget "http://www.bing.com/HPImageArchive.aspx?&idx=$index&mkt=en-US&n=1" -O out.txt

	# Extract the partial url where the wallpaper are stored.
	url=`cat out.txt | grep -oPm1 "(?<=<url>)[^<]+"`
	
	# Change the URL to get the 1920x1200px wallpaper
	url=`echo ${url//"1366x768"/$size}`

	# Download the wallpaper.
	wget "http://www.bing.com$url"

	# Delete the XML temp file.
	rm out.txt

	# update index
	let index=index+1

done
