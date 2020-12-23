#!/bin/bash
# analyse pacbio data (align to human reference and sequins)
# Author: Shani Amarasinghe
# Date: 18/09/2020
#PBS -l nodes=1:ppn=8,mem=80gb
#PBS -l walltime=50:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N align_to_merged_hg38

# running in vc7-shared
 
export PATH="$PATH:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/pacbio/smrtlink/smrtcmds/bin"


# edit the reference file to contain the sequins
cat /stornext/General/data/user_managed/grpu_mritchie_1/Shani/atac-seq/20190529_MiRCL_ATAC/references/genome.fa \
/stornext/General/data/user_managed/grpu_mritchie_1/SCmixology/Mike_seqin/annotations/rnasequin_decoychr_2.4.fa \
> /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/genome_rnasequin_decoychr_2.4.fa

cat /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flames_output_merged/gencode.v29.annotation.gtf \
/stornext/General/data/user_managed/grpu_mritchie_1/SCmixology/Mike_seqin/annotations/rnasequin_annotation_2.4.gtf \
> /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/genome_rnasequin_decoychr_2.4.gtf

# define inputs
MAIN_LOC="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/05.clustering"
mkdir /stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/06.a.aligned_merged_ref
OUT_DIR="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/06.a.aligned_merged_ref"
REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/genome_rnasequin_decoychr_2.4.fa"

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
${OUT_DIR}/${OUT_P}_aligned_to_merged_hg38.bam \
--log-file ${OUT_DIR}/${OUT_P}.log \
--log-level DEBUG \
--preset ISOSEQ \
--sort;
echo "###################### complete $BAM ###################################";
done
