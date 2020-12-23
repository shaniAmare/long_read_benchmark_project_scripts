#!/bin/bash
# analyse pacbio data (collapse)
# Author: Shani Amarasinghe
# Date: 10/06/2020
#PBS -l nodes=1:ppn=8,mem=80gb
#PBS -l walltime=50:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N isoseq3_collapse

# running in vc7-shared
 
export PATH="$PATH:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/pacbio/smrtlink/smrtcmds/bin"

# define inputs
MAIN_LOC="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/06.a.aligned_merged_ref"
mkdir "/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/07.a.collapsed_merged_ref"
OUT_DIR="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/07.a.collapsed_merged_ref"
REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/genome_rnasequin_decoychr_2.4.fa"

# run collapse in a loop
find ${MAIN_LOC} -name '*.bam' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/};OUT_P=${OUT_P%%_clustered_aligned_to_merged_hg38.bam};
echo "#################### processing $BAM ##################################";
isoseq3 collapse \
${BAM} \
${OUT_DIR}/${OUT_P}_collapsed.fastq \
--log-file ${OUT_DIR}/${OUT_P}.log \
--log-level DEBUG
#################### complete $BAM ###################################";
done
