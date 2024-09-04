library(BSgenome.Dmelanogaster.UCSC.dm6)
library(SingleMoleculeFootprinting)
library(rtracklayer)
library(parallel)
library(data.table)
library(ggplot2)


# Usage:  Rscript SMF_prepare_data.R config/SRRnnnnnnn_Qinput.tsv
args <- commandArgs(trailingOnly = TRUE)
Qinput <- args[1]
stopifnot(!is.na(Qinput))

cl <- makeCluster(2)
cacheDir <- paste0(getwd(), "/data/Bisulfite-Seq/bam", tempdir())
suppressWarnings(dir.create(cacheDir, recursive=TRUE))
prj <- QuasR::qAlign(sampleFile = Qinput,
  genome = "BSgenome.Dmelanogaster.UCSC.dm6",
  aligner = "Rbowtie",
  projectName = "prj",
  paired = "fr",
  bisulfite = "undir",
  alignmentsDir = paste0(getwd(), "/data/Bisulfite-Seq/bam"),
  alignmentParameter = "-e 70 -X 1000 -k 2 --best --strata",
  cacheDir = cacheDir,
  clObj = cl)

# ConversionRateValue <- ConversionRate(sampleSheet = Qinput,
#   genome = BSgenome.Dmelanogaster.UCSC.dm6,
#   chr = "chr4")
# print(ConversionRateValue)
