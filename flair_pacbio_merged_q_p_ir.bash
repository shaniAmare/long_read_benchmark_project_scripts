#!/bin/bash
# running flair quantify on pacbio merged bams
# Author: Shani Amarasinghe
# Date: 08/09/2020
#PBS -l nodes=1:ppn=8,mem=40gb
#PBS -q submit
#PBS -j oe
#PBS -l walltime=100:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N flair_quantify_productivity_ir

# running in unix500
module load python/3.7.0
module load samtools/1.7
module load R/3.6.1
module load perl
module load gmap-gsnap
module load bedtools

# define inputs
MAIN_LOC="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/pacbio_collapsed_merged"
mkdir "/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flair_output_merged"
OUT_DIR="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flair_output_merged"
REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/atac-seq/20190529_MiRCL_ATAC/references/genome.fa"
SOURCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/Nanopore/flair/flair/flair.py"
SOURCE_BIN="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/Nanopore/flair/flair/bin/"
ANNOT="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flames_output_merged/gencode.v29.annotation.gtf"

export PATH=$PATH:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/minimap2
echo $PATH

# run flair quantify
python ${SOURCE} quantify \
-r ${OUT_DIR}/reads_manifest.tsv \
-i ${OUT_DIR}/flair_collapse_new.isoforms.fa \
-m /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/minimap2/ \
--threads 8 \
--trust_ends \
--temp_dir ${OUT_DIR}/temp_flair

# run flair mark_productivity.py
python ${SOURCE_BIN}predictProductivity.py \
-i ${OUT_DIR}/flair_collapse_new.isoforms.bed \
-g ${ANNOT} \
-f ${REFERENCE} \
--longestORF > ${OUT_DIR}/flair_new.productivity.bed

# run flair intron_retention
python ${SOURCE_BIN}mark_intron_retention.py  \
${OUT_DIR}/flair_collapse_new.isoforms.bed \
${OUT_DIR}/flair_new.ir.psl \
${OUT_DIR}/flair_new.out_introns.txt




