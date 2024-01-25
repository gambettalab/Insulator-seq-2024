# Synthetic insulator screen

## Usage

### Data preparation

Download sequencing data in fq.gz format DNA-seq and RNA-seq (replicate 1) from Gene Expression Omnibus (GEO, accession code [GSE253140](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE253140))

```         
wget https://ftp.ncbi.nlm.nih.gov/geo/name_from_GEO.fg.gz
wget https://ftp.ncbi.nlm.nih.gov/geo/name_from_GEO.fg.gz
wget https://ftp.ncbi.nlm.nih.gov/geo/name_from_GEO.fg.gz
```

Rename files to match the provided script

```         
mv name_from_GEO.fg.gz data/Synthetic_DNA_seq_1.fq.gz
mv name_from_GEO.fg.gz data/Synthetic_DNA_seq_2.fq.gz
mv name_from_GEO.fg.gz data/Synthetic_RNA_seq_Rep1_L1_1.fq.gz
```

Run the script or the commands one by one

`./Synthetic_screen.sh`

The result will be saved in the file `SI_Rep1_with_mCherry_eGFP_val.tsv` in the result folder.
