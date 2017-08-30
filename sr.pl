#!/usr/bin/env perl
#
# Copyright (c) P. Lutus Ashland, Oregon lutusp@arachnoid.com
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#	* Redistributions of source code must retain the above copyright
#	notice, this list of conditions and the following disclaimer.
#	* Redistributions in binary form must reproduce the above copyright
#	notice, this list of conditions and the following disclaimer in the
#	documentation and/or other materials provided with the distribution.
#	* Neither the name of the <organization> nor the
#	names of its contributors may be used to endorse or promote products
#	derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#
# History:
# 0.1		1996-05-30		First Release			P. Lutus Ashland,
# 0.2		2001-05-27		Addded the -d option	Luc Suryo <luc@badassops.com>
#							Added FreeBSD license
#							more info in the 'help section'

use POSIX qw(strftime);

$_program	= (split /\//, $0)[-1];
$_author	= 'P. Lutus Ashland';
$_now_year	= strftime "%Y", localtime;
$_copyright = "Copyright 1996 - $_now_year (c) P. Lutus Ashland";
$_license	= 'License BSD, http://www.freebsd.org/copyright/freebsd-license.html';
$_version	= '0.2';
$_email		= 'lutusp@arachnoid.com';
$_summary	= "Search and Replace string";
$_info		= "$_program $_version\n$_copyright\n$_license\n\nWritten by $_author <$_email>\n$_summary\n";

if($#ARGV < 2) {
	print "$_info\n";
	print "usage: srchstr replstr file...file (replaces originals in place)\n";
	print "\talternate: -d srchstr file...file to delete search string\n";
	print "\talternate: -c file...file for console input of search and replace strings\n";

	print "\nNotes:\n\t - A single file name can specify many files using wildcard characters.\n";
	print "\t - This script processes text files, finds and replaces arbitrary strings\n";
	print "\t   Be careful with this script - it accepts wildcards and processes every text file\n";
	print "\t   that meets the wildcard criteria. This could be a catastrophe in the hands of the unwary.\n";
	exit(1);
}

if($ARGV[0] eq "-c") {
	# Interactive mode
	shift(@ARGV);
	print "Enter Search String:";
	$srchstr = <STDIN>;
	chop $srchstr;
	print "Enter Replace String:";
	$replstr = <STDIN>;
	chop $replstr;

} elsif ($ARGV[0] eq "-d") {
	# delete string mode
	$srchstr = $ARGV[1];
	$replstr = '';
	shift(@ARGV);

} else {
	# search and replace string mode
	$srchstr = $ARGV[0];
	$replstr = $ARGV[1];
	shift(@ARGV);
	shift(@ARGV);
}

$totrep = 0;
$totfil = 0;
foreach $filename (@ARGV) {
	if(-T $filename) {
		$totrep += &process($filename);
		$totfil++;
	}
}

print "$totfil files, $totrep replacements\n";
exit(0);

sub process {
	$fn = $_[0];
	undef $/; # so we can grab the entire file at once
	print STDERR "$fn"; # show current file name
	open (INFILE,$fn);
	$q = <INFILE>;
	close INFILE;

	$/ = "\n"; # restore default
	$sum = 0; # force numeric interpretation of this variable
	$sum = ($q =~ s/$srchstr/$replstr/g); # case-insensitive and global

	if($sum > 0) { # no point replacing file that isn't changed
		open (OUTFILE,">$fn");
		print OUTFILE $q;
		close OUTFILE;
		print " $sum replacement(s)";
	}
	print "\n";
	return $sum;
} # sub process
