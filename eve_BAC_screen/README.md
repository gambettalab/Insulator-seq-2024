# *eve* locus screen

## Usage

### Data preparation

Download sequencing data in fq.gz format DNA-seq and RNA-seq (replicate 1) from Gene Expression Omnibus (GEO, accession code [GSE253140](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE253140))

```         
wget https://ftp.ncbi.nlm.nih.gov/geo/name_from_GEO.fg.gz
wget https://ftp.ncbi.nlm.nih.gov/geo/name_from_GEO.fg.gz
wget https://ftp.ncbi.nlm.nih.gov/geo/name_from_GEO.fg.gz
wget https://ftp.ncbi.nlm.nih.gov/geo/name_from_GEO.fg.gz
```

Rename files to match the provided script

```         
mv name_from_GEO.fg.gz data/eve_DNA_seq_1.fq.gz
mv name_from_GEO.fg.gz data/eve_DNA_seq_2.fq.gz
mv name_from_GEO.fg.gz data/eve_RNA_rep1_L1_1.fq.gz
mv name_from_GEO.fg.gz data/eve_RNA_rep1_L2_1.fq.gz
```

Run the script or the commands one by one

`./BAC_screen.sh`

The result will be saved in the file `eve_Rep1_with_mCherry_eGFP_val.tsv` in the result folder.
