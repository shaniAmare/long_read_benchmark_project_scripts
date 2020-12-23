#!/bin/bash
# run cluster data
# Author: Shani Amarasinghe
# Date: 31/07/2020
#PBS -l nodes=1:ppn=8,mem=80gb
#PBS -l walltime=50:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N merge_pacbio

# running in vc7-shared
module load python/3.7.0
module load samtools/1.7

export PATH="$PATH:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/pacbio/smrtlink/smrtcmds/bin"

# define inputs
IN_LOC="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/04.refined"
OUT_F="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/05.clustering"

# first need to merge SMRT cells for 5R nd 6R_PloyA

# generate the merge file name file for 5R samples
find "${IN_LOC}" -name "5R*.bam" | while read BAM 
do 
ls ${BAM} >> ${OUT_F}/5R_flnc.fofn
done

# generate the merge file name file for 6R ployA samples
find "${IN_LOC}" -name "6R*.bam" | while read BAM 
do 
ls ${BAM} >> ${OUT_F}/6R_polyA_flnc.fofn
done

# generate the merge file name file for 1R samples
find "${IN_LOC}" -name "1R*.bam" | while read BAM 
do 
ls ${BAM} >> ${OUT_F}/1R_flnc.fofn
done

# generate the merge file name file for 2R samples
find "${IN_LOC}" -name "2R*.bam" | while read BAM 
do 
ls ${BAM} >> ${OUT_F}/2R_flnc.fofn
done

# generate the merge file name file for 3R samples
find "${IN_LOC}" -name "3R*.bam" | while read BAM 
do 
ls ${BAM} >> ${OUT_F}/3R_flnc.fofn
done

# generate the merge file name file for 4R samples
find "${IN_LOC}" -name "4R*.bam" | while read BAM 
do 
ls ${BAM} >> ${OUT_F}/4R_flnc.fofn
done

# do clustering
for file in 1R 2R 3R 4R
do
isoseq3 cluster ${OUT_F}/${file}_flnc.fofn ${OUT_F}/${file}_clustered.bam --verbose --use-qvs
done

isoseq3 cluster ${OUT_F}/5R_flnc.fofn ${OUT_F}/5R_clustered.bam --verbose --use-qvs
isoseq3 cluster ${OUT_F}/6R_polyA_flnc.fofn ${OUT_F}/6R_polyA_clustered.bam --verbose --use-qvs

#
exit
