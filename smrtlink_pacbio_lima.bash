#!/bin/bash
# run lima on pacbio ccs
# Author: Shani Amarasinghe
# Date: 17/06/2020
#PBS -l nodes=1:ppn=8,mem=80gb
#PBS -l walltime=50:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N lima_pacbio

# running in vc7-shared
module load python/3.7.0
module load samtools/1.7

export PATH="$PATH:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/pacbio/smrtlink/smrtcmds/bin"

# define inputs
IN_LOC_CCS="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/02.ccs"
OUT_F="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/03.adapter_removed"
PRIMERS="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/IsoSeqPrimers_new.fasta"

# use lima in a loop for all ccs BAM file
find "${IN_LOC_CCS}" -name "*.bam" | while read BAM 
do 
echo "processing ${BAM}";
OUT_P=${BAM##*/S};OUT_P=${OUT_P%%.bam};  OUT_P=$(echo $OUT_P | sed 's/\//_/g');
lima ${BAM} ${PRIMERS} ${OUT_F}/${OUT_P}.bam \
--per-read \
--isoseq \
--num-threads 8 \
--peek-guess \
--log-level DEBUG \
--log-file ${OUT_F}/${OUT_P}.log
done
#
exit
