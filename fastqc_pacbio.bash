#!/bin/bash
# run fastqc on pacbio data
# Author: Shani Amarasinghe
# Date: 10/06/2020
#PBS -l nodes=1:ppn=8,mem=24gb
#PBS -l walltime=10:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N fastqc_pacbio

# running in vc7-shared

# load module
module load fastqc/0.11.8

# define inputs
MAIN_LOC="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/00.RawData/"
mkdir /stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/fastqc 2> /dev/null;
OUT_DIR="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/fastqc/"
mkdir /stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/fastqc/tmp 2> /dev/null;
TMP="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/fastqc/tmp/"

# run fastqc in a loop
for subdir in S1R S2R S3R S4R S5R
do
mkdir /stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/fastqc/${subdir} 2> /dev/null;
BAM=${MAIN_LOC}/${subdir}/m64087_200413_100303.subreads.bam
fastqc -o ${OUT_DIR}/${subdir} --extract --format bam ${BAM} -d ${TMP} -t 8
done
