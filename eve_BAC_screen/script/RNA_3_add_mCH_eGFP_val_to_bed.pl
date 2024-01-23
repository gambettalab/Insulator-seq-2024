#!/usr/bin/perl
use strict;
use warnings;

# This is the script for adding mCherry and eGFP RNAseq read number to a pre-processed DNAseq cleaned bed file. 
# USAGE: ./scriptname.pl CLEANED_BED_FILE.bed RNAseq_scoresfile.tsv  > OUTPUTFILENAME.bed 

my $bedfile = $ARGV[0]; 
my $scorefile = $ARGV[1]; 


open S, $scorefile or die "score file not found\n";
my %GFP; 
my %mCherry;
my %score;
while(<S>) 
	{
	chomp;
	my @line = split(/\t/, $_);
	$GFP{$line[1]} = $line[3];	
	$mCherry{$line[1]} = $line[0];
	$score{$line[1]} = $line[6];
	}
close S;

open F, $bedfile or die "bed file not found\n";
while(<F>) 
	{
	chomp;
	my @field = split(/\t/, $_);
	my $GFP_val = 0; 
	my $mCherry_val = 0;
	my $score_val =0;
	if(defined($GFP{"$field[3]"})) 
		{
		$GFP_val=$GFP{"$field[3]"};
		$mCherry_val = $mCherry{"$field[3]"};
		$score_val = $score{"$field[3]"};
		#print "$insulation_score\n";
		print "$field[0]\t$field[1]\t$field[2]\t$field[3]\t$field[4]\t$mCherry_val\t$GFP_val\t$score_val\n";
		}			
	}
close F;
