#!/usr/bin/perl

use strict;
use warnings;

my $file="script/BC_list_top_91776.txt";
open(FILE,"$file");
my $count=0;
while(my $BC1 = <FILE>)
{
	$count++;
        chomp $BC1;
	print "$count\t";
	my $BC2=$BC1;
#	print "\n$BC1";
	my @a = (1..4);
	my @b = (0..11);
	for my $p (@b){
		$BC1=$BC2;

		for my $n (@a){
			substr( $BC1, $_, 1 ) =~ tr[ACGT][CGTA] for $p;;
			print "$BC1\t";
			}
		}
	print "\n";
}
close (FILE)
