#!/bin/bash
# zipping large fastq files
# Author: Shani Amarasinghe
# Date: 09/09/2020
#PBS -l nodes=1:ppn=5,mem=100gb
#PBS -q submit
#PBS -j oe
#PBS -l walltime=4:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N gzip_fastq

# running in vc7-shared
# module load python/3.7.0
module load samtools/1.7
module load anaconda2/2019.10
#module load anaconda3

#PYTHONPATH="$PYTHONPATH:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/cDNA_Cupcake/sequence/:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/cDNA_Cupcake/"

cd /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/FLAMES
source activate FLAMES

#module load python/2.7
module load samtools/1.7
module load R/3.6.1
module load perl
module load gmap-gsnap
module load minimap2

#export PYTHONPATH=$PYTHONPATH:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/cDNA_Cupcake/sequence/:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/cDNA_Cupcake/
#echo $PYTHONPATH

export PATH=$PATH:/stornext/General/data/user_managed/grpu_mritchie_1/SCmixology/script/minimap2-2.17_x64-linux:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/FLAMES/python/:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/minimap2/misc/
echo $PATH

# first convert all the Raw bams to fastq (bedtools?)

MAIN_LOC="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/00.RawData"
mkdir /stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/PacBio_raw_fastq
OUT_DIR="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/PacBio_raw_fastq"

# find ${MAIN_LOC} -name '*.bam' -print0 | while IFS= read -r -d '' BAM
# do 
# OUT_P=${BAM##*/00.RawData/};OUT_P=${OUT_P%%.bam}; OUT_P=$(echo ${OUT_P} | tr '/' '_');
# echo "#################### processing $BAM as $OUT_P ##################################";
# #bamToFastq -i ${BAM} -fq ${OUT_DIR}/${OUT_P}.fastq;
# bgzip -c ${OUT_DIR}/${OUT_P}.fastq > ${OUT_DIR}/${OUT_P}.fastq.gz;
# echo "#################### completed $BAM as ${OUT_P}.fastq.gz ##################################";
# done

find ${OUT_DIR} -name '*.fastq' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.fastq};
echo "#################### processing $BAM as $OUT_P ##################################";
#bamToFastq -i ${BAM} -fq ${OUT_DIR}/${OUT_P}.fastq;
bgzip -c ${OUT_DIR}/${OUT_P}.fastq > ${OUT_DIR}/${OUT_P}.fastq.gz;
echo "#################### completed $BAM as ${OUT_P}.fastq.gz ##################################";
done

mkdir /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/raw_fastq
cp ${OUT_DIR}/*fastq /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/raw_fastq

#cp ${OUT_DIR}/*fastq.gz /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/raw_fastq

