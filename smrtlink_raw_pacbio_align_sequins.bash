#!/bin/bash
# analyse pacbio data (align raw reads to sequins)
# Author: Shani Amarasinghe
# Date: 09/09/2020
#PBS -l nodes=1:ppn=8,mem=80gb
#PBS -l walltime=50:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N align_to_sequins_raw

# running in vc7-shared
 
export PATH="$PATH:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/pacbio/smrtlink/smrtcmds/bin"

# define inputs
MAIN_LOC="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/00.RawData"
mkdir /stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/raw_aligned_sequins
OUT_DIR="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/raw_aligned_sequins"
REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/SCmixology/Mike_seqin/annotations/rnasequin_decoychr_2.4.fa"

# run pbmm2 align module
pbmm2 --version
# 1.1.0 (commit SL-release-8.0.0)

# run pbmm2 in a loop
find ${MAIN_LOC} -name '*.bam' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/00.RawData/};OUT_P=${OUT_P%%.bam}; OUT_P=$(echo ${OUT_P} | tr '/' '_');
echo "#################### processing $BAM as $OUT_P ##################################";
pbmm2 align \
${REFERENCE} \
${BAM} \
${OUT_DIR}/${OUT_P}_aligned_to_sequins.bam \
--log-file ${OUT_DIR}/${OUT_P}.log \
--log-level DEBUG \
--sort;
echo "###################### complete $BAM ###################################";
done
