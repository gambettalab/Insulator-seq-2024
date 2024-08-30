#!/usr/bin/perl

# script to generate motif point mutation in CTCF fragments
# need to have six_bp.tsv and WT_CTCF_seq_190.txt files in the same directory



use strict;
use warnings;


# Oligo sequences to add 5' and 3' of the test fragment for PCR amplification

my $m13fw="TGTAAAACGACGGCCAG"; # m13 oligo sequence
my $m13rv="CTGGCCGTCGTTTTACA"; # m13 reverse complement oligo sequence



# create a hash table with the 6nt barcodes indexed 1 to 76 
#(for barcodes created with DNABarcodes)

open BC, "six_bp.tsv" or die "can't open six_bp.tsv\n";
my $i =0;
my %BC;									# create an empty hash for barcode

while(<BC>)
{
	chomp;
	$i++;								# index 
	my @line_info = split(/\t/, $_); 	# get barcode sequence
	$BC{$i}=$line_info[0];				# attrubute index to barcode and save in the hash $BC
}

close BC;

open FRAG, "WT_CTCF_seq_190.txt" or die "can't open WT_CTCF_seq_190.txt";
# WT_CTCF_seq_190.txt contains wild-type sequences of the fragments to mutate

$i=0;			
while (<FRAG>)

	{
	chomp;
	$i++;		# fragment number
	my @line_info = split(/\t/, $_);
	my @name = split(/:/, $line_info[0]);
	my $test_frag =$line_info[1];
	my $n=0;	# bp position in the sequence 
	my $k=0;	# mutant number
	for ($n =85; $n<=104;$n +=1) # $n: start position of 10 nt to substitute
		{
		my $new_frag1 = $test_frag;
		my $new_frag2 = $test_frag;
		my $new_frag3 = $test_frag;
		substr( $new_frag1, $n, 1 ) =~ tr[ACGT][CGTA] ; # mutate to next nucleotide
		substr( $new_frag2, $n, 1 ) =~ tr[ACGT][GTAC] ;
		substr( $new_frag3, $n, 1 ) =~ tr[ACGT][TACG] ;
		$k++;
		print "$name[0]\_$k\_MPM\_$k\t$m13fw$BC{$k}$new_frag1$m13rv\t1\n";
		$k++;
		print "$name[0]\_$k\_MPM\_$k\t$m13fw$BC{$k}$new_frag2$m13rv\t1\n";	
		$k++;
		print "$name[0]\_$k\_MPM\_$k\t$m13fw$BC{$k}$new_frag3$m13rv\t1\n";
		}
	}

