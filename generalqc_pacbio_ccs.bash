#!/bin/bash
# run QC stats on pacbio data
# Author: Shani Amarasinghe
# Date: 17/06/2020
#PBS -l nodes=1:ppn=8,mem=80gb
#PBS -l walltime=50:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N QC_pacbio

# running in vc7-shared
module load python/3.7.0
module load samtools/1.7

# define inputs
IN_LOC_CCS="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/02.ccs"
OUT_F="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/CCS_rl_np_rq"

# extract QC stats in a loop for all ccs BAM file
find "${IN_LOC_CCS}" -name "*bam" | while read BAM; 
do 
OUT_P=${BAM##*/S};OUT_P=${OUT_P%%.bam};  OUT_P=$(echo $OUT_P | sed 's/\//_/g');
samtools view "${BAM}" | awk -v OFS="\t" '{gsub("[np:i|rq:f]","",$0); {print length($10),$15,$16}}' > "${OUT_F}"_"${OUT_P}".tsv
done
#

find "${IN_LOC_CCS}" -name "6R*.bam" | while read BAM 
do 
OUT_P=${BAM##*/S};OUT_P=${OUT_P%%.bam};  OUT_P=$(echo $OUT_P | sed 's/\//_/g');
samtools view "${BAM}" | awk -v OFS="\t" '{gsub("[np:i|rq:f]","",$0); {print length($10),$15,$16}}' > "${OUT_F}"_"${OUT_P}".tsv
done
exit

