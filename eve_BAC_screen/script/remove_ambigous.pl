#!/usr/bin/perl

use strict;
use warnings;

# This is the script that removes ambiguous BC from .bed files 
# Usage: ./remove_ambigous.pl file_to_clean.bed list_of_ambigous_barcodes.txt

my %code;
my $file=$ARGV[0];
my $ambiguoslist=$ARGV[1];

open(F,"$ambiguoslist");
while(<F>)
{
	chomp;
	$code{"$_"}++;
}
close F;

open(FILE,"$file");
while(<FILE>)
{
	chomp;
	my @field =split/\t/;
	my$chrom=$field[0];
	my$start_pos=$field[1];
	my$stop_pos=$field[2];
	my$BC=$field[3];
	if (defined($code{"$BC"})) {}else{print "$chrom\t$start_pos\t$stop_pos\t$BC\t$field[5]\n";}
	
}
