#!/bin/bash
# run refine step on pacbio adapter_removed bam files
# Author: Shani Amarasinghe
# Date: 09/07/2020
#PBS -l nodes=1:ppn=8,mem=80gb
#PBS -l walltime=50:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N refine_pacbio

# running in vc7-shared
module load python/3.7.0
module load samtools/1.7

export PATH="$PATH:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/pacbio/smrtlink/smrtcmds/bin"

# define inputs
IN_LOC="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/03.adapter_removed"
OUT_F="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/04.refined"
PRIMERS="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/IsoSeqPrimers_new.fasta"

# use lima in a loop for all ccs BAM file
find "${IN_LOC}" -name "*.bam" | while read BAM 
do 
echo "processing ${BAM}/n";
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.bam};  OUT_P=$(echo $OUT_P | sed 's/\//_/g');
echo "producing ${OUT_F}/${OUT_P}_flnc.bam";
isoseq3 refine ${BAM} ${PRIMERS} ${OUT_F}/${OUT_P}_flnc.bam \
--log-level DEBUG \
--log-file ${OUT_F}/${OUT_P}.log \
--num-threads 8 
done

# only for polyA ccs files in 6R_polyA
find "${IN_LOC}" -name "6R*.bam" | while read BAM 
do 
echo "processing ${BAM}/n";
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.bam};  OUT_P=$(echo $OUT_P | sed 's/\//_/g');
echo "producing ${OUT_F}/${OUT_P}_flnc.bam";
isoseq3 refine ${BAM} ${PRIMERS} ${OUT_F}/${OUT_P}_flnc.bam \
--log-level DEBUG \
--log-file ${OUT_F}/${OUT_P}.log \
--num-threads 8 \
--require-polya \
--min-polya-length 20 
done
#
exit
