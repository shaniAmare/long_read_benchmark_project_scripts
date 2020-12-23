#!/bin/bash
# TALON qc on pacbio data
# Author: Shani Amarasinghe
# Date: 14/08/2020
#PBS -l nodes=1:ppn=8,mem=80gb
#PBS -l walltime=50:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N TALON

# running in vc-7 shared

# recommended to first clean the alignments using TranscriptClean

#################################
################################## TranscriptClean ----------------------------- 

module load python/3.7.0
module load samtools/1.7
module load R/3.6.0
module load bedtools
module load htslib/1.9
 
TRANSCRIPTCLEAN="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/TranscriptClean"
ALIGNED_BAM_SOURCE="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/06.aligned"
REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/atac-seq/20190529_MiRCL_ATAC/references/genome_name_edited.fa"
#REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/atac-seq/20190529_MiRCL_ATAC/references/genome.fa"
mkdir "/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/talon_output"
OUTDIR="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/talon_output"

# I had to install pybedtools in a different location. 
# pip install --target=/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/python_packages pybedtools --no-cache-dir
# Adding it to path here
export PYTHONPATH=$PYTHONPATH:/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/python_packages/pybedtools/:/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/python_packages/pybedtools/bin

find ${MAIN_LOC} -name '*.bam' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/};OUT_P=${OUT_P%%_clustered_aligned_to_hg38.bam};
echo "#################### processing $BAM ##################################";
#samtools view -h ${BAM} > ${OUTDIR}/${OUT_P}.sam;
#samtools index ${OUTDIR}/${OUT_P}.sam;
python ${TRANSCRIPTCLEAN}/TranscriptClean.py --sam <(bgzip -d ${BAM}) --genome ${REFERENCE} --outprefix ${OUTDIR}/${OUT_P}
done

# testing on one BAM file gzipped (assumption): remaining and converting to sam before running TRanscriptClean
BAM="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/talon_output/m64038_200610_112435.subreads.bam"
samtools view -h ${BAM} >  /stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/talon_output/m64038_200610_112435.subreads.sam;
samtools index  /stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/talon_output/m64038_200610_112435.subreads.sam

python ${TRANSCRIPTCLEAN}/TranscriptClean.py \
--sam /stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/talon_output/m64038_200610_112435.subreads.sam --genome ${REFERENCE} \
--outprefix /stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/talon_output/m64038_200610_112435.subreads

# leaving TranscriptClean out for now

# TALON

#installation
cd /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/TALON/
pip install --target=/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/python_packages . --no-cache-dir
export PYTHONPATH=$PYTHONPATH:/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/python_packages/pybedtools/:/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/python_packages/pybedtools/bin:/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/python_packages/talon/
export PATH=$PATH:/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/python_packages/pybedtools/:/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/python_packages/pybedtools/bin:/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/python_packages/talon/

#################################
#################################-----------------------

# TALON is installed in unix500: amarasinghe.s@vc7hpc-957.hpc.wehi.edu.au

module load python/3.7.0
module load samtools/1.7
module load R/3.6.0
module load bedtools
module load htslib/1.9
 
ALIGNED_BAM_SOURCE="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/06.aligned"
REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/atac-seq/20190529_MiRCL_ATAC/references/genome_name_edited.fa"
#REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/atac-seq/20190529_MiRCL_ATAC/references/genome.fa"
mkdir "/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/talon_output"
OUTDIR="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/talon_output"

ANNOT="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flames_output_merged/gencode.v29.annotation.gtf"
#REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/atac-seq/20190529_MiRCL_ATAC/references/genome.fa"
 
# initiate database
talon_initialize_database \
--f ${ANNOT} \
--a gencode.v29.annotation \
--g gencode29 \
--o talon_db

# label reads
find ${ALIGNED_BAM_SOURCE} -name '*.bam' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.bam};
echo "#################### processing $BAM ##################################";
talon_label_reads \
--f ${BAM} \
--g ${REFERENCE} \
--t 8 \
--ar 20 \
--deleteTmp \
--o ${OUTDIR}/${OUT_P};
echo "#################### complete $BAM ###################################";
done

# before annotator runs, MD tag needs to be added. I can try samtools

# samtools calmd aln.bam ref.fasta

find ${OUTDIR} -name '*.sam' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.sam}
samtools calmd ${BAM} ${REFERENCE} > ${OUTDIR}/${OUT_P}.MDtagged.sam
done

# run talon annotator
talon \
--f ${OUTDIR}/talon_pacbio_config.csv \
--db ${OUTDIR}/talon_db.db \
--build gencode29 \
--o ${OUTDIR}/talon_pacbio \
--t 8

# run talon summarize
talon_summarize \
--db ${OUTDIR}/talon_db.db \
--v \
--o ${OUTDIR}/talon_pacbio_summary

# ---------------sample1_H1975_sequinA---------------
# Number of reads: 27319
# Known genes: 7180
# Novel genes: 42
# ----Antisense genes: 19
# ----Other novel genes: 23
# Known transcripts: 7660
# Novel transcripts: 7137
# ----ISM transcripts: 3930
# --------Prefix ISM transcripts: 248
# --------Suffix ISM transcripts: 3563
# ----NIC transcripts: 1846
# ----NNC transcripts: 931
# ----antisense transcripts: 19
# ----genomic transcripts: 389
# ---------------sample2_H1975_sequinA---------------
# Number of reads: 34628
# Known genes: 7975
# Novel genes: 64
# ----Antisense genes: 23
# ----Other novel genes: 41
# Known transcripts: 8901
# Novel transcripts: 8279
# ----ISM transcripts: 2834
# --------Prefix ISM transcripts: 483
# --------Suffix ISM transcripts: 2300
# ----NIC transcripts: 3203
# ----NNC transcripts: 1860
# ----antisense transcripts: 22
# ----genomic transcripts: 320
# ---------------sample3_H1975_sequinA---------------
# Number of reads: 33015
# Known genes: 7753
# Novel genes: 57
# ----Antisense genes: 26
# ----Other novel genes: 31
# Known transcripts: 8567
# Novel transcripts: 7841
# ----ISM transcripts: 2664
# --------Prefix ISM transcripts: 462
# --------Suffix ISM transcripts: 2159
# ----NIC transcripts: 3062
# ----NNC transcripts: 1804
# ----antisense transcripts: 25
# ----genomic transcripts: 258
# ---------------sample4_HCC827_sequinB---------------
# Number of reads: 35720
# Known genes: 7945
# Novel genes: 43
# ----Antisense genes: 14
# ----Other novel genes: 29
# Known transcripts: 8911
# Novel transcripts: 9004
# ----ISM transcripts: 4125
# --------Prefix ISM transcripts: 451
# --------Suffix ISM transcripts: 3605
# ----NIC transcripts: 2999
# ----NNC transcripts: 1528
# ----antisense transcripts: 14
# ----genomic transcripts: 312
# ---------------sample5_HCC827_sequinB---------------
# Number of reads: 26849
# Known genes: 7355
# Novel genes: 30
# ----Antisense genes: 7
# ----Other novel genes: 23
# Known transcripts: 8123
# Novel transcripts: 6279
# ----ISM transcripts: 2493
# --------Prefix ISM transcripts: 330
# --------Suffix ISM transcripts: 2136
# ----NIC transcripts: 2304
# ----NNC transcripts: 1309
# ----antisense transcripts: 7
# ----genomic transcripts: 145
# ---------------sample6_HCC827_sequinB---------------
# Number of reads: 25421
# Known genes: 6478
# Novel genes: 35
# ----Antisense genes: 15
# ----Other novel genes: 20
# Known transcripts: 6490
# Novel transcripts: 8848
# ----ISM transcripts: 6634
# --------Prefix ISM transcripts: 251
# --------Suffix ISM transcripts: 6161
# ----NIC transcripts: 1001
# ----NNC transcripts: 588
# ----antisense transcripts: 15
# ----genomic transcripts: 592


# run talon abundance
talon_abundance \
--db ${OUTDIR}/talon_db.db \
-a gencode.v29.annotation \
--build gencode29 \
--o ${OUTDIR}/talon_pacbio_unfiltered

# filtering
talon_filter_transcripts \
--db ${OUTDIR}/talon_db.db \
--datasets sample1_H1975_sequinA,sample2_H1975_sequinA,sample3_H1975_sequinA,sample4_HCC827_sequinB,sample5_HCC827_sequinB,sample6_HCC827_sequinB \
-a gencode.v29.annotation \
--maxFracA 0.5 \
--minCount 5 \
--minDatasets 2 \
--o ${OUTDIR}/talon_pacbio_filtered_transcripts.csv

# next abundance again
talon_abundance \
--db ${OUTDIR}/talon_db.db \
--whitelist ${OUTDIR}/talon_pacbio_filtered_transcripts.csv \
-a gencode.v29.annotation \
--build gencode29 \
--o ${OUTDIR}/talon_pacbio_filtered


# plotting post talon
R_SCRIPT="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/TALON/src/talon/post/r_scripts/generate_talon_report.R"

# for unfiltered
mkdir ${OUTDIR}/talon_plots_unfiltered

for SAMPLE in sample1_H1975_sequinA sample2_H1975_sequinA sample3_H1975_sequinA sample4_HCC827_sequinB sample5_HCC827_sequinB sample6_HCC827_sequinB
do
mkdir ${OUTDIR}/talon_plots_unfiltered/${SAMPLE};
Rscript ${R_SCRIPT} \
--db=${OUTDIR}/talon_db.db \
--datasets=${SAMPLE} \
--outdir=${OUTDIR}/talon_plots_unfiltered/${SAMPLE}
done

### for filtered
mkdir ${OUTDIR}/talon_plots_filtered

for SAMPLE in sample1_H1975_sequinA sample2_H1975_sequinA sample3_H1975_sequinA sample4_HCC827_sequinB sample5_HCC827_sequinB sample6_HCC827_sequinB
do
mkdir ${OUTDIR}/talon_plots_filtered/${SAMPLE};
Rscript ${R_SCRIPT} \
--db=${OUTDIR}/talon_db.db \
--datasets=${SAMPLE} \
--outdir=${OUTDIR}/talon_plots_filtered/${SAMPLE}
done

# Rscript ${R_SCRIPT} \
# --db=${OUTDIR}/talon_db.db \
# --whitelists=${OUTDIR}/talon_pacbio_filtered_transcripts.csv \
# --datasets=sample1_H1975_sequinA \
# --outdir=${OUTDIR}/talon_plots_filtered

###############################
#################TALON on new dataset mapped with merged ref 

sed 's/\s.*$//' /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/genome_rnasequin_decoychr_2.4.fa > /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/genome_rnasequin_decoychr_2.4_edited.fa

ALIGNED_BAM_SOURCE="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/06.a.aligned_merged_ref"
REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/genome_rnasequin_decoychr_2.4_edited.fa"
mkdir "/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/talon_output_merged_ref"
OUTDIR="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/talon_output_merged_ref"
ANNOT="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/genome_rnasequin_decoychr_2.4.gtf"

talon_initialize_database \
--f ${ANNOT} \
--a gencode.v29.annotation \
--g gencode29 \
--o talon_db

# label reads
find ${ALIGNED_BAM_SOURCE} -name '*.bam' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.bam};
echo "#################### processing $BAM ##################################";
talon_label_reads \
--f ${BAM} \
--g ${REFERENCE} \
--t 8 \
--ar 20 \
--deleteTmp \
--o ${OUTDIR}/${OUT_P};
echo "#################### complete $BAM ###################################";
done

# before annotator runs, MD tag needs to be added. I can try samtools

# samtools calmd aln.bam ref.fasta

find ${OUTDIR} -name '*.sam' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.sam}
samtools calmd ${BAM} ${REFERENCE} > ${OUTDIR}/${OUT_P}.MDtagged.sam
done

# run talon annotator
talon \
--f ${OUTDIR}/talon_pacbio_config.csv \
--db ${OUTDIR}/talon_db.db \
--build gencode29 \
--o ${OUTDIR}/talon_pacbio \
--t 8

# run talon summarize
talon_summarize \
--db ${OUTDIR}/talon_db.db \
--v \
--o ${OUTDIR}/talon_pacbio_summary

# run talon abundance
talon_abundance \
--db ${OUTDIR}/talon_db.db \
-a gencode.v29.annotation \
--build gencode29 \
--o ${OUTDIR}/talon_pacbio_unfiltered

# filtering
talon_filter_transcripts \
--db ${OUTDIR}/talon_db.db \
--datasets sample1_H1975_sequinA,sample2_H1975_sequinA,sample3_H1975_sequinA,sample4_HCC827_sequinB,sample5_HCC827_sequinB,sample6_HCC827_sequinB \
-a gencode.v29.annotation \
--maxFracA 0.5 \
--minCount 5 \
--minDatasets 2 \
--o ${OUTDIR}/talon_pacbio_filtered_transcripts.csv

# next abundance again
talon_abundance \
--db ${OUTDIR}/talon_db.db \
--whitelist ${OUTDIR}/talon_pacbio_filtered_transcripts.csv \
-a gencode.v29.annotation \
--build gencode29 \
--o ${OUTDIR}/talon_pacbio_filtered





