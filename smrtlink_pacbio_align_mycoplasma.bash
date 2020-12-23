#!/bin/bash
# analyse pacbio data (align to mycoplasma data)
# Author: Shani Amarasinghe
# Date: 10/06/2020
#PBS -l nodes=1:ppn=8,mem=80gb
#PBS -l walltime=50:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N align_to_

# running in vc7-shared

#qsub -I -V -A ccs_pb -q ccs -l nodes=1:ppn=10,pmem=100gb,walltime=50:00:00,qos=ccs
#qsub -I -V -A amarasinghe.s -l nodes=1:ppn=8,pmem=80gb,walltime=100:00:00
 
export PATH="$PATH:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/pacbio/smrtlink/smrtcmds/bin"

#first generate the fasta.reference file for mycopasma
# references:
# https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4357728/
# https://www.ncbi.nlm.nih.gov/nuccore/NC_013511.1?report=fasta
# https://www.ncbi.nlm.nih.gov/nuccore/NC_017519.1?report=fasta
# https://www.ncbi.nlm.nih.gov/nuccore/NC_014921.1?report=fasta

cd /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/Mycoplasma_cont
cat *.fasta > mycoplasma.fasta


# define inputs
MAIN_LOC="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/05.clustering"
OUT_DIR="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/Mycoplasma_cont"
REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/Mycoplasma_cont/mycoplasma.fasta"

# run ccs module
pbmm2 --version
# 1.1.0

# run pbmm2 in a loop
find ${MAIN_LOC} -name '*_clustered.xml' -print0 | while IFS= read -r -d '' XML
do 
OUT_P=${XML##*/};OUT_P=${OUT_P%%.xml};
#XML=${MAIN_LOC}/${OUT_P}.transcriptset.xml;
pbmm2 align \
--log-file ${OUT_DIR}/${OUT_P}.log \
--log-level DEBUG \
--preset ISOSEQ \
--sort \
${REFERENCE} \
${XML} \
${OUT_DIR}/${OUT_P}_aligned_to_myplasma.bam
done

pbmm2 align \
--log-file ${OUT_DIR}/${OUT_P}.log\
--log-level DEBUG \
--preset ISOSEQ \
--sort \
${REFERENCE} \
/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/05.clustering/5R_clustered.transcriptset.xml \
${OUT_DIR}/5R_clustered_aligned_to_myplasma.bam