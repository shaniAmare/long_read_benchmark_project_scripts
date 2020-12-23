#!/bin/bash
# run LongQC on pacbio data
# Author: Shani Amarasinghe
# Date: 17/06/2020
#PBS -l nodes=1:ppn=8,mem=80gb
#PBS -l walltime=50:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N longQC_pacbio

# running in vc7-shared
module load python/3.7.0
module load samtools/1.7

# define inputs
IN_LOC_RAW="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/00.RawData"
IN_LOC_CCS="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/02.ccs"
mkdir "/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/LongQC_output"
OUT_DIR="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/LongQC_output"
mkdir ${OUT_DIR}/RAW/
mkdir ${OUT_DIR}/CCS/
SOURCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/LongQC/longQC.py"

# source: https://github.com/yfukasawa/LongQC

# first run samtools index
for subdir in S1R S2R S3R S4R S5R
do
cd ${IN_LOC_RAW}/${subdir}/ 
samtools index m64087_200413_100303.subreads.bam
# samtools index m64087_200413_100303.subreads.bam
done

# first run samtools index for ccs BAM
for subdir in S1R S2R S3R S4R S5R
do
samtools index ${IN_LOC_CCS}/${subdir}/m64087_200413_100303.subreads.bam
# samtools index m64087_200413_100303.subreads.bam
done

# run LongQC sampleqc in a loop for all raw BAM files
for subdir in S1R S2R S3R S4R S5R
do
BAM=${IN_LOC_RAW}/${subdir}/m64087_200413_100303.subreads.bam
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.bam};
mkdir ${OUT_DIR}/RAW/${subdir}_runqc
python ${SOURCE} runqc -s ${OUT_P}.raw -o ${OUT_DIR}/RAW/${subdir}_runqc sequel ${IN_LOC_RAW}/${subdir}
# python ${SOURCE} sampleqc -x pb-rs2 -p 2 -m 2 -o ${OUT_DIR}/RAW/${subdir} ${BAM}
done

# run LongQC sampleqc in a loop for all ccs BAM files
for subdir in S1R S2R S3R S4R S5R
do
BAM=${IN_LOC_CCS}/${subdir}/m64087_200413_100303.ccs.bam
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.bam};
mkdir ${OUT_DIR}/RAW/${subdir}_runqc
python ${SOURCE} runqc -s ${OUT_P}.raw -o ${OUT_DIR}/RAW/${subdir}_runqc rs2 ${IN_LOC_RAW}/${subdir}
# python ${SOURCE} runqc -s ${OUT_P}.raw -o ${OUT_DIR}/CCS/${subdir}_runqc rs2 ${IN_LOC_CCS}/${subdir}
python ${SOURCE} sampleqc -x pb-rs2 -p 2 -m 2 -o ${OUT_DIR}/CCS/${subdir} ${BAM}
done

# for S6R_polyA
# run LongQC sampleqc in a loop for all CCS BAM files
for subdir in S6R_polyA
do
BAM=${IN_LOC_CCS}/${subdir}/m64038_200610_112435.ccs.bam
echo -ne "###################### processing $BAM ############################"
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.ccs.bam};
#mkdir ${OUT_DIR}/CCS/${subdir}_${OUT_P}
python ${SOURCE} sampleqc -x pb-rs2 -p 8 -m 2 -o ${OUT_DIR}/CCS/${subdir}_${OUT_P} ${BAM}
echo -ne "###################### completed $BAM ############################"
BAM=${IN_LOC_CCS}/${subdir}/m64038_200604_112534.ccs.bam
echo -ne "###################### processing $BAM ############################"
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.ccs.bam};
#mkdir ${OUT_DIR}/CCS/${subdir}_${OUT_P}
python ${SOURCE} sampleqc -x pb-rs2 -p 8 -m 2 -o ${OUT_DIR}/CCS/${subdir}_${OUT_P} ${BAM}
echo -ne "###################### completed $BAM ############################"
done
#
# for the S5A in CCS
# run LongQC sampleqc in a loop for all CCS BAM files
for subdir in S5R
do
BAM=${IN_LOC_CCS}/${subdir}/m64087_200413_100303.ccs.bam
echo -ne "###################### processing $BAM ############################"
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.ccs.bam};
#mkdir ${OUT_DIR}/CCS/${subdir}_${OUT_P}
python ${SOURCE} sampleqc -x pb-rs2 -p 8 -m 2 -o ${OUT_DIR}/CCS/${subdir}_${OUT_P} ${BAM}
echo -ne "###################### completed $BAM ############################"
BAM=${IN_LOC_CCS}/${subdir}/m64087_200427_100602.ccs.bam
echo -ne "###################### processing $BAM ############################"
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.ccs.bam};
#mkdir ${OUT_DIR}/CCS/${subdir}_${OUT_P}
python ${SOURCE} sampleqc -x pb-rs2 -p 8 -m 2 -o ${OUT_DIR}/CCS/${subdir}_${OUT_P} ${BAM}
echo -ne "###################### completed $BAM ############################"
done
#

###########################
# test the method Yoshi was suggesting

mkdir ${OUT_DIR}/PB-SEQUEL-TEST/
OUT_DIR="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/LongQC_output"
SOURCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/LongQC/longQC.py"
IN_LOC_CCS="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/02.ccs"

for subdir in S1R S2R S3R S4R
do
BAM=${IN_LOC_CCS}/${subdir}/m64087_200413_100303.ccs.bam
echo -ne "###################### processing $BAM ############################"
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.bam};
python ${SOURCE} sampleqc -x pb-sequel -p 20 -f -o ${OUT_DIR}/PB-SEQUEL-TEST/${subdir} ${BAM}
echo -ne "###################### completed $BAM ############################"
done

# for S6R_polyA
# run LongQC sampleqc in a loop for all CCS BAM files
for subdir in S6R_polyA
do
BAM=${IN_LOC_CCS}/${subdir}/m64038_200610_112435.ccs.bam
echo -ne "###################### processing $BAM ############################"
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.ccs.bam};
python ${SOURCE} sampleqc -x pb-sequel -p 20 -f -o ${OUT_DIR}/PB-SEQUEL-TEST/${subdir}_${OUT_P} ${BAM}
echo -ne "###################### completed $BAM ############################"
BAM=${IN_LOC_CCS}/${subdir}/m64038_200604_112534.ccs.bam
echo -ne "###################### processing $BAM ############################"
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.ccs.bam};
python ${SOURCE} sampleqc -x pb-sequel -p 20 -f -o ${OUT_DIR}/PB-SEQUEL-TEST/${subdir}_${OUT_P} ${BAM}
echo -ne "###################### completed $BAM ############################"
done
#
# for the S5A in CCS
# run LongQC sampleqc in a loop for all CCS BAM files
for subdir in S5R
do
BAM=${IN_LOC_CCS}/${subdir}/m64087_200413_100303.ccs.bam
echo -ne "###################### processing $BAM ############################"
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.ccs.bam};
python ${SOURCE} sampleqc -x pb-sequel -p 20 -f -o ${OUT_DIR}/PB-SEQUEL-TEST/${subdir}_${OUT_P} ${BAM}
echo -ne "###################### completed $BAM ############################"
BAM=${IN_LOC_CCS}/${subdir}/m64087_200427_100602.ccs.bam
echo -ne "###################### processing $BAM ############################"
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.ccs.bam};
python ${SOURCE} sampleqc -x pb-sequel -p 20 -f -o ${OUT_DIR}/PB-SEQUEL-TEST/${subdir}_${OUT_P} ${BAM}
echo -ne "###################### completed $BAM ############################"
done

##########################
# run LongQC sampleqc in a loop for all refined BAM files

IN_LOC_REFINED="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/04.refined"
OUT_DIR="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/LongQC_output"
SOURCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/LongQC/longQC.py"

mkdir ${OUT_DIR}/REFINED/

find ${IN_LOC_REFINED} -name '*.bam' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.ccs.Clontech_5p--NEB_Clontech_3p_flnc.bam};
python ${SOURCE} sampleqc -x pb-rs2 -p 8 -m 2 -o ${OUT_DIR}/REFINED/${OUT_P} ${BAM}
done

# above didn't work, so trying the method Yoshi was suggesting

mkdir ${OUT_DIR}/REFINED/

find ${IN_LOC_REFINED} -name '*.bam' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.ccs.Clontech_5p--NEB_Clontech_3p_flnc.bam};
python ${SOURCE} sampleqc -x pb-sequel -p 20 -f -o ${OUT_DIR}/REFINED/${OUT_P} ${BAM}
done

#
exit
