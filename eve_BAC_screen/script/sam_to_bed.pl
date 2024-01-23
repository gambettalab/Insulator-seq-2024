#!/usr/bin/perl

use strict;
use warnings;


my $file=$ARGV[0];
# my $chr=$ARGV[1];

open(FILE,"$file");
while(<FILE>)
{
	chomp;
	my $read1 = $_;
	my $read2 = <FILE>; chomp($read2);
	my @field1 =split(/\t/,$read1);
	my @field2 =split(/\t/,$read2);
	my @new_field = split (/\:/,$field1[2]);
	my $chr = $new_field[0];
	my @new_field2= split(/\-/,$new_field[1]);
	my $BAC_start=$new_field2[0];
	my $start_pos = ($field1[3], $field1[7])[$field1[3] > $field1[7]];
	$start_pos =$start_pos+ $BAC_start;
	my $second_pos = ($field1[3], $field1[7])[$field1[3] < $field1[7]];
	$second_pos = $second_pos + $BAC_start;
	my $stop_position = 0;
	my $strand = "-";
	if ($field1[1] == 83)
	{
		$stop_position =  $second_pos + 37 ;
		$strand = "-";
	}
	if ($field1[1] == 99)
	{
		$stop_position =  $second_pos + 108 ;
		$strand = "+";
	}
	print "$chr\t$start_pos\t$stop_position\t$field1[0]\t$strand\n";
	
}
close(FILE);
