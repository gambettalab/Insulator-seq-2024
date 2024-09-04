library(BSgenome.Dmelanogaster.UCSC.dm6)
library(SingleMoleculeFootprinting)
library(rtracklayer)
library(parallel)
library(data.table)
library(ggplot2)


TFBSs <- import.gff("results/CTCF_binding/GSM1015410_Ct-CTCF_peaks_dm6.fa/fimo.gff")
TFBSs <- TFBSs[TFBSs$Name == "MA0531.1"]
TFBSs$peak_id <- seqnames(TFBSs)
offset <- as.integer(sapply(strsplit(
  sapply(strsplit(as.character(seqnames(TFBSs)), ":"), "[", 2), "-"), "[", 1))
end(TFBSs) <- end(TFBSs) + offset - 1L
start(TFBSs) <- start(TFBSs) + offset - 1L
new_seqnames <- sapply(strsplit(as.character(seqnames(TFBSs)), ":"), "[", 1)
TFBSs@seqnames <- Rle(factor(new_seqnames, seqnames(BSgenome.Dmelanogaster.UCSC.dm6)))
TFBSs@seqinfo <- seqinfo(BSgenome.Dmelanogaster.UCSC.dm6)
strand(TFBSs) <- "*" # note: this avoids a bug caused by sort(TFBS) in SingleMoleculeFootprinting::SortReads; default sort order of GenomicRanges is by seqnames, strand(!), start, end

tp <- table(TFBSs$peak_id)
double_motif_peaks <- names(tp[tp == 2])
double_TFBSs <- TFBSs[TFBSs$peak_id %in% double_motif_peaks]

dt <- as.data.table(double_TFBSs)
setkey(dt, seqnames, start, strand)
spacings_dt <- dt[, list(seqnames = seqnames[1], start = start[1], end = end[2], spacing = start[2] - end[1] - 1L), by = "peak_id"]
spacings_dt <- spacings_dt[spacing >= 0, ]
setkey(spacings_dt, spacing)
spacings_gr <- GRanges(spacings_dt)
spacings_gr <- resize(spacings_gr, 200, fix = "center")


Qinput_bam <- "config/SRR3133326-9_Qinput_bam.tsv"
MySample <- suppressMessages(readr::read_delim(Qinput_bam, delim = "\t")[[2]])


myPlotSM <- function (MethSM, range, SortedReads = NULL)
{
  # MethSM_HC = HierarchicalClustering(MethSM)
  if (nrow(MethSM) > 500) {
      MethSM_subset = MethSM[sample(dimnames(MethSM)[[1]],
          500), ]
  }
  else {
      MethSM_subset = MethSM
  }
  ReadsDist = dist(MethSM_subset)
  while (sum(is.na(ReadsDist)) > 0) {
      s <- which.max(rowSums(is.na(as.matrix(dist(MethSM_subset,diag=TRUE,upper=TRUE)))))
      MethSM_subset = MethSM_subset[dimnames(MethSM_subset)[[1]] != names(s), ]
      ReadsDist = dist(MethSM_subset)
  }
  message("down from ", nrow(MethSM), " rows to ", nrow(MethSM_subset), " to avoid NAs")
  hc = hclust(ReadsDist)
  MethSM_HC = MethSM_subset[hc$order, ]
  return(SingleMoleculeFootprinting:::PlotSingleMoleculeStack(MethSM_HC, range))
}


mySortReads <- function(MethSM, TFBS, BinsCoord, SortByCluster)
{
    message("TF cluster mode")
    TFBSs = sort(TFBS)
    binMethylationList = lapply(seq_along(TFBSs), function(i) {
        BinMethylation(MethSM, TFBSs[i], BinsCoord[[2]])
    })

    ReadsSubset = Reduce(intersect, lapply(binMethylationList,
        function(x) {
            names(x)
        }))
    binMethylationList_subset = lapply(binMethylationList, function(x) {
        as.character(x[ReadsSubset])
    })
    MethPattern = Reduce(paste0, binMethylationList_subset)
    if (length(ReadsSubset) > 0) {
        sortedReadslist = split(ReadsSubset, MethPattern)
    }
    else {
        sortedReadslist = list()
    }
    return(sortedReadslist)
}


stats_dt <- NULL

plot_region <- function(Region_of_interest)
{
  # Region_of_interest <- Region_of_interest + 1000
  Methylation <- NULL
  try(Methylation <- CallContextMethylation(sampleSheet = Qinput_bam,
    sample = MySample,
    genome = BSgenome.Dmelanogaster.UCSC.dm6,
    range = Region_of_interest,
    coverage = 20,
    ConvRate.thr = 0.2
    ))
  if (is.null(Methylation)) return()

old_par <- par(
  mfrow = c(2, 1),
  mai = c(0.2, 1, 0.3, 0.1),
  oma = c(1.5, 0, 0, 0)
)
  # print(PlotSM(MethSM = Methylation[[2]],
  #        range = Region_of_interest))
  # print(title("all molecules"))
  # print(myPlotSM(MethSM = Methylation[[2]],
  #        range = Region_of_interest,
  #        SortedReads = "HC"))
  # print(title("hierarchical clustering"))
  # # print(PlotSM(MethSM = Methylation[[2]],
  # #        range = Region_of_interest,
  # #        SortedReads = "HC"))
  # # print(title("hierarchical clustering"))

  print(TFBSs[TFBSs$peak_id == Region_of_interest$peak_id])

  BinsCoord = list(c(-50, -30), c(-10, 10), c(30, 50))
  SortedReads_TFCluster <- mySortReads(
    MethSM = Methylation[[2]],
    TFBS = TFBSs[TFBSs$peak_id == Region_of_interest$peak_id],
    BinsCoord, SortByCluster = TRUE)
  if (length(unlist(SortedReads_TFCluster)) < 100) { message("< 100 reads coverage!"); return() }

  print(PlotAvgSMF(MethGR = Methylation[[1]],
             range = Region_of_interest,
             TFBSs = TFBSs))
  print(PlotSM(MethSM = Methylation[[2]][unlist(SortedReads_TFCluster), ],
         range = Region_of_interest))
  # print(StateQuantificationPlot(SortedReads = SortedReads_TFCluster))
  par(old_par)

  stats_dt <<- rbind(stats_dt, data.table(peak_id = Region_of_interest$peak_id, spacing = Region_of_interest$spacing, state = names(SortedReads_TFCluster), count = sapply(SortedReads_TFCluster, length)))
}


pdf("results/SMF/SMF_double_TFBSs_CTCFOng2013.pdf", width = 6, height = 4)
for (i in seq_along(spacings_gr))
{
  message("i: ", i)
  Region_of_interest <- spacings_gr[i]
  message(Region_of_interest)
  try(plot_region(Region_of_interest))
}
dev.off()


lab <- c(`00` = "00 (both protected)", `01` = "01", `10` = "10", `11` = "11 (both accessible)")
stats_dt[, spacing_peak_id := paste0(spacing, " bp, ", peak_id)]
stats_dt[, spacing_peak_id := factor(spacing_peak_id, unique(spacing_peak_id))]
pdf("results/SMF/SMF_double_TFBSs_stats_CTCFOng2013.pdf", width = 10, height = 4)
p <- ggplot(stats_dt, aes(x=spacing_peak_id, y=count, fill=state))+
  geom_bar(position=position_fill(reverse=TRUE), stat="identity")+
  scale_fill_manual(values = c("#984ea3", "#8da0cb", "#66c2a5", "#d9d9d9"), labels = lab)+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  ylab("Fraction")+
  theme(legend.position = "bottom")+
  NULL
print(p)
dev.off()


cobinding_dt <- stats_dt[, list(cobinding = sum(count[state == "00"]) / sum(count[state %in% c("00", "01", "10")])), by = c("peak_id", "spacing")]
print(summary(cobinding_dt))

pdf("results/SMF/SMF_double_TFBSs_cobinding_CTCFOng2013.pdf", width = 4, height = 3)
p <- ggplot(cobinding_dt, aes(x=spacing, y=cobinding))+
  geom_point(color = "#984ea3", alpha = 0.3)+
  expand_limits(y = c(0, 1))+
  xlab("Spacing between CTCF motifs")+
  ylab("Co-binding ratio\n(fraction of all binding)")+
  ggtitle("CTCF peaks from Ong2013")+
  NULL
print(p)
dev.off()
