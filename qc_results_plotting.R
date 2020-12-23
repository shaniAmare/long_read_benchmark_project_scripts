#'
#' Generating figures for samtools derived data
#' for pacbio data
#' author: S. Amarasinghe
#' date: 31th July 2020
#'

# prerequisites -----------------

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
library("here")
library("ggpubr")
library("ggsci")

# i/o ---------------------------

# LOC <- "/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/rl_np_rq"
LOC <- "Z:/Shani/long_read_benchmark/rl_np_rq"

qc_files <- list.files(path=c(LOC), 
                       pattern=".tsv$", full=TRUE)
names(qc_files) <- sub("\\..*", "", 
                       basename(qc_files))


qc_stats <- lapply(qc_files, function(file) {
  stats <- read.table(file, header = FALSE, sep = "\t")
  colnames(stats) <- c("read_length", "np", "read_quality")
  return(stats)
})

names(qc_stats) <- names(qc_files)

qc_stats_df <- bind_rows(qc_stats, .id = "meta_information")
qc_stats_df$meta_information <- factor(qc_stats_df$meta_information)
qc_stats_df$log_read_quality <- log2(as.numeric(qc_stats_df$read_quality))
qc_stats_df$log_read_length <- log2(as.numeric(qc_stats_df$read_length))


density_rl <- ggpubr::gghistogram(qc_stats_df, 
                                  x = "log_read_length",
                                  y = "..density..", 
                                  color = "meta_information", 
                                  palette = "npg",
                                  alpha = 0.4,
                                  size = 3.5,
                                  rug = TRUE)

density_rl


density_np <- ggpubr::ggdensity(qc_stats_df, 
                                "np",
                                color = "meta_information", 
                                palette = "npg",
                                alpha = 0.4,
                                size = 3.5,
                                rug = TRUE)

density_np

density_rq <- ggpubr::ggdensity(qc_stats_df, 
                                "read_quality",
                                color = "meta_information", 
                                palette = "npg",
                                alpha = 0.4,
                                size = 3.5,
                                rug = TRUE)

density_rq



ggpubr::ggscatter(qc_stats[[1]], 
                  x = "np",
                  y = "log_read_length", 
                  facet.by = "meta_information",
                  color = "meta_information",
                  palette = "jco",
                  size = 2, 
                  alpha = 0.6,
                  rug = TRUE)

############# qc plots for idx stats form samtools --------------

# ccs files

LOC <- "Z:/Shani/long_read_benchmark/"
idx_ccs <- read.table(here("bamstats_ccs.tab"), header = FALSE, sep = "\t")
names(idx_ccs) <- c("sample", "v2", "v3", "v4", "counts")
idx_ccs$label  <- as.factor(c("S1R", "S2R", "S3R", "S4R", "S5R", "S5R_topup","S6R_topup", "S6R"))

idx_refined <- read.table(here("bamstats_refined_flnc.tab"), header = FALSE, sep = "\t")
names(idx_refined) <- c("sample", "v2", "v3", "v4", "counts")
idx_refined$label <- as.factor(c("S5R_topup", "S2R", "S6R_topup", "S3R", "S1R", "S6R", "S5R", "S4R"))

ggbarplot(idx_ccs,
          x = "label",
          y = "counts",
          fill = "label",
          palette = "jco",
          legend = "none",
          xlab = "sample",
          ylab = "number of reads")

ggbarplot(idx_refined,
          x = "label",
          y = "counts",
          fill = "label",
          palette = "jco",
          legend = "none",
          xlab = "sample",
          ylab = "number of reads")




