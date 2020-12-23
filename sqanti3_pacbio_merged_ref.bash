#!/bin/bash
# sqanti3 qc on pacbio data mapped to new reference with merged ref and sequin
# Author: Shani Amarasinghe
# Date: 14/08/2020
#PBS -l nodes=1:ppn=8,mem=40gb
#PBS -q submit
#PBS -j oe
#PBS -l walltime=400:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N sqanti3_merged_ref

# running in unix500
# NOT working on the VM: amarasinghe.s@vc7hpc-957.hpc.wehi.edu.au

# sqanti environment is created and activated

# add cDNA cupcake to python path here
#/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/cDNA_Cupcake/sequence/:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/cDNA_Cupcake/
module load python/3.7.0
module load samtools/1.7
#module load anaconda2/2019.10
module load anaconda3/2019.03

cd /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/SQANTI3/SQANTI3

module load anaconda2/2019.10
source activate SQANTI3.env
# conda activate SQANTI3.env

module load R/3.6.0
module load perl
module load gmap-gsnap
module load minimap2
module load samtools/1.7

export PYTHONPATH=$PYTHONPATH:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/cDNA_Cupcake/sequence/:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/cDNA_Cupcake/
echo $PYTHONPATH

export PATH=$PATH:/stornext/General/data/user_managed/grpu_mritchie_1/SCmixology/script/minimap2-2.17_x64-linux
echo $PATH

# define inputs
#MAIN_LOC="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/07.a.collapsed_merged_ref"
MAIN_LOC="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/pacbio_collapsed_merged_ref"
mkdir "/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/sqanti_output_merged_ref"
OUT_DIR="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/sqanti_output_merged_ref"
TAPPAS_GFF="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/SQANTI3/taPPAS_refs/Homo_sapiens_GRCh38_Ensembl_86.gff3"
REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/genome_rnasequin_decoychr_2.4.fa"
# REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/Index/GRCh38.primary_assembly.genome.fa"

# run sqanti_qc.py version
python sqanti3_qc.py --version
# SQANTI3 1.0.0

# run sqanti_qc.py in a loop
find ${MAIN_LOC} -name '*.fasta' -print0 | while IFS= read -r -d '' FASTA
do 
GFF=${FASTA%%.fasta}; GFF=${GFF}.gff;
FL=${FASTA%%.fasta}; FL=${FL}.abundance.txt;
OUT_P=${FASTA##*/};OUT_P=${OUT_P%%.fasta};
echo "#################### processing $FASTA ##################################";
echo "#################### using annotation $GFF ##############################";
echo "#################### using fl_count $FL ##############################";
echo "#################### saving as $OUT_P ###################################";
python sqanti3_qc.py \
--output ${OUT_P} \
--dir ${OUT_DIR} \
--fl_count ${FL} \
${FASTA} \
${GFF} \
${REFERENCE} \
--isoAnnotLite --gff3 ${TAPPAS_GFF};
echo "#################### complete $FASTA ###################################";
done
