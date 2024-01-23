#!/usr/bin/perl

# add fragment ID to dashed data
# usage: ./assign_fragment_L_R.pl dash_database_L_and_R.tsv > fragment_data.tsv
# example: CTCF_alone_O_43_MPM_43  R       60491-86204     43      TGTGTGAAGTGTTGACCCCCCGGCGAATATTACTTACCCGCCTCGCCAAGTTTCGTTGTTTGCTGCATGTGGCGGCAGAAGTGCTCGTACTCGCCGCTAGATGGCTC-CGGCCATTCGATCGAAGGCAGCCATATTGATGTGGCCAT
# column content:
#	1) name of fragment
#	2) orientation L = "six-bc" at the left (GFP side), R at the right (OPI2)
#	3) double bc 
#	4) six-bc (to confirm that it corresponds to the one in the fragment name)
#	5) the "dashed" sequence

use strict;
use warnings;

my $file= $ARGV[0];



# create a hash table for barcode 

open G, "script/dash_database_L_and_R.tsv" or die "can't open dash_database_L_and_R.tsv\n";
my %code;
my $n =0;
while(<G>)
{
        chomp;
	$n ++;
	my @line_info = split(/\t/, $_);
	

	$code{$line_info[1]} = $line_info[0];

}
close G;



my $frag_ID = "";

open(FILE,"$file");
while(<FILE>)
	{
	my $SEQ = $_; chomp($SEQ);
	my @read = split (/\t/, $SEQ);
	if (defined($code{"$read[3]"})) { $frag_ID =$code{"$read[3]"}; } else { $frag_ID= "unknown"; }
	print "$frag_ID\t$read[0]\t$read[1]\t$read[2]\t$read[3]\n";

}






