#!/usr/bin/perl

use strict;
use warnings;


my $file=$ARGV[0];

my $BC_o="";
my $BC="";
my $chrom_o="";
my $chrom="";
my $start_pos_o=0;
my $start_pos=0;
my $stop_pos_0=0;
my $stop_pos=0;

open(FILE,"$file");
while(<FILE>)
{
	chomp;
	my @field =split/\t/;
	$chrom=$field[0];
	$start_pos=$field[1];
	$stop_pos=$field[2];
	$BC=$field[3];
	if ($BC ne $BC_o)
		{
		print "$chrom\t$start_pos\t$stop_pos\t$BC\tOK\t$field[4]\n";
		$chrom_o=$chrom;
		$start_pos_o=$start_pos;
		$stop_pos_0=$stop_pos;
		$BC_o = $BC;
		}
	else
		{
		my $start_dist = abs($start_pos-$start_pos_o);
		my $stop_dist = abs($stop_pos-$stop_pos);
		if (($start_dist > 50 ) or ($stop_dist > 50))
			{
			print "$chrom\t$start_pos\t$stop_pos\t$BC\tambigous\t$field[4]\n";
			}
		}

	
}

	
	
