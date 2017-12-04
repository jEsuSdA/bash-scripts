#!/usr/bin/perl
# Bash Script for converting ALL the BMP image files to JPG
#
# Requires: mpg321 libmp3-info-per libstring-shellquote-perl  

# mp32wav, a modified version of mp32ogg to produce wav files easy.
# Generated WAV files have large size (+- 10MB per min, +- x10 of mp3 source file).

# Original Author: Nathan Walp <faceprint@faceprint.com>
# Modifications by: jEsuSdA <jesusda@ono.com>
# This software released under the terms of the Artistic License
# <http://www.opensource.org/licenses/artistic-license.html>

# version 1.2.0 by jEsuSdA.


$version = "v1.2.0";

use MP3::Info;
use File::Find ();
use File::Basename;
use Getopt::Long;
use String::ShellQuote;

use_winamp_genres();

$oggenc  = "/usr/bin/oggenc";
$ogginfo = "/usr/bin/ogginfo";
$mpg123  = "/usr/bin/mpg321";

print "mp32wav $version\n";
print "(c) 2000-2002 Nathan Walp\n";
print "(c) 2002-2005 jEsuSdA\n";
print "Released without warranty under the terms of the Artistic License\n\n";


GetOptions("help|?",\&showhelp,
		"delete", 
		"rename=s", 
		"lowercase",
		"no-replace",
		"verbose",
		"<>", \&checkfile);

sub showhelp() {
	print "Usage: $0 [options] dir1 dir2 file1 file2 ...\n\n";
	print "Options:\n";
	print "--delete                 Delete files after converting\n";
	print "--rename=format          Instead of simply replacing the .mp3 with\n";
	print "                         .ogg for the output file, produce output \n";
	print "                         filenames in this format, replacing %a, %t\n";
	print "                         and %l with artist, title, and album name\n";
	print "                         for the track\n";
	print "--lowercase              Force lowercase filenames when using --rename\n";
	print "--verbose		Verbose output\n";
	print "--help                   Display this help message\n";
	exit;

}

	


sub checkfile() {
	my $file = shift(@_);
	if(-d $file) {
		File::Find::find(\&findfunc, $file);
	}
	elsif (-f $file) {
		&ConvertFile($file);
	}
}

sub findfunc() {
	$file = $_;
	($name,$dir,$ext) = fileparse($file,'\.mp\d');
	if((/\.mp\d/,$ext) && -f $file) {
		&checkfile($file);
	}
}

sub ConvertFile() {
	my $mp3file = shift(@_);
	my $delete = $opt_delete;
	my $filename = $opt_rename;
	my $lowercase = $opt_lowercase;
	my $noreplace = $opt_no_replace;
	my $verbose = $opt_verbose;

	$info = get_mp3tag($mp3file);
	$fileinfo = get_mp3info($mp3file);

	$_ = $filename;

	my $channels = 2;	# default to stereo
	if ($fileinfo->{MODE} == 3) {
		$channels = 1;	# set to mono if single channel mode
	}
		
	my $frequency = ($fileinfo->{FREQUENCY}*1000);
	if ($frequency == 0) {
		$frequency = 44100;		# default to 44100
	}

	$mp3bitrate = $fileinfo->{BITRATE};
	if($mp3bitrate ne "") {
	   if($mp3bitrate > 256) {
	      $quality = 8;
	   } elsif($mp3bitrate > 192) {
	      $quality = 7;
	   } elsif($mp3bitrate > 128) {
	      $quality = 6;
	   } else {
	      $quality = 5;
	   }
	} else {
	   $quality = 5;
	   print "MP3::Info didn't report the bitrate... weird. Corrupt MP3 file? Bug?\n";
	}
	if($filename eq "" ||
		((/\%a/) && $info->{ARTIST} eq "") ||
		((/\%t/) && $info->{TITLE} eq "") ||
		((/\%l/) && $info->{ALBUM} eq "") ){

		if($filename ne "") {
			warn "not enough ID3 info to rename, reverting to old filename.\n";
		}

		($filename,$dirname,$ext) = fileparse($mp3file,'\.mp\d');
	}
	else {
		$filename =~ s/\%a/$info->{ARTIST}/g;
		$filename =~ s/\%t/$info->{TITLE}/g;
		$filename =~ s/\%l/$info->{ALBUM}/g;
		if($lowercase) {
			$filename = lc($filename);
		}
		if(!$noreplace) {
			$filename =~ s/[\[\]\(\)\{\}!\@#\$\%^&\*\~ ]/_/g;
			$filename =~ s/[\'\"]//g;
		}
		($name, $dir, $ext) = fileparse($filename, '.wav');
		$filename = "$dir$name";
		$dirname = dirname($mp3file);

	}

	$oggoutputfile = "$filename.wav";
	$newdir = dirname($oggoutputfile);

	# until i find a way to make perl's mkdir work like mkdir -p...
	system("mkdir -p $newdir");


	$infostring = "";
	
	print "Converting $mp3file to WAV...\n";
	if ($verbose) {
		print "Length: $fileinfo->{TIME}\t\tFreq: $fileinfo->{FREQUENCY} kHz\n";
		print "MP3 Bitrate: $mp3bitrate\tOGG Quality Level: $quality\n";

		print " Artist: $info->{ARTIST}\n";
		print "  Album: $info->{ALBUM}\n";
	        print "  Title: $info->{TITLE}\n";
	        print "   Year: $info->{YEAR}\n";
	        print "  Genre: $info->{GENRE}\n";
		print "Track #: $info->{TRACKNUM}\n";
		print "Comment: $info->{COMMENT}\n";
	}

	if($info->{ARTIST} ne "") {
		$infostring .= " --artist " . shell_quote($info->{ARTIST});
	}
	if($info->{ALBUM} ne "") {
		$infostring .= " --album " . shell_quote($info->{ALBUM});
	}
	if($info->{TITLE} ne "") {
		$infostring .= " --title " . shell_quote($info->{TITLE});
	}
	if($info->{TRACKNUM} ne "") {
		$infostring .= " --tracknum " . shell_quote($info->{TRACKNUM});
	}
	if($info->{YEAR} ne "") {
	   	$infostring .= " --date " . shell_quote($info->{YEAR});
	}
	if($info->{GENRE} ne "") {
	   	$infostring .= " --comment " . shell_quote("genre=$info->{GENRE}");
	}
	if($info->{COMMENT} ne "") {
		$infostring .= " --comment " . shell_quote("COMMENT=$info->{COMMENT}");
	}
	
	$infostring .= " --comment " . shell_quote("transcoded=mp3;$fileinfo->{BITRATE}");
		
	
	$oggoutputfile_escaped = shell_quote($oggoutputfile);
	$mp3file_escaped = shell_quote($mp3file);
	$result = system("$mpg123  $mp3file_escaped -w $oggoutputfile_escaped  2>/dev/null ");

	if(!$result) {
	   open(CHECK,"$ogginfo $oggoutputfile_escaped |");
	   while(<CHECK>)
	   {
	      if($_ eq "file_truncated=true\n")
	      {
		 warn "Conversion failed ($oggoutputfile truncated).\n";
		 close CHECK;
		 exit 1;
	      }
	      elsif($_ eq "header_integrity=fail\n")
	      {
		 warn "Conversion failed ($oggoutputfile header integrity check failed).\n";
		 close CHECK;
		 exit 1;
	      }
	      elsif($_ eq "stream_integrity=fail\n")
	      {
		 warn "Conversion failed ($oggoutputfile header integrity check failed).\n";
		 close CHECK;
		 exit 1;
	      }
	   }
	   close CHECK;
	   print "$oggoutputfile done!\n";
	   if($delete) {
	      unlink($mp3file);
	   }
	}
	else {
	   warn "Conversion failed ($oggenc returned $result).\n";
	   exit 1;
	}
}
