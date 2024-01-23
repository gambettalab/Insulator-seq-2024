########## DNA-seq #########

# Unzip the files

gzip -dc data/Synthetic_DNA_seq_1.fq.gz |paste - - - - |cut -f 2 > result/DNA_seq_SI_1.seq 
gzip -dc data/Synthetic_DNA_seq_2.fq.gz |paste - - - - |cut -f 2 > result/DNA_seq_SI_2.seq 

#combine forward and reverse reads

paste result/DNA_seq_SI_1.seq result/DNA_seq_SI_2.seq > result/DNA_seq_SI.seq 

# Assign barcode ID, separate reads by orientation 

# Required files 
# six_bp.tsv
# BC_list_no_or_one_mm_index.txt


./script/split_L_R_orientation_dash.pl result/DNA_seq_SI.seq > result/SI_DNA_data_with_dash_L_R.tsv

# Assign fragment names 

# Required files 
# dash_database_L_and_R.tsv 


./script/assign_fragment_L_R.pl result/SI_DNA_data_with_dash_L_R.tsv |grep -v unknown > result/SI_DNA_frag_name.txt

# Remove PCR duplicates:  

sort result/SI_DNA_frag_name.txt | uniq > result/SI_DNA_PCR_dup_removed.txt 

# Find ambiguous barcodes: 

cut -f3 result/SI_DNA_PCR_dup_removed.txt | sort | uniq -d > result/list_amb_SI.txt 

# Remove ambiguous barcodes: 

grep -v -f result/list_amb_SI.txt result/SI_DNA_PCR_dup_removed.txt |cut -f 1-4 > result/SI_DNA_final.txt

########## RNA-seq #########

# Same as in eve RNA-seq with UMI

# Unzip the file 

gzip -dc data/Synthetic_RNA_seq_Rep1_L1_1.fq.gz | paste - - - - | cut -f 2 > result/Rep1_UMI_RNAseq.seq

# Assign barcode and gene ID for spike-in controls and make a count table

./script/RNA_1_Count_spikeins_UMI.pl result/Rep1_UMI_RNAseq.seq | cut -f 4,5,6 | sort | grep -v N | uniq | cut -f 1,2 | sort | uniq -c > result/Rep1_UMI_spikeins.tsv 

# Assign barcode and gene ID for experimental reads, count unique barcode-gene-UMI combinations: 

./script/RNA_1_attributeBC_UMI.pl result/Rep1_UMI_RNAseq.seq | grep -v N | sort | uniq | cut -f 1,2 | sort | uniq -c > result/Rep1_BC_UMI_count.txt

# Transform the count table to a tab-delimited file that combines paired by barcode mCherry and eGFP reads 
# on one line and calculated mCherry/eGFP ratio

./script/RNA_2_Count_BC.pl result/Rep1_BC_UMI_count.txt > result/Rep1_BC_with_ratio.txt 

################## Merging DNA and RNA seq data ################# 

./script/SI_screen_add_RNA_seq_val.pl result/SI_DNA_final.txt result/Rep1_BC_with_ratio.txt  > result/SI_Rep1_with_mCherry_eGFP_val.tsv 

