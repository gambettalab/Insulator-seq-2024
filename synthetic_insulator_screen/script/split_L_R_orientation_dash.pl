#!/usr/bin/perl

use strict;
# use warnings;

# add barcode to sequence, make sequence compatible to the "dash" database
# expected sequence.file format : name <TAB> read1 <TAB> read2
# exemple: Fragment_2      GAAATTTGTGATGCTATTTAGGGTGGTAATCGGCTAGGTCAGTCCAAGCTTAGGGCTTTATTTGTAACCATTATAAGCTGCAATAAACAAGTTGTGTAAAACGACGGCCAGATGGCCACATCAATATGGCTGCCTTCGATCGAATGGCCG  CAGCATACATTGTTTATCATCATGGGTGTAAAACGACGGCCAGTGTGTGAAGTGTTGACCCCCCGGCGAATATTACTTACCCGCCTCGCCAAGTTTCGTTGTTTGCTGCATGTGGCGGCAGAAGTGCTCGTACTCGCCGCTAGATGGCTC  

# usage: ./split_L_R_orientation_dash.pl sequence.file > data_with_dash.tsv
# output: R       60491-86204     43      TGTGTGAAGTGTTGACCCCCCGGCGAATATTACTTACCCGCCTCGCCAAGTTTCGTTGTTTGCTGCATGTGGCGGCAGAAGTGCTCGTACTCGCCGCTAGATGGCTC-CGGCCATTCGATCGAAGGCAGCCATATTGATGTGGCCAT


my $file= $ARGV[0];

# create a hash for the 6bp barcode

open F, "script/six_bp.tsv" or die "can't open six_bp.tsv\n";

my %code_six;
my $n =0;
while(<F>)
{
	chomp;
	$n ++;

	$code_six{$_} = $n;
}


close F;

# create a hash table for the double barcode

open G, "script/BC_list_no_or_one_mm_index.txt" or die "can't open BC_list_no_or_one_mm_index.txt\n";
my %code;
$n =0;
while(<G>)
{
        chomp;
	$n ++;
	my @line_info = split(/\t/, $_);
	my $line_length = \@line_info;
	my $i =0 ;
	for ( $i = 1; $i <= $#$line_length; $i++)
    {
	$code{$line_info[$i]} = $line_info[0];
    }

}
close G;

open(FILE,"$file");
while(<FILE>)
	{
	my $SEQ = $_; chomp($SEQ);
	my @read = split (/\t/, $SEQ);
	if ($SEQ =~ /AATTTGTGATGCTATTTAGG/)						#check for valid sequence in the fwd read
		{
		my @sub_seq=split (/AATTTGTGATGCTATTTAGG/, $SEQ);	#split before double_BC
		my $frag_length = length($sub_seq[1]);
		my $barcode1  = substr($sub_seq[1],0,12);
		my $separator = substr($sub_seq[1],12,4);
		my $barcode2  = substr($sub_seq[1],16,12);
		if ($separator eq 'TAGG')							#check for valid separator
			{
			my $index1f = 0;								#assigne double_BC
			my $index2f = 0;
			if (defined($code{"$barcode1"})) { $index1f =$code{"$barcode1"}; } else { $index1f= 0; }
			if (defined($code{"$barcode2"})) { $index2f =$code{"$barcode2"}; } else { $index2f= 0; } 
			if ( ($index1f != 0 ) & ($index2f != 0)) 
				{
				if (($read[0] =~ /TGTAAAACGACGGCCAG/) and ($read[1] =~ /TGTAAAACGACGGCCAG/))
					{									#assigne BC_six
					my @Nread = split (/GTAAAACGACGGCCAG/ , $read[0]);	#split before BC_six ($read[0] for real reads)
					my @Pread = split (/GTAAAACGACGGCCAG/ , $read[1]);	#split before BC_six ($read[1] for real reads)
					my $barcodeN  = substr($Nread[1],0,6);
					my $barcodeP  = substr($Pread[1],0,6);
					my $indexN = 0;
					my $indexP = 0;

					if (defined($code_six{"$barcodeN"})) { $indexN =$code_six{"$barcodeN"}; } else { $indexN= 0; }
					if (defined($code_six{"$barcodeP"})) { $indexP =$code_six{"$barcodeP"}; } else { $indexP= 0; } 
					if ( ($indexN != 0 ) & ($indexP != 0)) 
						{
						my $revcP = reverse $Pread[1];
						$revcP=~ tr/ACGTacgt/TGCAtgca/;
						print "L\t$index1f\-$index2f\t$indexN\t$Nread[1]\-$revcP\n";
						my $revcN = reverse $Nread[1];
						$revcN=~ tr/ACGTacgt/TGCAtgca/;
						print "R\t$index1f\-$index2f\t$indexP\t$Pread[1]\-$revcN\n";
						}
					else
						{
						if ($indexN != 0 )
							{
							my $revcP = reverse $Pread[1];
							$revcP=~ tr/ACGTacgt/TGCAtgca/;
							print "L\t$index1f\-$index2f\t$indexN\t$Nread[1]\-$revcP\n";
							}
						if ($indexP != 0 )
							{
							my $revcN = reverse $Nread[1];
							$revcN=~ tr/ACGTacgt/TGCAtgca/;
							print "R\t$index1f\-$index2f\t$indexP\t$Pread[1]\-$revcN\n";
							}
						}
					}

				}
			}

		
		
	}
}






