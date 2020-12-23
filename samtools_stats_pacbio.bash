#!/bin/bash
# run stats for pacbio, nanopore and illumina data
# Author: Shani Amarasinghe
# Date: 13/08/2020
#PBS -l nodes=1:ppn=8,mem=80gb
#PBS -l walltime=50:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N idxstats_pacbio

# running in vc7-shared
module load python/3.7.0
module load samtools/1.7

# define inputs
OUT_DIR="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/"
IN_LOC_RAW="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/00.RawData"
IN_LOC_CCS="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/02.ccs"
IN_LOC_REFINED="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/04.refined"

IN_LOC_ONT="/stornext/General/data/user_managed/grpu_mritchie_1/XueyiDong/long_read_benchmark/ONT/bam"
IN_LOC_ILLUMINA="/stornext/General/data/user_managed/grpu_mritchie_1/XueyiDong/long_read_benchmark/illumina/bam"

###########################
######## idxstats on raw pacbio files

find ${IN_LOC_RAW} -name '*.bam' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/00.RawData/};OUT_P=${OUT_P%%.bam}; OUT_P=$(echo ${OUT_P} | tr '/' '_');
echo -ne "###################### processing $BAM as $OUT_P ############################\n";
samtools index ${BAM};
stats=$(samtools idxstats ${BAM});
echo -ne "${OUT_P}\t${stats}\n" >> ${OUT_DIR}/bamstats_subreads.tab;
echo -ne "###################### completed $BAM ############################\n";
done

###########################
######## idxstats on ccs files

for subdir in S1R S2R S3R S4R
do
BAM=${IN_LOC_CCS}/${subdir}/m64087_200413_100303.ccs.bam
echo -ne "###################### processing $BAM ############################\n";
OUT_P=${BAM##*/};
samtools index ${BAM};
stats=$(samtools idxstats ${BAM});
echo -ne "${subdir}_${OUT_P}\t${stats}\n" >> ${OUT_DIR}/bamstats_ccs.tab;
echo -ne "###################### completed $BAM ############################\n";
done

# for the S5A

for subdir in S5R
do
BAM=${IN_LOC_CCS}/${subdir}/m64087_200413_100303.ccs.bam
echo -ne "###################### processing $BAM ############################\n";
OUT_P=${BAM##*/};
samtools index ${BAM};
stats=$(samtools idxstats ${BAM});
echo -ne "${subdir}_${OUT_P}\t${stats}\n" >> ${OUT_DIR}/bamstats_ccs.tab;
echo -ne "###################### completed $BAM ############################\n";
BAM=${IN_LOC_CCS}/${subdir}/m64087_200427_100602.ccs.bam
echo -ne "###################### processing $BAM ############################\n";
OUT_P=${BAM##*/};
samtools index ${BAM};
stats=$(samtools idxstats ${BAM});
echo -ne "${subdir}_${OUT_P}\t${stats}\n" >> ${OUT_DIR}/bamstats_ccs.tab;
echo -ne "###################### completed $BAM ############################\n";
done

# for S6R_polyA

for subdir in S6R_polyA
do
BAM=${IN_LOC_CCS}/${subdir}/m64038_200610_112435.ccs.bam
echo -ne "###################### processing $BAM ############################\n";
OUT_P=${BAM##*/};
samtools index ${BAM};
stats=$(samtools idxstats ${BAM});
echo -ne "${subdir}_${OUT_P}\t${stats}\n" >> ${OUT_DIR}/bamstats_ccs.tab;
echo -ne "###################### completed $BAM ############################\n";
BAM=${IN_LOC_CCS}/${subdir}/m64038_200604_112534.ccs.bam
echo -ne "###################### processing $BAM ############################\n";
OUT_P=${BAM##*/};
samtools index ${BAM};
stats=$(samtools idxstats ${BAM});
echo -ne "${subdir}_${OUT_P}\t${stats}\n" >> ${OUT_DIR}/bamstats_ccs.tab;
echo -ne "###################### completed $BAM ############################\n";
done

##########################
# run idxstats on refined BAM files

find ${IN_LOC_REFINED} -name '*.bam' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/};
echo -ne "###################### processing $BAM ############################\n";
samtools index ${BAM};
stats=$(samtools idxstats ${BAM});
echo -ne "${OUT_P}\t${stats}\n" >> ${OUT_DIR}/bamstats_refined_flnc.tab;
echo -ne "###################### completed $BAM ############################\n";
done
#

###########################
######## idxstats on nanopore alignment

find ${IN_LOC_ONT} -name '*.bam' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.sorted.bam};
echo -ne "###################### processing $BAM as $OUT_P ############################\n";
samtools index ${BAM};
stats=$(samtools idxstats ${BAM});
echo -ne "${OUT_P}\t${stats}\n" >> ${OUT_DIR}/bamstats_ont.tab;
echo -ne "###################### completed $BAM ############################\n";
done

###########################
######## idxstats on illumina alignment

find ${IN_LOC_ILLUMINA} -name '*.bam' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.bam};
echo -ne "###################### processing $BAM as $OUT_P ############################\n";
samtools view -b ${BAM}| samtools sort > ${IN_LOC_ILLUMINA}/${OUT_P}.sorted.bam;
samtools index ${IN_LOC_ILLUMINA}/${OUT_P}.sorted.bam;
# stats=$(samtools idxstats ${IN_LOC_ILLUMINA}/${OUT_P}.sorted.bam);
# echo -ne "${OUT_P}\t${stats}\n" >> ${OUT_DIR}/bamstats_illumina.tab;
echo -ne "###################### completed $BAM ############################\n";
done

find ${IN_LOC_ILLUMINA} -name '*.sorted.bam' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.bam};
echo -ne "###################### processing $BAM as $OUT_P ############################\n";
stats=$(samtools idxstats ${BAM});
echo -ne "${OUT_P}\t${stats}\n" >> ${OUT_DIR}/bamstats_illumina_new.tab;
echo -ne "###################### completed $BAM ############################\n";
done

exit
