#!/usr/bin/perl

#This is a script for analysing spike-in controls in RNAseq data; 
# Usage: ./scriptname FILENAME.seq | cut -f 4,5 | sort | uniq -c > OUTPUTFILENAME.tsv


use strict; 
use warnings; 
my $file=$ARGV[0];
my $revcom="";
my $result="";
open F, "script/spikeins_1_no_MM.txt" or die "can't open spikeins_1_no_MM.txt\n"; #opens barcode file
my %code; 								#create an empty table 
my $n =0; 								#attribute a counter
while(<F>) 								#take each line of the file one by one
{
        chomp;
	$n ++; 								#counter, increment by 1
	my @line_info = split(/\t/, $_); 				#line will be split by tabulation 
	my $line_length = \@line_info;
									#print "Line length = $#$line_length\n";
									#print "$line_info[0]\t";
	my $i =0 ;
	for ( $i = 1; $i <= $#$line_length; $i++)
    {
	$code{$line_info[$i]} = $line_info[0];
									#print "$line_info[$i]\n";
    }
									#print "\n";

}
close F;
									#my $result = $code{"$BC"};
									#print "$result\n";
 
									#my $spike_BC = $ARGV[1]

open(FILE,"$file");
while(<FILE>)
	{
	my $SEQ = $_; chomp($SEQ);
	if ($SEQ =~ /ATAATGGTTACAAATAAAGCCCTA/)				#check for valid sequence in the GFP mRNA read
		{
		my @sub_seq=split (/ATAATGGTTACAAATAAAGCCCTA|CCTAAATAGCATCA/, $SEQ);	#split before|after BC
		my $frag_length = length($sub_seq[1]);
		if ($frag_length == 12) 						#corresponds to single BC 
			{
			$revcom = reverse $sub_seq[1];					#reverse compliment single BC
			$revcom =~ tr/ACGTacgt/TGCAtgca/;				# to make it compatible
			print "single_BC\t$revcom\t$sub_seq[1]\t"; 			# with the BC list 
			if (defined($code{"$revcom"})) { $result =$code{"$revcom"}; } else { $result= "not a spike-in"; }
				print "GFP\t$result\n"; 				#if the BC is spike-in, print GFP and type of spike-in;
			}								#else it is not a spike-in, prints message
		}
	if ($SEQ =~ /ATAATGGTTACAAATAAAGCTTCG/)						#check for valid sequence in the mCherry mRNA read
		{
		my @sub_seq=split (/ATAATGGTTACAAATAAAGCTTCG|TTCGAATAGCATCA/, $SEQ);	#split before|after BC
		my $frag_length = length($sub_seq[1]);
			if ($frag_length == 12) 
			{
			$revcom = reverse $sub_seq[1];
			$revcom =~ tr/ACGTacgt/TGCAtgca/;
			print "single_BC\t$revcom\t$sub_seq[1]\t"; 
			if (defined($code{"$revcom"})) { $result =$code{"$revcom"}; } else { $result= "not a spike-in"; }
				print "mCherry\t$result\n";
			}	
		}
	}
close(FILE);
