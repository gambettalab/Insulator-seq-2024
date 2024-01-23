#!/usr/bin/perl

#*** THIS IS A SCRIPT USED FOR ANALYSING RNASEQ DATA: LINKING THE BARCODE ID WITH RNA SEQUENCING READS*** 
#VERSION: 0.2 modified 18.01.2022 by Nana 
#USAGE:  RNA_1_attributeBC_UMI.pl FILENAME.seq > OUTPUTFILENAME.seq  | FILENAME.seq contains sequencing reads/n
# File that contains a list of barcodes, allowing 1 or no mismatches should be present in working directory under name BC_list_no_or_one_mm_index.txt
# After running the script, sort the OUTPUTFILENAME.seq like :
# sort  OUTPUTFILENAME.seq | uniq -c > sorted_OUTPUT.seq
#


use strict; 
use warnings; 

my $file= $ARGV[0]; #attribute file name to the variable 
my $rev_comp_seq="";
my $gene="";
# PART ONE - CREATING TABLE FOR BARCODES
open F, "script/BC_list_no_or_one_mm_index.txt" or die "can't open BC_list_no_or_one_mm_index.txt\n"; #opens barcode file
my %code; #create an empty table 
my $n =0; #attribute a counter
while(<F>) #take each line of the file one by one
{
        chomp;
	$n ++; #counter, increment by 1
	my @line_info = split(/\t/, $_); #line will be split by tabulation 
	my $line_length = \@line_info;
#	print "Line length = $#$line_length\n";
#	print "$line_info[0]\t";
	my $i =0 ;
	for ( $i = 1; $i <= $#$line_length; $i++)
    {
	$code{$line_info[$i]} = $line_info[0];
#	print "$line_info[$i]\n";
    }
#	print "\n";

}
close F;

#Part two - separating mCherry and GFP reads by TAGG and CGAA identifying sequences
my $tot_seq = 0;
my $valid_sequ = 0;
my $right_length = 0;
my $valid_BC = 0;
my $GFP_sep = 0;
my $mcherry_sep = 0;
open(FILE,"$file"); 
while(<FILE>)
	{
	$tot_seq ++ ;
	my $SEQ = $_; #<FILE>; #chomp($SEQ);
	my $UMI = substr($SEQ, 0, 8);
#	if ($SEQ =~ /ATAATGGTTACAAATAAAGC/)
	if ($SEQ =~ /GGTTACAAATAAAGC/)						#check for valid sequence in the fwd read
		{
		$valid_sequ ++;
#		my @sub_seq=split (/ATAATGGTTACAAATAAAGC|AATAGCATCA/, $SEQ);
		my @sub_seq=split (/GGTTACAAATAAAGC|AATAGCATCA/, $SEQ);	
		my $frag_length = length($sub_seq[1]);
		if ($frag_length == 36) 								
			{
			$right_length ++;
			$rev_comp_seq = reverse $sub_seq[1];
			$rev_comp_seq =~ tr/ACGTacgt/TGCAtgca/;	
			my $separator1  = substr($rev_comp_seq,0,4);
			my $barcode1 = substr($rev_comp_seq,4,12); 
			my $separator2  = substr($rev_comp_seq,16,4); 	
			my $barcode2 = substr($rev_comp_seq,20,12);
			my $separator3  = substr($rev_comp_seq,32,4);
				if (($separator1 eq $separator2) && ($separator2 eq'TAGG'))
				{$gene ='GFP';$GFP_sep ++;}
				if (($separator1 eq $separator2) && ($separator2 eq 'CGAA'))
				{$gene ='mCherry';$mcherry_sep ++;}			
# Attribute BC indexes to the barcodes				
				my $index1f = 0;
				my $index2f = 0;
				if (defined($code{"$barcode1"})) { $index1f =$code{"$barcode1"}; } else { $index1f= 0; } 
				# ^ if the first barcode in seq file matches with indexed barcodes from the list, record its index
				if (defined($code{"$barcode2"})) { $index2f =$code{"$barcode2"}; } else { $index2f= 0; } #same as above but for second barcode
				if ( ($index1f != 0 ) & ($index2f != 0)) #if both barcodes are attributed fron the index table
				{print "$index1f\-$index2f\t$gene\t$UMI\n"}
				{$valid_BC ++;}
			}
		}
	}
#print "Total_seq\t$tot_seq\n";
#print "Valid_seq\t$valid_sequ\n";
#print "Right-size\t$right_length\n";
#print "GFP_sep\t$GFP_sep\n";
#print "mCherry_sep\t$mcherry_sep\n";
#my $tot_BC = $GFP_sep + $mcherry_sep;
#print "Scanned_BC\t$tot_BC\n";
#print "Indexed_BC\t$valid_BC\n";
		
