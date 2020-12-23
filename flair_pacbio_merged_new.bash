#!/bin/bash
# running flair on pacbio merged bams
# Author: Shani Amarasinghe
# Date: 08/09/2020
#PBS -l nodes=1:ppn=8,mem=80gb
#PBS -q submit
#PBS -j oe
#PBS -l walltime=4:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N flair_new

# running in unix500
module load python/3.7.0
module load samtools/1.7
module load R/3.6.1
module load perl
module load gmap-gsnap
module load bedtools
module load minimap2/2.4

#export PATH=$PATH:/stornext/General/data/user_managed/grpu_mritchie_1/SCmixology/script/minimap2-2.17_x64-linux
#echo $PATH

# define inputs
MAIN_LOC="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/pacbio_collapsed_merged"
mkdir "/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flair_output_merged_new"
OUT_DIR="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flair_output_merged_new"
REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/LuyiTian/Index/GRCh38.primary_assembly.genome.fa"
# ANNOT="/stornext/General/data/user_managed/grpu_mritchie_1/LuyiTian/Index/gencode.v33.annotation.gff3"
ANNOT="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flames_output_merged/gencode.v29.annotation.edited.gtf"
SOURCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/Nanopore/flair/flair/flair.py"
SOURCE_BIN="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/Nanopore/flair/flair/bin/"

# run flair123
# python ${SOURCE} 123 \
# -r ${MAIN_LOC}/merged_clustered.fastq.gz \
# -g ${REFERENCE} \
# -f ${ANNOT} \
# -o ${OUT_DIR}/flair_merged_new \
# -temp_dir ${OUT_DIR}/temp_flair \
# --threads 8 \
# --psl

python ${SOURCE} align \
-g ${REFERENCE} \
-r ${MAIN_LOC}/merged_clustered.fastq.gz \
-o ${OUT_DIR}/flair_merged_new \
--temp_dir ${OUT_DIR}/temp_flair \
--threads 8

# samtools index ${OUT_DIR}/flair_merged_new.bam
python ${SOURCE_BIN}bam2Bed12.py -i ${OUT_DIR}/flair_merged_new.bam > ${OUT_DIR}/flair_merged_new.bed12


# get chromsizes
cut -f1,2 ${REFERENCE}.fai > ${OUT_DIR}/GRCh38.primary_assembly.genome.sizes.genome

python ${SOURCE_BIN}identify_gene_iso.py 

python ${SOURCE} correct \
-q ${OUT_DIR}/flair_merged_new.bed12 \
-g ${REFERENCE} \
-f ${ANNOT} \
-o ${OUT_DIR}/flair_correct

-c ${OUT_DIR}/GRCh38.primary_assembly.genome.sizes.genome \

python ${SOURCE} collapse \
-r ${MAIN_LOC}/merged_clustered.fasta.gz \
-q ${OUT_DIR}/flair_merged_new.bed12 \
-g ${REFERENCE} \
-o ${OUT_DIR}/flair_collapse \
--temp_dir ${OUT_DIR}/temp_flair \
--threads 8







