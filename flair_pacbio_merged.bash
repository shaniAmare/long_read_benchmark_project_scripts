#!/bin/bash
# running flair on pacbio merged bams
# Author: Shani Amarasinghe
# Date: 08/09/2020
#PBS -l nodes=1:ppn=8,mem=40gb
#PBS -q submit
#PBS -j oe
#PBS -l walltime=4:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N flair_merged

# running in unix500
module load python/3.7.0
module load samtools/1.7
module load R/3.6.1
module load perl
module load gmap-gsnap
module load bedtools

#export PATH=$PATH:/stornext/General/data/user_managed/grpu_mritchie_1/SCmixology/script/minimap2-2.17_x64-linux
#echo $PATH

# define inputs
MAIN_LOC="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/pacbio_collapsed_merged"
mkdir "/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flair_output_merged"
OUT_DIR="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flair_output_merged"
REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/atac-seq/20190529_MiRCL_ATAC/references/genome.fa"
SOURCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/Nanopore/flair/flair/flair.py"
SOURCE_BIN="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/Nanopore/flair/flair/bin/"
# not running flair align as the data alis already aligned by pbmm2 which aso uses minimap2 under the hood : No ran it.

python ${SOURCE} align \
-g ${REFERENCE} \
-r ${MAIN_LOC}/merged_clustered.fastq.gz \
-o ${OUT_DIR}/merged_clustered_new \
-m /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/minimap2/ \
--threads 8

# run flair bin/bam2Bed12.py
# need python module tqdm
samtools index ${MAIN_LOC}/merged_clustered.bam
python ${SOURCE_BIN}bam2Bed12.py -i ${MAIN_LOC}/merged_clustered.bam > ${OUT_DIR}/merged_clustered.bed12

# run flair correct
# Need the python modules Cython and kernaltree
#python ${SOURCE} correct -q ${OUT_DIR}/merged_clustered.bed12 -g ${REFERENCE} -f ${MAIN_LOC}/merged_clustered_collapsed.gff -o ${OUT_DIR}/flair_correct
#python ${SOURCE} correct -q ${OUT_DIR}/merged_clustered_new.bed -g ${REFERENCE} -f ${MAIN_LOC}/merged_clustered_collapsed.gff -o ${OUT_DIR}/flair_correct_new
# above workks, ut this gff generated from PacBio data is a very simple one
# testing the Gencode GFF
#ANNOT="/stornext/General/data/user_managed/grpu_mritchie_1/LuyiTian/Index/gencode.v33.annotation.gff3"
# so above gives the same python error meaning the gff file is the culprit here.

ANNOT="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flames_output_merged/gencode.v29.annotation.gtf"

python ${SOURCE} correct -q ${OUT_DIR}/merged_clustered_new.bed -g ${REFERENCE} -f ${ANNOT} -o ${OUT_DIR}/flair_correct_new
# above works - meaning the chr values match and then it should be fine.... hmmm what happened whn I tried it in flair_merged_new?


# run flair collapse
# need a .fasta/.fastq file for processing; bam2fasta from amrtlink (in vc7-shared)
bam2fasta -o ${MAIN_LOC}/merged_clustered ${MAIN_LOC}/merged_clustered.bam
# it also needs minimap2 in its path

export PATH=$PATH:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/minimap2
echo $PATH

# python ${SOURCE} collapse -r ${MAIN_LOC}/merged_clustered.fasta.gz -q ${OUT_DIR}/merged_clustered.bed12 -g ${REFERENCE} -o ${OUT_DIR}/flair_collapse
python ${SOURCE} collapse -r ${MAIN_LOC}/merged_clustered.fasta.gz -q ${OUT_DIR}/merged_clustered_new.bed -g ${REFERENCE} -o ${OUT_DIR}/flair_collapse_new

# run flair quantify
python ${SOURCE} quantify -r ${OUT_DIR}/reads_manifest.tsv -i ${OUT_DIR}/flair_collapse_new.isoforms.fa

# run flair mark_productivity.py
python ${SOURCE_BIN}predictProductivity.py -i ${OUT_DIR}/flair_collapse_new.isoforms.bed -f ${ANNOT} -g ${REFERENCE} --longestORF > ${OUT_DIR}/flair_new.productivity.bed

# python ${SOURCE_BIN}predictProductivity.py -i ${OUT_DIR}/flair_collapse.isoforms.d12 -g ${MAIN_LOC}/merged_clustered_collapsed.gff -f ${REFERENCE} --longestORF > ${OUT_DIR}/merged_clustered.productivity.bed
# #python ${SOURCE_BIN}mark_productivity.py  .psl -f ${MAIN_LOC}/merged_clustered_collapsed.gff -g ${REFERENCE} > .${OUT_DIR}/merged_clustered.productivity.psl
# python ${SOURCE_BIN}predictProductivity.py -i ${OUT_DIR}/flair_collapse.isoforms.d12 -g /stornext/General/data/user_managed/grpu_mritchie_1/LuyiTian/Index/gencode.v33.annotation.gff3 \
 # -f ${REFERENCE} --longestORF > ${OUT_DIR}/merged_clustered.productivity.bed

# # run flair intron_retention
# python ${SOURCE_BIN}mark_intron_retention.py  ${file} ./intron_retention/${prefix}.ir.psl ./intron_retention/${prefix}_coords.txt




