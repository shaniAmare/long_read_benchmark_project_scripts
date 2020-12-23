#!/bin/bash
# run alignQC on pacbio data
# Author: Shani Amarasinghe
# Date: 17/06/2020
#PBS -l nodes=1:ppn=8,mem=80gb
#PBS -l walltime=50:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N alignqc_pacbio

# running in vc7-shared

# install alignQC
# pip install --user AlignQC # doesn't work
# conda create -n alignqc -c vacation AlignQC 

source activate alignqc
# Load it into path
# export PATH="$PATH:/home/users/allstaff/amarasinghe.s/.local/bin"


# define inputs
IN_LOC_RAW="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/00.RawData/"
IN_LOC_CCS="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/02.ccs/"

# set IN_LOC_RAW="U:\lab_ritchie\transcr_bench_PacBio\long_term\H201SC20030389\00.RawData"
# set IN_LOC_CCS="U:\lab_ritchie\transcr_bench_PacBio\long_term\H201SC20030389\02.ccs"
# mkdir "Z:\Shani\long_read_benchmark\alignqc"
# set OUT_DIR="Z:\Shani\long_read_benchmark\alignqc"


# quick script to run AlignQC
# source @ https://github.com/jason-weirather/AlignQC
# alignqc analysis long_reads.bam --no_genome --no_transcriptome -o long_reads.alignqc.xhtml

# run alignQC in a loop for all raw BAM files

mkdir "/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/alignqc_output/pacbio_subreads/"
OUT_DIR="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/alignqc_output/pacbio_subreads"
REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/genome_rnasequin_decoychr_2.4.fa"
GTF="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/genome_rnasequin_decoychr_2.4.gtf"

for subdir in S1R S2R S3R S4R S5R
do
BAM=${IN_LOC_RAW}/${subdir}/m64087_200413_100303.subreads.bam;
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.subreads.bam};
echo " ######## --------- processing $BAM in $subdir as $OUT_P -------- #########################";
#alignqc analyze ${BAM} -g {REFERENCE} -t ${GTF}.gz --threads 8 --specific_tempdir ${OUT_DIR} -o ${OUT_DIR}/${subdir}.${OUT_P}.subreads.alignqc.xhtml
mkdir ${OUT_DIR}/${subdir};
alignqc analyze ${BAM} --no_genome --no_transcriptome --threads 8 --specific_tempdir ${OUT_DIR}/${subdir} -o ${OUT_DIR}/${subdir}/${OUT_P}.subreads.alignqc.xhtml
done


alignqc analyze /stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/00.RawData/S5R/m64087_200413_100303.subreads.bam \
--no_genome --no_transcriptome --threads 8 --specific_tempdir ${OUT_DIR}/${subdir} -o ${OUT_DIR}/${subdir}/${OUT_P}.subreads.alignqc.xhtml

# alignqc analyze "U:\lab_ritchie\transcr_bench_PacBio\long_term\H201SC20030389\00.RawData\S1R\m64087_200413_100303.subreads.bam" --no_genome --no_transcriptome --specific_tempdir "Z:\Shani\long_read_benchmark\alignqc" -o "Z:\Shani\long_read_benchmark\alignqc\S1R.m64087_200413_100303.raw.alignqc.xhtml" --rscript_path "C:\Program Files\R\R-4.0.0\bin\Rscript"

# run alignQC in a loop for ccs BAM files
for subdir in S1R S2R S3R S4R S5R
do
BAM=${IN_LOC_CCS}/${subdir}/m64087_200413_100303.subreads.bam
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.subreads.bam};
alignqc analyze ${BAM} --no_genome --no_transcriptome --threads 8 --specific_tempdir ${OUT_DIR} -o ${OUT_DIR}/${subdir}.${OUT_P}.ccs.alignqc.xhtml
done

# for the merged pacbio bam file
OUT_DIR="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/alignqc_output/pacbio_merged"
REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/atac-seq/20190529_MiRCL_ATAC/references/genome.fa"
alignqc analyze /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/pacbio_collapsed_merged/merged_clustered.bam \
-g ${REFERENCE} --no_transcriptome --threads 8 --specific_tempdir ${OUT_DIR} -o ${OUT_DIR}/pacbio_merged.alignqc.xhtml

# for the bams with merged references/genome
#IN_LOC="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/pacbio_collapsed_merged_ref"
IN_LOC="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/06.a.aligned_merged_ref"
REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/genome_rnasequin_decoychr_2.4.fa"
GTF="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/genome_rnasequin_decoychr_2.4.gtf"
mkdir "/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/alignqc_output/pacbio_merged_ref"
OUT_DIR="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/alignqc_output/pacbio_merged_ref"

module load samtools/1.7

find ${IN_LOC} -name '*.bam' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/};OUT_P=${OUT_P%%_clustered*};
echo " ######## --------- processing $BAM in $OUT_P -------- #########################";
seq-tools sort --bam ${BAM} -o ${BAM}.sorted.bam;
samtools index ${BAM}.sorted.bam;
echo " ######## --------- successfully sorted $BAM.sorted.bam -------- #########################";
#alignqc analyze ${BAM} -g {REFERENCE} -t ${GTF}.gz --threads 8 --specific_tempdir ${OUT_DIR} -o ${OUT_DIR}/${subdir}.${OUT_P}.subreads.alignqc.xhtml
mkdir ${OUT_DIR}/${OUT_P};
echo " ######## --------- processing sorted $BAM.sorted.bam and reults saved in $OUT_DIR/$OUT_P -------- #########################";
alignqc analyze ${BAM}.sorted.bam -g ${REFERENCE} --no_transcriptome --threads 8 --specific_tempdir ${OUT_DIR}/${OUT_P} -o ${OUT_DIR}/${OUT_P}/${OUT_P}.merged_ref.alignqc.xhtml
done

# trying on ONT data from Xueyi
REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/genome_rnasequin_decoychr_2.4.fa"
# the bam file contains chr chromosomes. so I need to edit te chrosmooome from the reference first
perl -p -e 's/^>(.*)/>chr$1/' ${REFERENCE} > /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/genome_rnasequin_decoychr_2.4_chr.fa
perl -p -e 's/^>chrchr(.*)/>chr$1/' /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/genome_rnasequin_decoychr_2.4_chr.fa > /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/genome_rnasequin_decoychr_2.4_chr_edited.fa

IN_LOC_ONT="/stornext/General/data/user_managed/grpu_mritchie_1/XueyiDong/long_read_benchmark/ONT/bam"
REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/genome_rnasequin_decoychr_2.4_chr_edited.fa" 
mkdir "/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/alignqc_output/ont"
OUT_DIR="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/alignqc_output/ont"

# fill BAM files tookforever - so trying on the subsampl
IN_LOC_ONT="/stornext/General/data/user_managed/grpu_mritchie_1/XueyiDong/long_read_benchmark/ONT/bam_subsample"


find ${IN_LOC_ONT} -name '*.bam' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.sorted*};
echo " ######## --------- processing $BAM in $OUT_P -------- #########################";
mkdir ${OUT_DIR}/${OUT_P};
echo " ######## --------- results saved in $OUT_DIR/$OUT_P -------- #########################";
alignqc analyze ${BAM} -g ${REFERENCE} --no_transcriptome --threads 8 --specific_tempdir ${OUT_DIR}/${OUT_P} -o ${OUT_DIR}/${OUT_P}/${OUT_P}.ont.alignqc.xhtml
done



## aaarcgh@=! alignQC does not well work with the server. Cannot get it to work on my local machine either!
# gave up

# trying multiqc now in python 3.7

# run multiQC in a loop for all raw BAM files
# for subdir in S1R S2R S3R S4R S5R
# do
# BAM=${IN_LOC_RAW}${subdir}/
# cd ${BAM}
# multiqc ./
# done

# realised multiqc will generate plots for the analysis done - so no use!!!!
