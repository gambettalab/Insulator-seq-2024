#!/usr/bin/perl

use strict;
use warnings;

my $strand=$ARGV[0];
my $file=$ARGV[1];

open(FILE,"$file");
while(<FILE>)
{
	chomp;
	my @fields=split/\t/;
	if ($strand eq "fwd")
		{
		print ">$fields[0]\n$fields[1]\n"
		}
	else
		{
		print ">$fields[0]\n$fields[2]\n"
		}
}
close FILE;
