# plotting the featureCOunt outputs
# in different meaningful ways

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

#main setup
setwd("Z:/Shani/long_read_benchmark/featureCounts")
OUT_LOC <- "Z:/Shani/long_read_benchmark/featureCounts"

# on sequins from flnc files
# -----------------------------------------

# I/O
COUNT_FILES_LOC             <- paste0(OUT_LOC, "sequin")

# read in the counts files
files                       <- list.files(COUNT_FILES_LOC, "counts_transcript_", full.names = TRUE)
counts_list                 <- lapply(files, read_csv)
names(counts_list)          <- gsub("counts_transcript_(.*)\\_clustered.*","\\1", basename(files))

for (i in 1:length(counts_list)) {
  counts_list[[i]]            <- as.data.frame(counts_list[[i]])
  rownames(counts_list[[i]])  <- counts_list[[i]]$X1
  colnames(counts_list[[i]])  <- gsub("\\.clustered.aligned.to.merged.hg38.bam","", colnames(counts_list[[i]]))
}

CountS                        <- bind_cols(counts_list)
ROWNAMES                      <- CountS$X1               
CountS                        <- CountS[sapply(CountS, is.numeric)]
rownames(CountS)              <- ROWNAMES
colnames(CountS)              <- names(counts_list)

# filter anything that has 0 across the rows
CountS                        <- CountS[rowSums(CountS) > 0, ]
saveRDS(CountS, paste0(OUT_LOC, "sequins_count_matrix_filtered.RDS"))

setwd("Z:/Shani/long_read_benchmark/featureCounts/")
sequin_counts <- readRDS("sequins_count_matrix_filtered.RDS")
sequin_counts_long <- reshape2::melt(as.matrix(sequin_counts))
colnames(sequin_counts_long) <- c("sequin_gene", "sample", "read_count")

ggbarplot(sequin_counts_long, 
			x = "sequin_gene", 
			y = "read_count", 
			fill = "sample",
			lab.size = 10,
			palette ="jco") + 
	xlab("Sequin gene") +
	ylab("Read count") +
	theme(axis.text=element_text(size=14),
		  axis.title=element_text(size=16,face="bold"),
		  axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
		  legend.title = element_text(size=14),
		  legend.text = element_text(size=14))
		  
# on sequins from subread files
# -----------------------------------------

#I/O
COUNT_FILES_LOC             <- paste0(OUT_LOC, "sequin_raw")

# read in the counts files
files                       <- list.files(COUNT_FILES_LOC, "counts_transcript_", full.names = TRUE)
counts_list                 <- lapply(files, read_csv)
names(counts_list)          <- gsub("counts_transcript_(.*)\\_m6.*","\\1", basename(files))

for (i in 1:length(counts_list)) {
  counts_list[[i]]            <- as.data.frame(counts_list[[i]])
  rownames(counts_list[[i]])  <- counts_list[[i]]$X1
  colnames(counts_list[[i]])  <- gsub("\\.m6.*","", colnames(counts_list[[i]]))
}

CountS                        <- bind_cols(counts_list)
ROWNAMES                      <- CountS$X1               
CountS                        <- CountS[sapply(CountS, is.numeric)]
rownames(CountS)              <- ROWNAMES
colnames(CountS)              <- names(counts_list)
colnames(CountS)              <- make.unique(colnames(CountS), sep="_")

# filter anything that has 0 across the rows
CountS                        <- CountS[rowSums(CountS) > 0, ]
saveRDS(CountS, paste0(OUT_LOC, "raw_sequins_count_matrix_filtered.RDS"))

setwd("Z:/Shani/long_read_benchmark/featureCounts/")
sequin_counts <- readRDS("raw_sequins_count_matrix_filtered.RDS")
sequin_counts_long <- reshape2::melt(as.matrix(sequin_counts))
colnames(sequin_counts_long) <- c("sequin_gene", "sample", "read_count")

ggbarplot(sequin_counts_long, 
			x = "sequin_gene", 
			y = "read_count", 
			fill = "sample",
			lab.size = 10,
			palette ="jco") + 
	xlab("Sequin gene") +
	ylab("Read count") +
	theme(axis.text=element_text(size=14),
		  axis.title=element_text(size=16,face="bold"),
		  axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
		  legend.title = element_text(size=14),
		  legend.text = element_text(size=14))		  


# estimated vs expected abundance on sequins from flnc files
# -----------------------------------------

# I/O
COUNT_FILES_LOC             <- paste0(OUT_LOC, "/sequin")

# read in the counts files
files                       <- list.files(COUNT_FILES_LOC, "counts_transcript_", full.names = TRUE)
counts_list                 <- lapply(files, read_csv)
names(counts_list)          <- gsub("counts_transcript_(.*)\\_clustered.*","\\1", basename(files))

for (i in 1:length(counts_list)) {
  counts_list[[i]]            <- as.data.frame(counts_list[[i]])
  rownames(counts_list[[i]])  <- counts_list[[i]]$X1
  colnames(counts_list[[i]])  <- gsub("\\.clustered.aligned.to.merged.hg38.bam","", colnames(counts_list[[i]]))
}

CountS                        <- bind_cols(counts_list)
ROWNAMES                      <- CountS$X1               
CountS                        <- CountS[sapply(CountS, is.numeric)]
rownames(CountS)              <- ROWNAMES
colnames(CountS)              <- names(counts_list)

# read in sequin abundance

est_seq_abund <- read.table("Z:/SCmixology/Mike_seqin/annotations/rnasequin_genes_2.4.tsv", header = TRUE)
head(est_seq_abund)

counts_merged <- cbind(CountS, 
                       MIX_A = est_seq_abund$MIX_A[match(row.names(CountS), est_seq_abund$NAME)], 
                       MIX_B = est_seq_abund$MIX_B[match(row.names(CountS), est_seq_abund$NAME)])

counts_merged$S1_logCPM <- (edgeR::cpm(counts_merged$`1R`))
counts_merged$S2_logCPM <- (edgeR::cpm(counts_merged$`2R`))
counts_merged$S3_logCPM <- (edgeR::cpm(counts_merged$`3R`))
counts_merged$S4_logCPM <- (edgeR::cpm(counts_merged$`4R`))
counts_merged$S5_logCPM <- (edgeR::cpm(counts_merged$`5R`))
counts_merged$S6_polyA_logCPM <- log2(edgeR::cpm(counts_merged$`6R_polyA`))
counts_merged$MIX_A_logCPM <- (edgeR::cpm(counts_merged$`MIX_A`))
counts_merged$MIX_B_logCPM <- (edgeR::cpm(counts_merged$`MIX_B`))


ggscatter(counts_merged, x = "S1_logCPM", y = c("MIX_A_logCPM"), size = 2.0,
          combine = TRUE, ylab = "Expected abundance", xlab = "Estimated abundance",
          palette = "jco", scales = "free_y", rug = TRUE,
          add.params = list(color = "blue", fill = "lightgray"),
          add = "reg.line", conf.int = TRUE) +
  stat_cor(method = "spearman", label.y.npc = "top", label.x.npc = "left", size = 7) +
  theme(axis.text=element_text(size=14),
        axis.title=element_text(size=16,face="bold"),
        axis.text.x = element_text(vjust = 0.5, hjust=1),
        legend.title = element_text(size=14),
        legend.text = element_text(size=14))

ggscatter(counts_merged, x = "S2_logCPM", y = c("MIX_A_logCPM"), size = 2.0,
          combine = TRUE, ylab = "Expected abundance", xlab = "Estimated abundance",
          palette = "jco", scales = "free_y", rug = TRUE,
          add.params = list(color = "blue", fill = "lightgray"),
          add = "reg.line", conf.int = TRUE) +
  stat_cor(method = "spearman", label.y.npc = "top", label.x.npc = "left", size = 7) +
  theme(axis.text=element_text(size=14),
        axis.title=element_text(size=16,face="bold"),
        axis.text.x = element_text(vjust = 0.5, hjust=1),
        legend.title = element_text(size=14),
        legend.text = element_text(size=14))

ggscatter(counts_merged, x = "S3_logCPM", y = c("MIX_A_logCPM"), size = 2.0,
          combine = TRUE, ylab = "Expected abundance", xlab = "Estimated abundance",
          palette = "jco", scales = "free_y", rug = TRUE,
          add.params = list(color = "blue", fill = "lightgray"),
          add = "reg.line", conf.int = TRUE) +
  stat_cor(method = "spearman", label.y.npc = "top", label.x.npc = "left", size = 7) +
  theme(axis.text=element_text(size=14),
        axis.title=element_text(size=16,face="bold"),
        axis.text.x = element_text(vjust = 0.5, hjust=1),
        legend.title = element_text(size=14),
        legend.text = element_text(size=14))

ggscatter(counts_merged, x = "S4_logCPM", y = c("MIX_B_logCPM"), size = 2.0,
          combine = TRUE, ylab = "Expected abundance", xlab = "Estimated abundance",
          palette = "jco", scales = "free_y", rug = TRUE,
          add.params = list(color = "blue", fill = "lightgray"),
          add = "reg.line", conf.int = TRUE) +
  stat_cor(method = "spearman", label.y.npc = "top", label.x.npc = "left", size = 7) +
  theme(axis.text=element_text(size=14),
        axis.title=element_text(size=16,face="bold"),
        axis.text.x = element_text(vjust = 0.5, hjust=1),
        legend.title = element_text(size=14),
        legend.text = element_text(size=14))

ggscatter(counts_merged, x = "S5_logCPM", y = c("MIX_B_logCPM"), size = 2.0,
          combine = TRUE, ylab = "Expected abundance", xlab = "Estimated abundance",
          palette = "jco", scales = "free_y", rug = TRUE,
          add.params = list(color = "blue", fill = "lightgray"),
          add = "reg.line", conf.int = TRUE) +
  stat_cor(method = "spearman", label.y.npc = "top", label.x.npc = "left", size = 7) +
  theme(axis.text=element_text(size=14),
        axis.title=element_text(size=16,face="bold"),
        axis.text.x = element_text(vjust = 0.5, hjust=1),
        legend.title = element_text(size=14),
        legend.text = element_text(size=14))

ggscatter(counts_merged, x = "S6_polyA_logCPM", y = c("MIX_B_logCPM"), size = 2.0,
          combine = TRUE, ylab = "Expected abundance", xlab = "Estimated abundance",
          palette = "jco", scales = "free_y", rug = TRUE,
          add.params = list(color = "blue", fill = "lightgray"),
          add = "reg.line", conf.int = TRUE) +
  stat_cor(method = "spearman", label.y.npc = "top", label.x.npc = "left", size = 7) +
  theme(axis.text=element_text(size=14),
        axis.title=element_text(size=16,face="bold"),
        axis.text.x = element_text(vjust = 0.5, hjust=1),
        legend.title = element_text(size=14),
        legend.text = element_text(size=14))


# plotting the sample size from all technologies
#-------------------------------------------------
sample_size <- read.csv("sample_sizes_summrised.csv", header = TRUE)
head(sample_size)

# from Xueyi
ont_size <- readRDS("ONT.RDS")
illumina_size <- readRDS("illumina.RDS")

# I just copy above paste this to my original file

sample_size <- read.csv("sample_sizes_summrised_new.csv", header = TRUE)

sample_size$tech <- factor(sample_size$tech, levels=c("pacbio", "ont", "illumina"))
  
ggbarplot(sample_size, 
          x = "tech", 
          y = "sample_size", 
          fill = "tech",
          lab.size = 10,
          palette ="npg") + 
  xlab("Technology") +
  ylab("Unprocessed library size") +
  theme(axis.text=element_text(size=14),
        axis.title=element_text(size=16,face="bold"),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.title = element_text(size=14),
        legend.text = element_text(size=14),
        legend.position = "none")	+
  facet_wrap(~sample, scales = "free")


# plotting ratio of assigned to unassigned from known gff
#---------------------------------------------------------

# First I manually generated the input files
# couldn't be bothered to write a script	

stat_summary <- read.csv("known_gene_stat_summarised.csv", header = TRUE)	  
head(stat_summary)

#calculate percentages
edited_stat_summary <- stat_summary %>% dplyr::group_by(tech, sample) %>% mutate(percentage = (count/sum(count) * 100))
edited_stat_summary$fill_col <- factor(paste0(edited_stat_summary$tech,"_", edited_stat_summary$cat))
edited_stat_summary$tech <- factor(edited_stat_summary$tech, levels=c("pacbio", "ont", "illumina"))

ggbarplot(edited_stat_summary, 
          x = "tech", 
          y = "percentage", 
          fill = "cat",
          lab.size = 10,
          palette ="jco") + 
  xlab("Technology") +
  ylab("Percentage of reads") +
  theme(axis.text=element_text(size=14),
        axis.title=element_text(size=16,face="bold"),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.title = element_text(size=14),
        legend.text = element_text(size=14))	+
  facet_wrap(~sample, scales = "free")

# plotting assigned from known gff from each tech in scateerplots
#---------------------------------------------------------

#pacbio
COUNT_FILES_LOC             <- paste0(OUT_LOC, "/pb_known_gene")

# read in the counts files
files                       <- list.files(COUNT_FILES_LOC, "counts_transcript_", full.names = TRUE)
counts_list                 <- lapply(files, read_csv)
names(counts_list)          <- gsub("counts_transcript_(.*)\\_clustered.*","\\1", basename(files))

for (i in 1:length(counts_list)) {
  counts_list[[i]]            <- as.data.frame(counts_list[[i]])
  rownames(counts_list[[i]])  <- counts_list[[i]]$X1
  colnames(counts_list[[i]])  <- gsub("\\.clustered.*","", colnames(counts_list[[i]]))
}

CountS                        <- bind_cols(counts_list)
ROWNAMES                      <- CountS$X1               
CountS                        <- CountS[sapply(CountS, is.numeric)]
rownames(CountS)              <- ROWNAMES
colnames(CountS)              <- names(counts_list)
colnames(CountS)              <- make.unique(colnames(CountS), sep="_")

saveRDS(CountS, "pb_known_count_matrix.rds")

#ont
COUNT_FILES_LOC             <- paste0(OUT_LOC, "/ont_known_gene")

# read in the counts files
files                       <- list.files(COUNT_FILES_LOC, "counts_transcript_", full.names = TRUE)
counts_list                 <- lapply(files, read_csv)
names(counts_list)          <- gsub("counts_transcript_(.*).csv","\\1", basename(files))

for (i in 1:length(counts_list)) {
  counts_list[[i]]            <- as.data.frame(counts_list[[i]])
  rownames(counts_list[[i]])  <- counts_list[[i]]$X1
  colnames(counts_list[[i]])  <- gsub("\\.sorted*","", colnames(counts_list[[i]]))
}

CountS                        <- bind_cols(counts_list)
ROWNAMES                      <- CountS$X1               
CountS                        <- CountS[sapply(CountS, is.numeric)]
rownames(CountS)              <- ROWNAMES
colnames(CountS)              <- names(counts_list)
colnames(CountS)              <- make.unique(colnames(CountS), sep="_")

saveRDS(CountS, "ont_known_count_matrix.rds")

#illumina
COUNT_FILES_LOC             <- paste0(OUT_LOC, "/illumina_known_gene")

# read in the counts files
files                       <- list.files(COUNT_FILES_LOC, "counts_transcript_", full.names = TRUE)
counts_list                 <- lapply(files, read_csv)
names(counts_list)          <- gsub("counts_transcript_(.*).csv","\\1", basename(files))

for (i in 1:length(counts_list)) {
  counts_list[[i]]            <- as.data.frame(counts_list[[i]])
  rownames(counts_list[[i]])  <- counts_list[[i]]$X1
  colnames(counts_list[[i]])  <- gsub("(.*\\..*)\\..*","\\1", colnames(counts_list[[i]]))
}

CountS                        <- bind_cols(counts_list)
ROWNAMES                      <- CountS$X1               
CountS                        <- CountS[sapply(CountS, is.numeric)]
rownames(CountS)              <- ROWNAMES
colnames(CountS)              <- names(counts_list)
colnames(CountS)              <- make.unique(colnames(CountS), sep="_")

saveRDS(CountS, "illumina_known_count_matrix.rds")

# combine all count matrices

pb_counts  <- readRDS(paste0(OUT_LOC,"/pb_known_count_matrix.rds"))
ont_counts <- readRDS(paste0(OUT_LOC,"/ont_known_count_matrix.rds"))
illumina_counts <- readRDS(paste0(OUT_LOC,"/illumina_known_count_matrix.rds"))

full_counts             <- cbind(pb_counts, ont_counts, illumina_counts)  
names(full_counts)      <- c("s1_pacbio", "s2_pacbio", "s3_pacbio","s4_pacbio","s5_pacbio", "s6_polyA_pacbio", 
                        "s1_ont", "s2_ont", "s3_ont","s4_ont","s5_ont", "s6_polyA_ont", "unclassified_ont",
                        "s1_illumina", "s2_illumina", "s3_illumina","s4_illumina","s5_illumina", "s5_illumina__2", "s6_polyA_illumina")
full_counts$s5_illumina <- full_counts$s5_illumina + full_counts$s5_illumina__2

# ggscatter(full_counts,
#           x = "s1_pacbio",
#           y = "s1_ont",
#           rug = TRUE,                                # Add marginal rug
#           palette = "jco") +
#   stat_cor(method = "spearman")
# 
# ggscatter(full_counts,
#           x = "s1_ont",
#           y = "s1_illumina",
#           rug = TRUE,                                # Add marginal rug
#           palette = "jco") +
#   stat_cor(method = "spearman")

long_full_counts        <- melt(as.matrix(full_counts))
long_full_counts$sample <- factor(gsub("\\_.*", "",long_full_counts$Var2))
long_full_counts$tech   <- factor(gsub(".*\\_", "",long_full_counts$Var2))
long_full_counts <- long_full_counts[, c(1, 3:5)]
long_full_counts <- long_full_counts[long_full_counts$sample!="unclassified", ]
long_full_counts$sample <- factor(long_full_counts$sample)
long_full_counts$logcpm <- log2(edgeR::cpm(long_full_counts$value + 1))

wide_full_counts <- dcast(long_full_counts, Var1+sample ~ tech, value.var = "logcpm")

ggscatter(wide_full_counts, x = "pacbio", y = c("ont"), size = 0.3,
          combine = TRUE, ylab = "ONT", xlab ="PacBio",
          color = "sample", palette = "jco", scales = "free_y", rug = TRUE,
          add = "reg.line", conf.int = TRUE) +
  stat_cor(aes(color = sample), method = "spearman", label.y.npc = "top", label.x.npc = "left", size = 7) +
  theme(axis.text=element_text(size=14),
        axis.title=element_text(size=16,face="bold"),
        axis.text.x = element_text(vjust = 0.5, hjust=1),
        legend.title = element_text(size=14),
        legend.text = element_text(size=14))

ggscatter(wide_full_counts, x = "pacbio", y = c("illumina"), size = 0.3,
          combine = TRUE, ylab = "Illumina", xlab ="PacBio",
          color = "sample", palette = "jco", scales = "free_y", rug = TRUE,
          add = "reg.line", conf.int = TRUE) +
  stat_cor(aes(color = sample), method = "spearman", label.y.npc = "top", label.x.npc = "left", size = 7) +
  theme(axis.text=element_text(size=14),
        axis.title=element_text(size=16,face="bold"),
        axis.text.x = element_text(vjust = 0.5, hjust=1),
        legend.title = element_text(size=14),
        legend.text = element_text(size=14))

ggscatter(wide_full_counts, x = "ont", y = c("illumina"), size = 0.3,
          combine = TRUE, ylab = "Illumina", xlab = "ONT",
          color = "sample", palette = "jco", scales = "free_y", rug = TRUE,
          add = "reg.line", conf.int = TRUE) +
  stat_cor(aes(color = sample), method = "spearman", label.y.npc = "top", label.x.npc = "left", size = 7) +
  theme(axis.text=element_text(size=14),
        axis.title=element_text(size=16,face="bold"),
        axis.text.x = element_text(vjust = 0.5, hjust=1),
        legend.title = element_text(size=14),
        legend.text = element_text(size=14))


# venn diagram values from known gff matches
# --------------------------------------------------------

pb_counts  <- readRDS(paste0(OUT_LOC,"/pb_known_count_matrix.rds"))
ont_counts <- readRDS(paste0(OUT_LOC,"/ont_known_count_matrix.rds"))
illumina_counts <- readRDS(paste0(OUT_LOC,"/illumina_known_count_matrix.rds"))

# for pb, what genes don't have 0 counts?
pb_counts_genes <- row.names(pb_counts[rowSums(pb_counts) >0, ])
# for ont, what genes don't have 0 counts?
ont_counts_genes <- row.names(ont_counts[rowSums(ont_counts) >0, ])
# for illumina, what genes don't have 0 counts?
illumina_counts_genes <- row.names(illumina_counts[rowSums(illumina_counts) >0, ])

str(setdiff(pb_counts_genes, ont_counts_genes))
str(setdiff(ont_counts_genes, pb_counts_genes))

str(intersect(pb_counts_genes, ont_counts_genes))


str(setdiff(pb_counts_genes, illumina_counts_genes))
str(setdiff(illumina_counts_genes, pb_counts_genes))

str(intersect(pb_counts_genes, illumina_counts_genes))

str(setdiff(ont_counts_genes, illumina_counts_genes))
str(setdiff(illumina_counts_genes, ont_counts_genes))

str(intersect(ont_counts_genes, illumina_counts_genes))

# find overlap
library(VennDiagram)

venn_overlap <- VennDiagram::calculate.overlap(list(pb_counts_genes, ont_counts_genes, illumina_counts_genes))
str(venn_overlap)

# sequin proportions compared to known gff annotation counts
# -----------------------------------------------------------

# I again amnually created a .csv file using the stats from featurecounts

sequin_summary <- read.csv("known_gene_vs_sequins_summarised.csv", header = TRUE)	  
head(sequin_summary)

#calculate percentages
edited_sequin_summary <- sequin_summary %>% dplyr::group_by(tech, sample) %>% mutate(prop = (count/sum(count) * 100))
edited_sequin_summary$fill_col <- factor(paste0(edited_sequin_summary$tech,"_", edited_sequin_summary$cat))
edited_sequin_summary$tech <- factor(edited_sequin_summary$tech, levels=c("pacbio", "ont", "illumina"))

ggbarplot(edited_sequin_summary[edited_sequin_summary$cat!="assigned_known", ], 
          x = "sample", 
          y = "count", 
          fill = "tech",
          lab.size = 10,
          palette ="jco",
          position = position_dodge2()) + 
  xlab("Technology") +
  ylab("Nuber of reads assinged to sequins") +
  theme(axis.text=element_text(size=14),
        axis.title=element_text(size=16,face="bold"),
        axis.text.x = element_text(vjust = 0.5, hjust=1),
        legend.title = element_text(size=14),
        legend.text = element_text(size=14))


#

