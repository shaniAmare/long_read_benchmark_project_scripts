#!/bin/bash
# sqanti3 qc on pacbio data
# Author: Shani Amarasinghe
# Date: 14/08/2020
#PBS -l nodes=1:ppn=8,mem=80gb
#PBS -l walltime=50:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N sqanti3

# running in unix500

# sqanti environment is created and activated

# because unix500 cannot access the promethion dir, creating symlinks for the collapse directory in my directory
# using symlinks didn't work

# copying only works in vc7-shared! (aaargh)
cp /stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/07.collapsed/* \
/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/pacbio_collapsed/

# add cDNA cupcake to python path here
#/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/cDNA_Cupcake/sequence/:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/cDNA_Cupcake/

# define inputs
MAIN_LOC="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/pacbio_collapsed"
mkdir "/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/sqanti_output"
OUT_DIR="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/sqanti_output"

REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/atac-seq/20190529_MiRCL_ATAC/references/genome.fa"
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
${REFERENCE};
echo "#################### complete $FASTA ###################################";
done
