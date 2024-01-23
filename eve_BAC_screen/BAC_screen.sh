#!/bin/bash

########## DNA-seq #########
# Unzip the files

gzip -dc data/eve_DNA_seq_1.fq.gz |paste - - - - |cut -f 2 > result/DNAseq/eve_DNA_seq_R1_1.seq 
gzip -dc data/eve_DNA_seq_2.fq.gz |paste - - - - |cut -f 2 > result/DNAseq/eve_DNA_seq_R1_2.seq

#combine forward and reverse reads

paste result/DNAseq/eve_DNA_seq_R1_1.seq result/DNAseq/eve_DNA_seq_R1_2.seq > result/DNAseq/eve_DNA_seq_R1.seq

# Assign barcode ID 

./script/extract_genomic_seq.pl result/DNAseq/eve_DNA_seq_R1.seq > result/DNAseq/eve_DNA_seq_R1_genomic.seq 

# Convert into .fasta format (keep forward and reverse reads separate)

./script/seq_to_fa.pl fwd result/DNAseq/eve_DNA_seq_R1_genomic.seq  > result/DNAseq/eve_DNA_seq_R1_genomic_1.fa 
./script/seq_to_fa.pl rev result/DNAseq/eve_DNA_seq_R1_genomic.seq  > result/DNAseq/eve_DNA_seq_R1_genomic_2.fa 

# Map on the ref genome 

bowtie2 --threads 10 -f -I 100 -X 900 --no-mixed  --no-unal --no-discordant -x genome/eve_bac -1 result/DNAseq/eve_DNA_seq_R1_genomic_1.fa -2 result/DNAseq/eve_DNA_seq_R1_genomic_2.fa -S result/DNAseq/eve_DNA_seq_R1_pair_no_mix_unal_dis.sam 

# remove .sam file's header 

grep "@" -v  result/DNAseq/eve_DNA_seq_R1_pair_no_mix_unal_dis.sam >  result/DNAseq/eve_DNA_seq_R1_pair_no_mix_unal_dis.sam.tsv 

# Convert sam to bed

./script/sam_to_bed.pl  result/DNAseq/eve_DNA_seq_R1_pair_no_mix_unal_dis.sam.tsv > result/DNAseq/eve_mapped_DNA_R1.bed 

# Remove PCR multiplicates

sort -k 4,4 result/DNAseq/eve_mapped_DNA_R1.bed |uniq > result/DNAseq/eve_mapped_DNA_R1_uniq.bed 

# Filter for ambiguous barcodes (seen with multiple genomic fragments)

./script/filter_frag.pl result/DNAseq/eve_mapped_DNA_R1_uniq.bed > result/DNAseq/eve_DNA_R1_OK_amb.bed 

# Create a list of ambiguous barcodes

./script/filter_frag.pl result/DNAseq/eve_mapped_DNA_R1_uniq.bed |grep "ambigous" | cut -f 4 |uniq > result/DNAseq/eve_DNA_R1_amb_list.txt 

# Remove the ambiguous barcodes from the final data
./script/remove_ambigous.pl result/DNAseq/eve_DNA_R1_OK_amb.bed result/DNAseq/eve_DNA_R1_amb_list.txt > result/DNAseq/eve_DNA_R1_clean.bed 

############# RNAseq without UMI #############


# Assign barcode and gene ID for spike-in controls and make a count table

./script/RNA_1_Count_spikeins.pl data/eve_Rep1_RNAseq.seq |cut -f 4,5 | sort  | uniq -c > result/RNAseq/eve_spikein_R1.tsv

# Assign barcode and gene ID for experimental reads, count unique gene-barcode combinations 

./script/RNA_1_attributeBC.pl data/eve_Rep1_RNAseq.seq | sort | uniq -c > result/RNAseq/eve_Rep1_RNAseq_count_sorted.txt  

# Transform the count table to a tab-delimited file that combines paired by barcode mCherry and eGFP reads 
# on one line and calculated mCherry/eGFP ratio

./script/RNA_2_Count_BC.pl result/RNAseq/eve_Rep1_RNAseq_count_sorted.txt > result/RNAseq/eve_Rep1_RNAseq_final.tsv 

############## RNA-seq with UMI ###################### 

# Unzip the file 

gzip -dc data/eve_RNA_rep1_L1_1.fq.gz |paste - - - - |cut -f 2 > data/eve_Rep1_RNAseq.seq
gzip -dc data/eve_RNA_rep1_L2_1.fq.gz |paste - - - - |cut -f 2 >> data/eve_Rep1_RNAseq.seq


# Assign barcode and gene ID for spike-in controls and make a count table

./script/RNA_1_Count_spikeins_UMI.pl data/eve_Rep1_RNAseq.seq | cut -f 4,5,6 | sort | grep -v N | uniq | cut -f 1,2 | sort | uniq -c > result/RNAseq/eve_Rep1_UMI_spikeins.tsv 

# Assign barcode and gene ID for experimental reads, count unique barcode-gene-UMI combinations: 

./script/RNA_1_attributeBC_UMI.pl data/eve_Rep1_RNAseq.seq | grep -v N | sort | uniq | cut -f 1,2 | sort | uniq -c > result/RNAseq/eve_Rep1_BC_UMI_count.txt

# Transform the count table to a tab-delimited file that combines paired by barcode mCherry and eGFP reads 
# on one line and calculated mCherry/eGFP ratio

./script/RNA_2_Count_BC.pl result/RNAseq/eve_Rep1_BC_UMI_count.txt > result/RNAseq/eve_Rep1_UMI_BC_with_ratio.txt 

################## Merging DNA and RNA seq data ################# 

./script/RNA_3_add_mCH_eGFP_val_to_bed.pl result/DNAseq/eve_DNA_R1_clean.bed  result/RNAseq/eve_Rep1_UMI_BC_with_ratio.txt  > result/eve_Rep1_with_mCherry_eGFP_val.tsv 


