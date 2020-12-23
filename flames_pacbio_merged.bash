#!/bin/bash
# running FLAMES on pacbio merged bams
# Author: Shani Amarasinghe
# Date: 09/09/2020
#PBS -l nodes=1:ppn=5,mem=100gb
#PBS -q submit
#PBS -j oe
#PBS -l walltime=4:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N flames_merged

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

# define inputs
MAIN_LOC="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/pacbio_collapsed_merged"
OUT_DIR="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flames_output_merged"
#REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/atac-seq/20190529_MiRCL_ATAC/references/genome.fa"
REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flames_output_merged/GRCh38.primary_assembly.genome.fa"
SOURCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/FLAMES/python/bulk_long_pipeline.py"

# reference was suggested to use as the genocode one so had to fix the chromosomes

awk 'OFS="\t" {if (NR > 5) $1="chr"$1; print}' /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flames_output_merged/gencode.v29.annotation.gtf > \
/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flames_output_merged/gencode.v29.annotation.edited.gtf


#GFF="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flames_output_merged/gencode.v29.annotation.edited.gtf"

# trying a different GFF
# cp /stornext/General/data/user_managed/grpu_mritchie_1/LuyiTian/Index/GRCh38.primary_assembly.genome.fa /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flames_output_merged/
# cp /stornext/General/data/user_managed/grpu_mritchie_1/LuyiTian/Index/Homo_sapiens.GRCh38.92.gff3 /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flames_output_merged/

GFF="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flames_output_merged/Homo_sapiens.GRCh38.92.gff3"

python ${SOURCE} \
--gff3 ${GFF} \
--genomefa ${REFERENCE} \
--outdir ${OUT_DIR} \
--config_file ${OUT_DIR}/PacBio_config.json \
--inbam ${MAIN_LOC}/merged_clustered.bam \
--fq_dir ${MAIN_LOC} \
--minimap2_dir /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flames_output_merged/minimap2-2.17_x64-linux/

python ${SOURCE} \
--gff3 /stornext/General/data/user_managed/grpu_mritchie_1/LuyiTian/Index/gencode.v33.annotation.gff3 \
--genomefa /stornext/General/data/user_managed/grpu_mritchie_1/LuyiTian/Index/GRCh38.primary_assembly.genome.fa \
--outdir ${OUT_DIR} \
--config_file ${OUT_DIR}/PacBio_config.json \
--fq_dir ${MAIN_LOC} \
--minimap2_dir /stornext/General/data/user_managed/grpu_mritchie_1/SCmixology/script/minimap2-2.17_x64-linux


python /stornext/General/data/user_managed/grpu_mritchie_1/SCmixology/script/lr/sc_long_pipeline.py \
--gff3 /stornext/General/data/user_managed/grpu_mritchie_1/LuyiTian/Index/gencode.v33.annotation.gff3 \
--genomefa /stornext/General/data/user_managed/grpu_mritchie_1/LuyiTian/Index/GRCh38.primary_assembly.genome.fa \
--outdir /stornext/Genomics/data/CLL_venetoclax/single_cell_data/sclr_data/CLL5305/isoform_out \
--config_file /stornext/Genomics/data/CLL_venetoclax/single_cell_data/sclr_data/CLL5305/config_sclr_nanopore_5end.json \
--infq /stornext/Genomics/data/CLL_venetoclax/single_cell_data/sclr_data/CLL5305/CLL5305.trimmed.fq.gz \
--minimap2 /stornext/General/data/user_managed/grpu_mritchie_1/SCmixology/script/minimap2-2.17_x64-linux


# --fq_dir ${MAIN_LOC} \
#--minimap2_dir /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/minimap2

#--gff3 ${MAIN_LOC}/merged_clustered_collapsed.gff \
#--gff3 /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flames_output_merged/gencode.v29.annotation.gtf \


# python ${SOURCE} \
# --gff3 /stornext/General/data/user_managed/grpu_mritchie_1/LuyiTian/Index/gencode.v33.annotation.gff3 \
# --genomefa /stornext/General/data/user_managed/grpu_mritchie_1/LuyiTian/Index/GRCh38.primary_assembly.genome.fa \
# --outdir FLAMES_output_test \
# --config_file ${OUT_DIR}/PacBio_config.json \
# --fq_dir ${MAIN_LOC} \
# --minimap2 /stornext/General/data/user_managed/grpu_mritchie_1/SCmixology/script/minimap2-2.17_x64-linux

python ${SOURCE} \
--gff3 data/SIRV_isoforms_multi-fasta-annotation_C_170612a.gtf \
--genomefa data/SIRV_isoforms_multi-fasta_170612a.fasta \
--outdir FLAMES_output \
--config_file data/SIRV_config.json \
--fq_dir data/fastq \
--minimap2_dir /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/minimap2/


# first convert all the Raw bams to fastq (bedtools?)

MAIN_LOC="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/00.RawData"
mkdir /stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/PacBio_raw_fastq
OUT_DIR="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/PacBio_raw_fastq"

MAIN_LOC="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/02.ccs"
mkdir /stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/PacBio_ccs_fastq
OUT_DIR="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/PacBio_ccs_fastq"

find ${MAIN_LOC} -name '*.bam' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/00.RawData/};OUT_P=${OUT_P%%.bam}; OUT_P=$(echo ${OUT_P} | tr '/' '_');
echo "#################### processing $BAM as $OUT_P ##################################";
bamToFastq -i ${BAM} -fq ${OUT_DIR}/${OUT_P}.fastq;
bgzip -c ${OUT_DIR}/${OUT_P}.fastq > ${OUT_DIR}/${OUT_P}.fastq.gz;
echo "#################### completed $BAM as ${OUT_P}.fastq.gz ##################################";
done

find ${MAIN_LOC} -name '*.bam' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/02.ccs/};OUT_P=${OUT_P%%.bam}; OUT_P=$(echo ${OUT_P} | tr '/' '_');
echo "#################### processing $BAM as $OUT_P ##################################";
bamToFastq -i ${BAM} -fq ${OUT_DIR}/${OUT_P}.fastq;
bgzip -c ${OUT_DIR}/${OUT_P}.fastq > ${OUT_DIR}/${OUT_P}.fastq.gz;
echo "#################### completed $BAM as ${OUT_P}.fastq.gz ##################################";
done

mkdir /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/raw_fastq
cp ${OUT_DIR}/*fastq.gz /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/raw_fastq

MAIN_LOC="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/raw_fastq/"
OUT_DIR="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flames_output"
IN_JSON="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flames_output_merged/PacBio_config.json"
REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/LuyiTian/Index/GRCh38.primary_assembly.genome.fa"
SOURCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/FLAMES/python/bulk_long_pipeline.py"
GFF="/stornext/General/data/user_managed/grpu_mritchie_1/LuyiTian/Index/gencode.v33.annotation.gff3"

python ${SOURCE} \
--gff3 ${GFF} \
--genomefa ${REFERENCE} \
--outdir ${OUT_DIR} \
--config_file ${IN_JSON} \
--fq_dir ${MAIN_LOC} \
--minimap2_dir /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/minimap2/	

#update on 5/11/2020
# running on ccs fastq files

mkdir /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/ccs_fastq
cp ${OUT_DIR}/*fastq.gz /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/ccs_fastq

#MAIN_LOC="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/PacBio_ccs_fastq"
MAIN_LOC="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/ccs_fastq"
mkdir stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flames_output_ccs
OUT_DIR="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flames_output_ccs"
IN_JSON="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flames_output_merged/PacBio_config.json"
REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/LuyiTian/Index/GRCh38.primary_assembly.genome.fa"
SOURCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/FLAMES/python/bulk_long_pipeline.py"
GFF="/stornext/General/data/user_managed/grpu_mritchie_1/LuyiTian/Index/gencode.v33.annotation.gff3"

python ${SOURCE} \
--gff3 ${GFF} \
--genomefa ${REFERENCE} \
--outdir ${OUT_DIR} \
--config_file ${IN_JSON} \
--fq_dir ${MAIN_LOC} \
--minimap2_dir /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/minimap2/	

# update on 23/10/2020
# apparently a CB is needed on the BAM file to processing
# so manually added a CB to each sample

MAIN_LOC="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/pseudocb"
OUT_DIR="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flames_output_pseudocb"
SOURCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/FLAMES/python/bulk_long_pipeline.py"

python ${SOURCE} \
--gff3 /stornext/General/data/user_managed/grpu_mritchie_1/LuyiTian/Index/gencode.v33.annotation.gff3 \
--genomefa /stornext/General/data/user_managed/grpu_mritchie_1/LuyiTian/Index/GRCh38.primary_assembly.genome.fa \
--outdir ${OUT_DIR} \
--config_file ${OUT_DIR}/PacBio_config.json \
--fq_dir ${MAIN_LOC} \
--minimap2_dir /stornext/General/data/user_managed/grpu_mritchie_1/SCmixology/script/minimap2-2.17_x64-linux

# BAM files have to be in the OUT dir?

MAIN_LOC="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/pseudocb"
OUT_DIR="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/flames_output_pseudocb"
SOURCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/FLAMES/python/bulk_long_pipeline.py"

python ${SOURCE} \
--gff3 /stornext/General/data/user_managed/grpu_mritchie_1/LuyiTian/Index/gencode.v33.annotation.gff3 \
--genomefa /stornext/General/data/user_managed/grpu_mritchie_1/LuyiTian/Index/GRCh38.primary_assembly.genome.fa \
--outdir ${OUT_DIR} \
--inbam ${OUT_DIR}/1R_clustered_aligned_to_hg38_pseudocb.bam \
--config_file ${OUT_DIR}/PacBio_config.json \
--minimap2_dir /stornext/General/data/user_managed/grpu_mritchie_1/SCmixology/script/minimap2-2.17_x64-linux

# # output data is in FLAMES_output
# ls ${OUT_DIR}

