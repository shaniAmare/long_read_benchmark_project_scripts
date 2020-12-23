#!/bin/bash
# pacbio merge all bams and align to get the feel for the stats, etc.
# Author: Shani Amarasinghe
# Date: 31/07/2020
#PBS -l nodes=1:ppn=8,mem=80gb
#PBS -l walltime=50:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N pacbio_merge_all_bams_and_align

# running in vc7-shared
module load python/3.7.0
module load samtools/1.7

export PATH="$PATH:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/pacbio/smrtlink/smrtcmds/bin"

# previous steps collapsed below (ran out of memory)

##########################
# qsub -l nodes=1:ppn=1,pmem=80gb,walltime=4:00:00
# # isoseq3 clustering
# IN_LOC="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/04.refined"
# OUT_F="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/merged_analysis"
# # generate the merge file name file for all samples
# find "${IN_LOC}" -name "*.bam" | while read BAM 
# do 
# ls ${BAM} >> ${OUT_F}/merged_flnc.fofn
# done
# isoseq3 cluster ${OUT_F}/merged_flnc.fofn ${OUT_F}/merged_clustered.bam --verbose --use-qvs
# #pbmm2 aligning
# MAIN_LOC="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/merged_analysis"
# OUT_DIR="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/merged_analysis"
# REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/atac-seq/20190529_MiRCL_ATAC/references/genome.fa"
# # run pbmm2 align module
# pbmm2 --version
# # 1.1.0
# # run pbmm2 in a loop
# find ${MAIN_LOC} -name '*_clustered.bam' -print0 | while IFS= read -r -d '' BAM
# do 
# OUT_P=${BAM##*/};OUT_P=${OUT_P%%.bam};
# echo "#################### processing $BAM ##################################";
# pbmm2 align \
# ${REFERENCE} \
# ${BAM} \
# ${OUT_DIR}/${OUT_P}_aligned_to_hg38.bam \
# --log-file ${OUT_DIR}/${OUT_P}.log \
# --log-level DEBUG \
# --preset ISOSEQ \
# --sort;
# echo "###################### complete $BAM ###################################";
# done
# # run collapse in a loop
# find ${MAIN_LOC} -name '*aligned_to_hg38.bam' -print0 | while IFS= read -r -d '' BAM
# do 
# OUT_P=${BAM##*/};OUT_P=${OUT_P%%_clustered_aligned_to_hg38.bam};
# echo "#################### processing $BAM ##################################";
# isoseq3 collapse \
# ${BAM} \
# ${OUT_DIR}/${OUT_P}_collapsed.fastq \
# --log-file ${OUT_DIR}/${OUT_P}.log \
# --log-level DEBUG
# #################### complete $BAM ###################################";
# done
##############################

# merge aligned files first

samtools merge \
/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/merged_analysis/merged_clustered.bam \
/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/06.aligned/*.bam

# index it
pbindex /stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/merged_analysis/merged_clustered.bam

# next collapse

BAM="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/merged_analysis/merged_clustered.bam"
OUT_DIR="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/merged_analysis/"

isoseq3 collapse ${BAM} \
${OUT_DIR}/merged_clustered_collapsed.fastq \
--log-file ${OUT_DIR}/merged_clustered.log \
--log-level DEBUG

# run sqanti on it

cp /stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/merged_analysis/* \
/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/pacbio_collapsed_merged/

# define inputs
MAIN_LOC="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/pacbio_collapsed_merged"
mkdir "/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/sqanti_output_merged"
OUT_DIR="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/sqanti_output_merged"

REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/atac-seq/20190529_MiRCL_ATAC/references/genome.fa"
# REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/Index/GRCh38.primary_assembly.genome.fa"

# run sqanti_qc.py version
python sqanti3_qc.py --version
# SQANTI3 1.0.0

# run sqanti_qc.py
find ${MAIN_LOC} -name '*.fasta' -print0 | while IFS= read -r -d '' FASTA
do 
GFF=${FASTA%%.fasta}; GFF=${GFF}.gff;
FL=${FASTA%%.fasta}; FL=${FL}.abundance.txt;
OUT_P=${FASTA##*/};OUT_P=${OUT_P%%.fasta};
echo "#################### processing $FASTA ##################################";
echo "#################### using annotation $GFF ##############################";
echo "#################### using fl_count $FL ##############################";
echo "#################### saving as $OUT_P ###################################";
python sqanti3_qc.py \
--output ${OUT_P} \
--dir ${OUT_DIR} \
--fl_count ${FL} \
${FASTA} \
${GFF} \
${REFERENCE};
echo "#################### complete $FASTA ###################################";
done
