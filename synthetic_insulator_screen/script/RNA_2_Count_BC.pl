#!/usr/bin/perl

#*** THIS IS A SCRIPT USED FOR ANALYSING RNASEQ DATA: COUNTING BARCODE READS IN EGFP AND MCHERRY*** 
#VERSION: 0.2 commented 19.01.2022 by Nana 
#USAGE: SCRIPTNAME.pl FILENAME.tsv > OUTPUTFILENAME.tsv  | FILENAME.seq contains sorted output of RNAseq reads with attributed barcodes;


use strict; 
use warnings; 

my $file= $ARGV[0]; 
my $gene = "";
my $gene_o = "";
my $BC_pair = "";
my $BC_pair_o = "";
my $read_number = 0;
my $read_number_o = 0;
my $minimum = 3;
open(FILE,"$file"); 
while(<FILE>)
	{ 
	#chomp;
	my @fields=split(/\s+/, $_);
	$fields[0]=~ s/^\t//;
	$read_number = $fields[1];
	$BC_pair = $fields[2];
	$gene = $fields[3];
	if ($BC_pair eq $BC_pair_o) 
		{
		if ($gene_o eq "GFP")
			{
			if(($read_number >= $minimum) &($read_number_o >= $minimum))
				{		
				my $ratio = $read_number/$read_number_o;
				print"$read_number\t$BC_pair\t$gene\t$read_number_o\t$BC_pair_o\t$gene_o\t$ratio\n";
				}
			}		
			  			
		
		}
		$BC_pair_o = $BC_pair; 
		$read_number_o = $read_number;
		$gene_o =$gene;

	}

