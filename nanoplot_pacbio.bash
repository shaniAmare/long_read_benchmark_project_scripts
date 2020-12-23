#!/bin/bash
# run nanoPlot on pacbio data
# Author: Shani Amarasinghe
# Date: 11/06/2020
#PBS -l nodes=1:ppn=8,mem=24gb
#PBS -l walltime=10:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N nanoplot_pacbio

# running in vc7-shared

# load modules
module load python/3.7.0

# pip install NanoPlot --user --upgrade
# saved PATH = "/home/users/allstaff/amarasinghe.s/.local/bin"
# add it to path
export PATH="$PATH:/home/users/allstaff/amarasinghe.s/.local/bin/"

# define inputs
MAIN_LOC="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/00.RawData/"
mkdir /stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/nanoPlot 2> /dev/null;
OUT_DIR="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/nanoPlot/"
mkdir /stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/nanoPlot/tmp 2> /dev/null;
TMP="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/nanoPlot/tmp/"

# run Nanoplot in a loop
for subdir in S1R S2R S3R S4R S5R
do
# mkdir /stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/nanoPlot/${subdir} 2> /dev/null;
BAM=${MAIN_LOC}/${subdir}/m64087_200413_100303.subreads.bam
NanoPlot -t 12 --color yellow --bam ${BAM} --downsample 10000 -o ${OUT_DIR} -p ${subdir}_bamplots_downsampled --N50 --title ${subdir}
done


