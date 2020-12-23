#!/bin/bash
# analyse pacbio data (align to human reference)
# Author: Shani Amarasinghe
# Date: 10/06/2020
#PBS -l nodes=1:ppn=8,mem=80gb
#PBS -l walltime=50:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N align_to_hg38

# running in vc7-shared
 
export PATH="$PATH:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/pacbio/smrtlink/smrtcmds/bin"

# define inputs
MAIN_LOC="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/05.clustering"
OUT_DIR="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/06.aligned"
REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/atac-seq/20190529_MiRCL_ATAC/references/genome.fa"

# run pbmm2 align module
pbmm2 --version
# 1.1.0

# run pbmm2 in a loop
find ${MAIN_LOC} -name '*_clustered.bam' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.bam};
echo "#################### processing $BAM ##################################";
pbmm2 align \
${REFERENCE} \
${BAM} \
${OUT_DIR}/${OUT_P}_aligned_to_hg38.bam \
--log-file ${OUT_DIR}/${OUT_P}.log \
--log-level DEBUG \
--preset ISOSEQ \
--sort;
echo "###################### complete $BAM ###################################";
done
