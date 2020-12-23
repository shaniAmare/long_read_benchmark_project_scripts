#!/bin/bash
# analyse pacbio data (ccs)
# Author: Shani Amarasinghe
# Date: 10/06/2020
#PBS -l nodes=1:ppn=8,mem=80gb
#PBS -l walltime=50:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N ccs_pacbio

# running in vc7-shared

#qsub -I -V -A ccs_pb -q ccs -l nodes=1:ppn=10,pmem=100gb,walltime=50:00:00,qos=ccs
#qsub -I -V -A amarasinghe.s -l nodes=1:ppn=8,pmem=80gb,walltime=100:00:00
 
export PATH="$PATH:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/pacbio/smrtlink/smrtcmds/bin"


# define inputs
MAIN_LOC="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/00.RawData/"
mkdir /stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/02.ccs 2> /dev/null;
OUT_DIR="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/02.ccs"

# run ccs module
ccs --version

# run ccs in a loop
for subdir in S1R S2R S3R S4R S5R
do
mkdir ${OUT_DIR}/${subdir} 2> /dev/null;
BAM=${MAIN_LOC}/${subdir}/m64087_200413_100303.subreads.bam
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.subreads.bam};
ccs ${BAM} ${OUT_DIR}/${subdir}/${OUT_P}.ccs.bam --min-rq 0.95 --num-threads 0 --report-file ${OUT_DIR}/${subdir}/${OUT_P}.report --log-level DEBUG --log-file ${OUT_DIR}/${subdir}/${OUT_P}.log #minimum prediction accuracy to be 0.9
done
