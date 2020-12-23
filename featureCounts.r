# featurecounts() for scATAC_seq data
# featurcounts long for pacbio and nanopore data
# date: 23/09/2020
# author: S. Amarasinghe
# objective: to get a count matrix for each gene and transcript for pacbio data

#load libraries
library("Rsubread")
library("tidyverse")
library("readr")
library("dplyr")
library("ggplot2")
library("reshape2")
library("hrbrthemes")
require("gridExtra")
library("plyr")
library("scales")

#main I/O
BAM_LOC <- "/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/06.a.aligned_merged_ref"
ONT_GFF <- "/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/isoform_annotated.gff3"
SEQUIN_LOC <- "/stornext/General/data/user_managed/grpu_mritchie_1/SCmixology/Mike_seqin/annotations/rnasequin_annotation_2.4.gtf"

OUT_LOC <- "/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/featureCounts/"

# -----------------------------------------
# generate featurecounts for the complete BAM files
# -----------------------------------------

bamFls <- list.files(path=c(BAM_LOC), 
                     pattern=".bam$", full=TRUE)
names(bamFls) <- sub("\\..*", "", 
                     basename(bamFls))

# on transcript level
# -----------------------------------------
					 
for (bam in names(bamFls)) {
  {fc <- featureCounts(bamFls[[bam]], 
                       isPairedEnd         = FALSE, 
                       annot.ext           = paste0(ONT_GFF),
                       isGTFAnnotationFile = TRUE,
                       GTF.featureType     = "transcript",
                       GTF.attrType        = "transcript_id", 
                       strandSpecific      = 0, #options are 0 unstranded, 1 forward, 2 reverse
                       nthreads            = 8,
                       allowMultiOverlap   = TRUE,
                       useMetaFeatures     = FALSE,
					   isLongRead          = TRUE					   
  )
  write.csv(fc$counts, paste0(OUT_LOC, "nanopore/counts_transcript_", bam, ".csv" ), quote = FALSE)	
  write.csv(fc$stat, paste0(OUT_LOC, "nanopore/stats_transcript_", bam, ".csv" ), quote = FALSE)	
  }
}	


# on exon level
# -----------------------------------------

dir.create("/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/featureCounts/nanopore_exon")

for (bam in names(bamFls)) {
  {fc <- featureCounts(bamFls[[bam]], 
                       isPairedEnd         = FALSE, 
                       annot.ext           = paste0(ONT_GFF),
                       isGTFAnnotationFile = TRUE,
                       GTF.featureType     = "exon",
                       GTF.attrType        = "exon_id", 
                       strandSpecific      = 0, #options are 0 unstranded, 1 forward, 2 reverse
                       nthreads            = 8,
                       allowMultiOverlap   = TRUE,
                       useMetaFeatures     = FALSE,
					   isLongRead          = TRUE					   
  )
  write.csv(fc$counts, paste0(OUT_LOC, "nanopore_exon/counts_transcript_", bam, ".csv" ), quote = FALSE)	
  write.csv(fc$stat, paste0(OUT_LOC, "nanopore_exon/stats_transcript_", bam, ".csv" ), quote = FALSE)	
  }
}

# on sequins
# -----------------------------------------

dir.create("/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/featureCounts/sequin")

for (bam in names(bamFls)) {
  {fc <- featureCounts(bamFls[[bam]], 
                       isPairedEnd         = FALSE, 
                       annot.ext           = paste0(SEQUIN_LOC),
                       isGTFAnnotationFile = TRUE,
                       GTF.featureType     = "gene",
                       GTF.attrType        = "gene_id", 
                       strandSpecific      = 0, #options are 0 unstranded, 1 forward, 2 reverse
                       nthreads            = 8,
                       allowMultiOverlap   = TRUE,
                       useMetaFeatures     = FALSE,
					   isLongRead          = TRUE					   
  )
  write.csv(fc$counts, paste0(OUT_LOC, "sequin/counts_transcript_", bam, ".csv" ), quote = FALSE)	
  write.csv(fc$stat, paste0(OUT_LOC, "sequin/stats_transcript_", bam, ".csv" ), quote = FALSE)	
  }
}



# count sequins from raw bam alignments
# -----------------------------------------

dir.create("/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/featureCounts/sequin_raw")
BAM_LOC <- "/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/raw_aligned_sequins"

bamFls <- list.files(path=c(BAM_LOC), 
                     pattern=".bam$", full=TRUE)
names(bamFls) <- sub("\\..*", "", 
                     basename(bamFls))
					 
for (bam in names(bamFls)) {
  {fc <- featureCounts(bamFls[[bam]], 
                       isPairedEnd         = FALSE, 
                       annot.ext           = paste0(SEQUIN_LOC),
                       isGTFAnnotationFile = TRUE,
                       GTF.featureType     = "gene",
                       GTF.attrType        = "gene_id", 
                       strandSpecific      = 0, #options are 0 unstranded, 1 forward, 2 reverse
                       nthreads            = 8,
                       allowMultiOverlap   = TRUE,
                       useMetaFeatures     = FALSE,
					   isLongRead          = TRUE					   
  )
  write.csv(fc$counts, paste0(OUT_LOC, "sequin_raw/counts_transcript_", bam, ".csv" ), quote = FALSE)	
  write.csv(fc$stat, paste0(OUT_LOC, "sequin_raw/stats_transcript_", bam, ".csv" ), quote = FALSE)	
  }
}


# count known features from all the PacBio, Nanopore and Illumina (transcript)
# -----------------------------------------

ONT_BAM_LOC      <- "/stornext/General/data/user_managed/grpu_mritchie_1/XueyiDong/long_read_benchmark/ONT/bam"
ILLUMINA_BAM_LOC <- "/stornext/General/data/user_managed/grpu_mritchie_1/XueyiDong/long_read_benchmark/illumina/bam"
PACBIO_BAM_LOC   <- "/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/06.a.aligned_merged_ref"

GFF_LOC <- "/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/genome_rnasequin_decoychr_2.4.gtf"

# ONT

dir.create("/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/featureCounts/ont_known")

bamFls <- list.files(path=c(ONT_BAM_LOC), 
                     pattern=".bam$", full=TRUE)
names(bamFls) <- sub("\\..*", "", 
                     basename(bamFls))
					 
for (bam in names(bamFls)) {
  {fc <- featureCounts(bamFls[[bam]], 
                       isPairedEnd         = FALSE, 
                       annot.ext           = paste0(GFF_LOC),
                       isGTFAnnotationFile = TRUE,
                       GTF.featureType     = "transcript",
                       GTF.attrType        = "transcript_id", 
                       strandSpecific      = 0, #options are 0 unstranded, 1 forward, 2 reverse
                       nthreads            = 8,
                       allowMultiOverlap   = TRUE,
                       useMetaFeatures     = FALSE,
					   isLongRead          = TRUE					   
  )
  write.csv(fc$counts, paste0(OUT_LOC, "ont_known/counts_transcript_", bam, ".csv" ), quote = FALSE)	
  write.csv(fc$stat, paste0(OUT_LOC, "ont_known/stats_transcript_", bam, ".csv" ), quote = FALSE)	
  }
}

# PacBio

dir.create("/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/featureCounts/pb_known")

bamFls <- list.files(path=c(PACBIO_BAM_LOC), 
                     pattern=".bam$", full=TRUE)
names(bamFls) <- sub("\\..*", "", 
                     basename(bamFls))
					 
for (bam in names(bamFls)) {
  {fc <- featureCounts(bamFls[[bam]], 
                       isPairedEnd         = FALSE, 
                       annot.ext           = paste0(GFF_LOC),
                       isGTFAnnotationFile = TRUE,
                       GTF.featureType     = "transcript",
                       GTF.attrType        = "transcript_id", 
                       strandSpecific      = 0, #options are 0 unstranded, 1 forward, 2 reverse
                       nthreads            = 8,
                       allowMultiOverlap   = TRUE,
                       useMetaFeatures     = FALSE,
					   isLongRead          = TRUE					   
  )
  write.csv(fc$counts, paste0(OUT_LOC, "pb_known/counts_transcript_", bam, ".csv" ), quote = FALSE)	
  write.csv(fc$stat, paste0(OUT_LOC, "pb_known/stats_transcript_", bam, ".csv" ), quote = FALSE)	
  }
}

# Illumina

dir.create("/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/featureCounts/illumina_known")

bamFls <- list.files(path=c(ILLUMINA_BAM_LOC), 
                     pattern=".bam$", full=TRUE)
names(bamFls) <- sub("\\..*", "", 
                     basename(bamFls))
					 
for (bam in names(bamFls)) {
  {fc <- featureCounts(bamFls[[bam]], 
                       isPairedEnd         = FALSE, 
                       annot.ext           = paste0(GFF_LOC),
                       isGTFAnnotationFile = TRUE,
                       GTF.featureType     = "transcript",
                       GTF.attrType        = "transcript_id", 
                       strandSpecific      = 0, #options are 0 unstranded, 1 forward, 2 reverse
                       nthreads            = 8,
                       allowMultiOverlap   = TRUE,
                       useMetaFeatures     = FALSE,
					   isLongRead          = FALSE					   
  )
  write.csv(fc$counts, paste0(OUT_LOC, "illumina_known/counts_transcript_", bam, ".csv" ), quote = FALSE)	
  write.csv(fc$stat, paste0(OUT_LOC, "illumina_known/stats_transcript_", bam, ".csv" ), quote = FALSE)	
  }
}

# count known features from all the PacBio, Nanopore and Illumina (gene)
# -----------------------------------------

ONT_BAM_LOC      <- "/stornext/General/data/user_managed/grpu_mritchie_1/XueyiDong/long_read_benchmark/ONT/bam"
ILLUMINA_BAM_LOC <- "/stornext/General/data/user_managed/grpu_mritchie_1/XueyiDong/long_read_benchmark/illumina/bam"
PACBIO_BAM_LOC   <- "/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/06.a.aligned_merged_ref"

GFF_LOC <- "/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/genome_rnasequin_decoychr_2.4.gtf"

# ONT

dir.create("/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/featureCounts/ont_known_gene")

bamFls <- list.files(path=c(ONT_BAM_LOC), 
                     pattern=".bam$", full=TRUE)
names(bamFls) <- sub("\\..*", "", 
                     basename(bamFls))
					 
for (bam in names(bamFls)) {
  {fc <- featureCounts(bamFls[[bam]], 
                       isPairedEnd         = FALSE, 
                       annot.ext           = paste0(GFF_LOC),
                       isGTFAnnotationFile = TRUE,
                       GTF.featureType     = "gene",
                       GTF.attrType        = "gene_id", 
                       strandSpecific      = 0, #options are 0 unstranded, 1 forward, 2 reverse
                       nthreads            = 8,
                       allowMultiOverlap   = TRUE,
                       useMetaFeatures     = FALSE,
					   isLongRead          = TRUE					   
  )
  write.csv(fc$counts, paste0(OUT_LOC, "ont_known_gene/counts_transcript_", bam, ".csv" ), quote = FALSE)	
  write.csv(fc$stat, paste0(OUT_LOC, "ont_known_gene/stats_transcript_", bam, ".csv" ), quote = FALSE)	
  }
}

# PacBio

dir.create("/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/featureCounts/pb_known_gene")

bamFls <- list.files(path=c(PACBIO_BAM_LOC), 
                     pattern=".bam$", full=TRUE)
names(bamFls) <- sub("\\..*", "", 
                     basename(bamFls))
					 
for (bam in names(bamFls)) {
  {fc <- featureCounts(bamFls[[bam]], 
                       isPairedEnd         = FALSE, 
                       annot.ext           = paste0(GFF_LOC),
                       isGTFAnnotationFile = TRUE,
                       GTF.featureType     = "gene",
                       GTF.attrType        = "gene_id", 
                       strandSpecific      = 0, #options are 0 unstranded, 1 forward, 2 reverse
                       nthreads            = 8,
                       allowMultiOverlap   = TRUE,
                       useMetaFeatures     = FALSE,
					   isLongRead          = TRUE					   
  )
  write.csv(fc$counts, paste0(OUT_LOC, "pb_known_gene/counts_transcript_", bam, ".csv" ), quote = FALSE)	
  write.csv(fc$stat, paste0(OUT_LOC, "pb_known_gene/stats_transcript_", bam, ".csv" ), quote = FALSE)	
  }
}

# Illumina

dir.create("/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/featureCounts/illumina_known_gene")

bamFls <- list.files(path=c(ILLUMINA_BAM_LOC), 
                     pattern=".bam$", full=TRUE)
names(bamFls) <- sub("\\..*", "", 
                     basename(bamFls))
					 
for (bam in names(bamFls)) {
  {fc <- featureCounts(bamFls[[bam]], 
                       isPairedEnd         = FALSE, 
                       annot.ext           = paste0(GFF_LOC),
                       isGTFAnnotationFile = TRUE,
                       GTF.featureType     = "gene",
                       GTF.attrType        = "gene_id", 
                       strandSpecific      = 0, #options are 0 unstranded, 1 forward, 2 reverse
                       nthreads            = 8,
                       allowMultiOverlap   = TRUE,
                       useMetaFeatures     = FALSE,
					   isLongRead          = FALSE					   
  )
  write.csv(fc$counts, paste0(OUT_LOC, "illumina_known_gene/counts_transcript_", bam, ".csv" ), quote = FALSE)	
  write.csv(fc$stat, paste0(OUT_LOC, "illumina_known_gene/stats_transcript_", bam, ".csv" ), quote = FALSE)	
  }
}

# count sequins features from all the Nanopore and Illumina
# -----------------------------------------		  

# ONT

dir.create("/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/featureCounts/sequin_ont")

bamFls <- list.files(path=c(ONT_BAM_LOC), 
                     pattern=".bam$", full=TRUE)
names(bamFls) <- sub("\\..*", "", 
                     basename(bamFls))
					 
for (bam in names(bamFls)) {
  {fc <- featureCounts(bamFls[[bam]], 
                       isPairedEnd         = FALSE, 
                       annot.ext           = paste0(SEQUIN_LOC),
                       isGTFAnnotationFile = TRUE,
                       GTF.featureType     = "gene",
                       GTF.attrType        = "gene_id", 
                       strandSpecific      = 0, #options are 0 unstranded, 1 forward, 2 reverse
                       nthreads            = 8,
                       allowMultiOverlap   = TRUE,
                       useMetaFeatures     = FALSE,
					   isLongRead          = TRUE					   
  )
  write.csv(fc$counts, paste0(OUT_LOC, "sequin_ont/counts_transcript_", bam, ".csv" ), quote = FALSE)	
  write.csv(fc$stat, paste0(OUT_LOC, "sequin_ont/stats_transcript_", bam, ".csv" ), quote = FALSE)	
  }
}

# ILLUMINA

dir.create("/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/featureCounts/sequin_illumina")

bamFls <- list.files(path=c(ILLUMINA_BAM_LOC), 
                     pattern=".bam$", full=TRUE)
names(bamFls) <- sub("\\..*", "", 
                     basename(bamFls))
					 
for (bam in names(bamFls)) {
  {fc <- featureCounts(bamFls[[bam]], 
                       isPairedEnd         = FALSE, 
                       annot.ext           = paste0(SEQUIN_LOC),
                       isGTFAnnotationFile = TRUE,
                       GTF.featureType     = "gene",
                       GTF.attrType        = "gene_id", 
                       strandSpecific      = 0, #options are 0 unstranded, 1 forward, 2 reverse
                       nthreads            = 8,
                       allowMultiOverlap   = TRUE,
                       useMetaFeatures     = FALSE,
					   isLongRead          = FALSE					   
  )
  write.csv(fc$counts, paste0(OUT_LOC, "sequin_illumina/counts_transcript_", bam, ".csv" ), quote = FALSE)	
  write.csv(fc$stat, paste0(OUT_LOC, "sequin_illumina/stats_transcript_", bam, ".csv" ), quote = FALSE)	
  }
}
