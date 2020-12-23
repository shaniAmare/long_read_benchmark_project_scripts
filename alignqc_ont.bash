#!/bin/bash
# run alignQC on ont data
# Author: Shani Amarasinghe
# Date: 01/10/2020
#PBS -l nodes=1:ppn=8,mem=80gb
#PBS -l walltime=50:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N alignqc_ont

module load anaconda2

cd /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/alignqc/
source activate alignqc

module load samtools/1.7

#REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/genome_rnasequin_decoychr_2.4_chr_edited.fa" 
REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/atac-seq/20190529_MiRCL_ATAC/references/genome.fa"

mkdir "/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/alignqc_output/ont"
OUT_DIR="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/alignqc_output/ont"

# full BAM files took forever - so trying on the subsample
IN_LOC_ONT="/stornext/General/data/user_managed/grpu_mritchie_1/XueyiDong/long_read_benchmark/ONT/bam_subsample"

find ${IN_LOC_ONT} -name '*.bam' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.sorted*};
echo " ######## --------- processing $BAM in $OUT_P -------- #########################";
seq-tools sort --bam ${BAM} -o ${BAM}.sorted.bam;
samtools index ${BAM}.sorted.bam;
mkdir ${OUT_DIR}/${OUT_P};
echo " ######## --------- results saved in $OUT_DIR/$OUT_P -------- #########################";
alignqc analyze ${BAM}.sorted.bam -g ${REFERENCE} --no_transcriptome --threads 8 --specific_tempdir ${OUT_DIR}/${OUT_P} -o ${OUT_DIR}/${OUT_P}/${OUT_P}.ont.alignqc.xhtml
done

# testing the memory issue:
IN_LOC_ONT="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/alignqc/ont_bam_subsample/"
OUT_DIR="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/alignqc/ont_bam_subsample/"

find ${IN_LOC_ONT} -name 'barcode01*.bam' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.sorted*};
echo " ######## --------- processing $BAM in $OUT_P -------- #########################";
seq-tools sort --bam ${BAM} -o ${BAM}.sorted.bam;
samtools index ${BAM}.sorted.bam;
mkdir ${OUT_DIR}/${OUT_P};
echo " ######## --------- results saved in $OUT_DIR/$OUT_P -------- #########################";
alignqc analyze ${BAM}.sorted.bam -g ${REFERENCE} --no_transcriptome --threads 8 --specific_tempdir ${OUT_DIR}/${OUT_P} -o ${OUT_DIR}/${OUT_P}/${OUT_P}.ont.alignqc.xhtml
done

# find ${IN_LOC_ONT} -name 'barcode05*.bam' -print0 | while IFS= read -r -d '' BAM
# do 
# OUT_P=${BAM##*/};OUT_P=${OUT_P%%.sorted*};
# echo " ######## --------- processing $BAM in $OUT_P -------- #########################";
# mkdir ${OUT_DIR}/${OUT_P};
# echo " ######## --------- results saved in $OUT_DIR/$OUT_P -------- #########################";
# alignqc analyze ${BAM} -g ${REFERENCE} --no_transcriptome --threads 8 --specific_tempdir ${OUT_DIR}/${OUT_P} -o ${OUT_DIR}/${OUT_P}/${OUT_P}.ont.alignqc.xhtml
# done

#exit