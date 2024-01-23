#!/usr/bin/perl

use strict;
use warnings;

my $file= $ARGV[0];

# create a hash table for barcode

open F, "script/BC_list_no_or_one_mm_index.txt" or die "can't open BC_list_no_or_one_mm_index.txt\n";
my %code;
my $n =0;
while(<F>)
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
close F;

open(FILE,"$file");
while(<FILE>)
	{
	my $SEQ = $_; chomp($SEQ);
	if ($SEQ =~ /AATTTGTGATGCTATTTAGG/)				#check for valid sequence in the fwd read
		{
		my @sub_seq=split (/AATTTGTGATGCTATTTAGG/, $SEQ);	#split before BC
		my $frag_length = length($sub_seq[1]);
		if ($frag_length > 30)
			{
			my $barcode1  = substr($sub_seq[1],0,12);
			my $separator = substr($sub_seq[1],12,4);
			my $barcode2  = substr($sub_seq[1],16,12);
			if ($separator eq 'TAGG')
				{
				my $index1f = 0;
				my $index2f = 0;
				if (defined($code{"$barcode1"})) { $index1f =$code{"$barcode1"}; } else { $index1f= 0; }
				if (defined($code{"$barcode2"})) { $index2f =$code{"$barcode2"}; } else { $index2f= 0; } 
				if ( ($index1f != 0 ) & ($index2f != 0)) 
					{
					my @rev_read = split (/\t/, $SEQ);
					my $gen_seq_fwd = substr($rev_read[0],-37);
					my $gen_seq_rev = substr($rev_read[1],42);
					print "$index1f\-$index2f\t$gen_seq_fwd\t$gen_seq_rev\n";
					}
				}
			}
		}
	}

close FILE;

