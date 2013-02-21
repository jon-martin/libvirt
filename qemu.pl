#! /usr/bin/perl

use strict;
use Getopt::Std;

my $opt_string = 'hn:';
my %opt;
my $NUMBER;

getopts("$opt_string", \%opt ) or usage();
usage() if $opt{h};

$NUMBER = $opt{'n'};

for (my $i; $i<$NUMBER; $i++){
	system("screen -d -m -S mm$i qemu-system-x86_64 -m 16 -hda mm1.hda -curses");	# Fix this line to create VM and write output somewhere
	print "$i\n";
}

sub usage(){
	print "helpmethod\n";
	exit 0;
}

exit 0;
