configfile: "config/config.yml"

SAMPLES = list(config["Bisulfite-Seq"]["dataset_to_library_sra"])
DATASETS = ["SRR3133326-7", "SRR3133328-9"]

#
#  Default targets
#

rule all:
  input:
    lambda wildcards:
      rules.all_multiqc.input + \
      rules.all_trimmed.input + \
      rules.all_deduplicated.input + \
      rules.all_merged_final.input + \
      rules.all_plots.input

rule all_multiqc:
  input:
    "data/Bisulfite-Seq/qc/multiqc_report.html"

rule all_trimmed:
  input:
    list([
      ["data/Bisulfite-Seq/fastq_trimmed/" + sample + "_forward_paired.fastq.gz",
        "data/Bisulfite-Seq/fastq_trimmed/" + sample + "_reverse_paired.fastq.gz"]
        for sample in SAMPLES])

rule all_deduplicated:
  input:
    list(["data/Bisulfite-Seq/bam/" + dataset + ".bam" for dataset in DATASETS])

rule all_merged_final:
  input:
    "data/Bisulfite-Seq/bam/SRR3133326-9.rmdup.merge.bam"

rule all_plots:
  input:
    "results/SMF/SMF_double_TFBSs_cobinding_CTCFOng2013.pdf"

#
#  SRA data download
#

rule download_sra:
  output:
    "data/Bisulfite-Seq/fastq/{sample}_1.fastq.gz",
    "data/Bisulfite-Seq/fastq/{sample}_2.fastq.gz"
  conda:
    "../../env/sra-tools.yaml"
  shell:
    "fastq-dump --split-files --origfmt --gzip -O data/Bisulfite-Seq/fastq {wildcards.sample}"

#
#  FASTQ quality control
#

rule fastqc:
  input:
    "data/Bisulfite-Seq/fastq/{file}.fastq.gz"
  output:
    "data/Bisulfite-Seq/qc/{file}_fastqc.zip"
  conda:
    "../../env/fastqc.yaml"
  shell:
    """
    fastqc -o data/Bisulfite-Seq/qc {input}
    """

def library_fastq_qcfiles(wildcards):
  return ["data/Bisulfite-Seq/qc/" + library_sra + "_" + readindex + "_fastqc.zip"
    for library_sra in SAMPLES
      for readindex in ["1", "2"]]

rule multiqc:
  input:
    library_fastq_qcfiles
  output:
    "data/Bisulfite-Seq/qc/multiqc_report.html"
  conda:
    "../../env/multiqc.yaml"
  shell:
    """
    cd data/Bisulfite-Seq/qc
    rm -rf multiqc_data/
    multiqc --interactive .
    """

#
#  Trim the 3' low quality end of the reads, and Illumina adapters
#

rule trimmomatic:
  input:
    read1 = "data/Bisulfite-Seq/fastq/{file}_1.fastq.gz",
    read2 = "data/Bisulfite-Seq/fastq/{file}_2.fastq.gz"
  output:
    forward_paired = "data/Bisulfite-Seq/fastq_trimmed/{file}_forward_paired.fastq.gz",
    forward_unpaired = "data/Bisulfite-Seq/fastq_trimmed/{file}_forward_unpaired.fastq.gz",
    reverse_paired = "data/Bisulfite-Seq/fastq_trimmed/{file}_reverse_paired.fastq.gz",
    reverse_unpaired = "data/Bisulfite-Seq/fastq_trimmed/{file}_reverse_unpaired.fastq.gz"
  threads:
    4
  conda:
    "../../env/trimmomatic.yaml"
  shell:
    """
    trimmomatic PE -threads {threads} {input.read1} {input.read2} \
      {output.forward_paired} {output.forward_unpaired} {output.reverse_paired} {output.reverse_unpaired} \
      ILLUMINACLIP:config/TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:18
    """

#
#  Align reads using QuasR/Rbowtie
#

rule SMF_prepare_data:
  input:
    forward_paired = "data/Bisulfite-Seq/fastq_trimmed/{sample}_forward_paired.fastq.gz",
    reverse_paired = "data/Bisulfite-Seq/fastq_trimmed/{sample}_reverse_paired.fastq.gz",
    Qfile = "config/{sample}_Qinput.tsv"
  output:
    temp("data/Bisulfite-Seq/bam/{sample}_forward_paired_{suffix}.bam")
  threads:
    2
  conda:
    "../../env/snf.yaml"
  shell:
    """
    Rscript src/R/SMF_prepare_data.R {input.Qfile}
    """

#
#  Merge sequencing runs that belong to the same biological replicate, and deduplicate reads
#

rule samtools_merge_SRR3133326_7:
  input:
    "data/Bisulfite-Seq/bam/SRR3133326_forward_paired_15c3a316c89abe.bam",
    "data/Bisulfite-Seq/bam/SRR3133327_forward_paired_15c3a33d2c68b3.bam"
  output:
    temp("data/Bisulfite-Seq/bam/SRR3133326-7.bam")
  conda:
    "../../env/samtools.yaml"
  shell:
    """
    samtools merge -@ 4 {output} {input}
    samtools index {output}
    """

rule samtools_merge_SRR3133328_9:
  input:
    "data/Bisulfite-Seq/bam/SRR3133328_forward_paired_15c82c4e684a3d.bam",
    "data/Bisulfite-Seq/bam/SRR3133329_forward_paired_15c82c6a1e2e26.bam"
  output:
    temp("data/Bisulfite-Seq/bam/SRR3133328-9.bam")
  conda:
    "../../env/samtools.yaml"
  shell:
    """
    samtools merge -@ 4 {output} {input}
    samtools index {output}
    """

rule picard_rmdup:
  input:
    "data/Bisulfite-Seq/bam/{file}.bam"
  output:
    bam = "data/Bisulfite-Seq/bam/{file}.rmdup.bam",
    metrics = "data/Bisulfite-Seq/bam/{file}.rmdup.metrics.txt"
  log:
    "data/Bisulfite-Seq/bam/{file}.rmdup.log"
  conda:
    "../../env/picard-slim.yaml"
  shell:
    """
    picard -Xmx32g MarkDuplicates -INPUT {input} -OUTPUT {output.bam} -REMOVE_DUPLICATES true -VALIDATION_STRINGENCY LENIENT -METRICS_FILE {output.metrics} &> {log}
    """

#
#  Merge biological replicates
#

rule samtools_merge_final:
  input:
    "data/Bisulfite-Seq/bam/SRR3133326-7.rmdup.bam",
    "data/Bisulfite-Seq/bam/SRR3133328-9.rmdup.bam"
  output:
    "data/Bisulfite-Seq/bam/SRR3133326-9.rmdup.merge.bam"
  conda:
    "../../env/samtools.yaml"
  shell:
    """
    samtools merge -@ 4 {output} {input}
    samtools index {output}
    """

#
#  Plot SMF signal at double motif CTCF ChIP-seq peaks
#

rule CTCF_peaks_getfasta:
  input:
    bed = "data/CTCF_binding/{file}.bed",
    fasta_genome = config["genome"]["fasta"]
  output:
    "data/CTCF_binding/{file}.fa"
  conda:
    "../../env/bedtools.yaml"
  shell:
    """
    bedtools getfasta -fi {input.fasta_genome} -bed {input.bed} -fo {output}
    """

rule fimo_CTCF_binding:
  input:
    motifs = "data/CTCF_binding/MA0531.1.meme",
    fasta = "data/CTCF_binding/{file}.fa"
  output:
    "results/CTCF_binding/{file}.fa/fimo.gff"
  conda:
    "../../env/meme.yaml"
  shell:
    """
    fimo --oc results/CTCF_binding/{wildcards.file}.fa --no-pgc {input.motifs} {input.fasta}
    """

rule SMF_CTCF:
  input:
    "config/SRR3133326-9_Qinput_bam.tsv",
    "data/Bisulfite-Seq/bam/SRR3133326-9.rmdup.merge.bam",
    "results/CTCF_binding/GSM1015410_Ct-CTCF_peaks_dm6.fa/fimo.gff"
  output:
    "results/SMF/SMF_double_TFBSs_cobinding_CTCFOng2013.pdf"
  conda:
    "../../env/snf.yaml"
  shell:
    """
    Rscript src/R/SMF_CTCF.R
    """
