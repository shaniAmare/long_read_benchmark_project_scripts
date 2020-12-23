#!/bin/bash
# run picardtools collect insert size on pacbio data
# Author: Shani Amarasinghe
# Date: 31/07/2020
#PBS -l nodes=1:ppn=8,mem=80gb
#PBS -l walltime=50:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N insertsize_pacbio

# running in vc7-shared
module load python/3.7.0
module load samtools/1.7
modue load picard-tools/2.20.2
module load java/1.8.0_211

# define inputs
IN_LOC_CCS="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/02.ccs"
mkdir "/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/Picrad_InserSize"
OUT_F="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/Picrad_InserSize/"

# extract QC stats in a loop for all ccs BAM file
find "${IN_LOC_CCS}" -name "*bam" | while read BAM; 
do 
echo -ne "processing ${BAM}/n#############################################################/n";
OUT_P=${BAM##*/S};OUT_P=${OUT_P%%.bam};  OUT_P=$(echo $OUT_P | sed 's/\//_/g');
samtools view -H "${BAM}" | sed 's,^@RG.*,^@RG.*\tSM:None,g' |  samtools reheader - "${BAM}" > "${BAM}_edited.bam";
samtools index "${BAM}_edited.bam";
CollectInsertSizeMetrics I="${BAM}_edited.bam" \
O="${OUT_F}"_"${OUT_P}"_insert_size_metrics.txt \
H="${OUT_F}"_"${OUT_P}"_insert_size_histogram.pdf \
M=0.5;
echo "/n##############################################/n/n/n";
done
#
#
exit

