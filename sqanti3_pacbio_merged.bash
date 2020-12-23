#!/bin/bash
# running sqanti3 on pacbio merged bams
# Author: Shani Amarasinghe
# Date: 08/09/2020
#PBS -l nodes=1:ppn=8,mem=40gb
#PBS -q submit
#PBS -j oe
#PBS -l walltime=4:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N sqanti3_merged

# running in vc7-shared
module load python/3.7.0
module load samtools/1.7
module load anaconda2/2019.10
#module load anaconda3

#PYTHONPATH="$PYTHONPATH:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/cDNA_Cupcake/sequence/:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/cDNA_Cupcake/"

cd /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/SQANTI3/SQANTI3
source activate SQANTI3.env
#conda activate SQANTI3.env

module load R/3.6.1
module load perl
module load gmap-gsnap

export PYTHONPATH=$PYTHONPATH:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/cDNA_Cupcake/sequence/:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/cDNA_Cupcake/
echo $PYTHONPATH

export PATH=$PATH:/stornext/General/data/user_managed/grpu_mritchie_1/SCmixology/script/minimap2-2.17_x64-linux
echo $PATH

# define inputs
MAIN_LOC="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/pacbio_collapsed_merged"
mkdir "/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/sqanti_output_merged"
OUT_DIR="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/sqanti_output_merged"

REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/atac-seq/20190529_MiRCL_ATAC/references/genome.fa"
# REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/Index/GRCh38.primary_assembly.genome.fa"

# run sqanti_qc.py version
python sqanti3_qc.py --version
# SQANTI3 1.0.0

# run sqanti_qc.py
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
