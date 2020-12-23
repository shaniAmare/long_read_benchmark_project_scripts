#!/bin/bash
# analyse pacbio data (isophase tool)
# Author: Shani Amarasinghe
# Date: 10/06/2020
#PBS -l nodes=1:ppn=8,mem=80gb
#PBS -l walltime=50:00:59
#PBS -m abe
#PBS -M amarasinghe.s@wehi.edu.au
#PBS -N isophase

# running in vc7-shared
 
export PATH="$PATH:/stornext/General/data/user_managed/grpu_mritchie_1/Shani/pacbio/smrtlink/smrtcmds/bin"

module load anaconda3

# create and activate a conda environment
conda create --name isophase python=3.7.0
source activate isophase


# define inputs
#BAM_LOC="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/05.clustering"
BAM_LOC="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/04.refined"
GFF_LOC="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/07.a.collapsed_merged_ref"
CUPCAKE_LOC="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/cDNA_Cupcake"
REFERENCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/genome_rnasequin_decoychr_2.4.fa"
mkdir "/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/isophase"
OUT_DIR="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/long_term/H201SC20030389/isophase"

module load python/3.7.0
module load anaconda3

module load minimap2
module load samtools/1.7
module load bamtools
module load bedtools

cd ${OUT_DIR};

# run isophase in a loop

# need to first edit the association files to have all 4 columns even if they are empty

find ${BAM_LOC} -name '*.bam' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.bam};
PREFIX=${OUT_P%%_*};
echo "#################### processing $BAM as $OUT_P ##################################";
echo "#################### converting $BAM to fastq ##################################";
# bamtools convert -format fastq -in ${BAM} > ${OUT_DIR}/${OUT_P}_clustered.fastq;
bamToFastq -i ${BAM} -fq ${OUT_DIR}/${OUT_P}.fastq;
# bamToFastq -i ${BAM} -fq ${OUT_DIR}/${OUT_P}_clustered.fastq;
echo "#################### complete bam to fastq conversion ##################################";
echo "#################### processing annotation file $GFF_LOC/${OUT_P}_collapsed.gff ##################################";
echo "#################### processing association file $GFF_LOC/${OUT_P}_collapsed.read_stat.txt ##################################";
python3 ${CUPCAKE_LOC}/phasing/utils/select_loci_to_phase.py \
${REFERENCE} \
${OUT_DIR}/${OUT_P}.fastq \
${GFF_LOC}/${PREFIX}_collapsed.gff \
${GFF_LOC}/${PREFIX}_collapsed.read_stat_new.txt;
echo "#################### complete $BAM ##################################";
done

# running shell scripts to extract the info

cp ${CUPCAKE_LOC}/phasing/utils/run_phasing_in_dir.sh .
# convert dos2unix
sed -i 's/\r$//' run_phasing_in_dir.sh
#edit the bash file if needed
ls -1d by_loci/*size*|xargs -n1 -i echo "bash run_phasing_in_dir.sh {}" > cmd
bash cmd

ls -1d by_loci/*size*|xargs -n1 -i echo "cd {}; bash run.sh; cd ../../" > cmd2
bash cmd2

# to summarise the findings
python ${CUPCAKE_LOC}/phasing/utils/summarize_byloci_results.py
python ${CUPCAKE_LOC}/phasing/utils/collect_all_vcf.py


# looping over all the bam files
# woring in short_term directory

mkdir "/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/isophase"
OUT_DIR="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/isophase"

cd ${OUT_DIR}

find ${BAM_LOC} -name '*.bam' -print0 | while IFS= read -r -d '' BAM
do 
OUT_P=${BAM##*/};OUT_P=${OUT_P%%.ccs*.bam};
PREFIX=${OUT_P%%_*};
mkdir ${OUT_P};
cd ${OUT_P};
echo "#################### processing $BAM in $OUT_P as $PREFIX ##################################";
echo "#################### converting $BAM to fastq ##################################";
# using samtools and bedtools options here to convert between bam and fastq
bamToFastq -i ${BAM} -fq ${OUT_DIR}/${OUT_P}/${PREFIX}.fastq;
echo "#################### complete bam to fastq conversion ##################################";
echo "#################### processing annotation file $GFF_LOC/${OUT_P}_collapsed.gff ##################################";
echo "#################### processing association file $GFF_LOC/${OUT_P}_collapsed.read_stat.txt ##################################";
python3 ${CUPCAKE_LOC}/phasing/utils/select_loci_to_phase.py \
${REFERENCE} \
${OUT_DIR}/${OUT_P}/${PREFIX}.fastq \
${GFF_LOC}/${PREFIX}_collapsed.gff \
${GFF_LOC}/${PREFIX}_collapsed.read_stat_new.txt;
echo "#################### complete $BAM ##################################";
cp ${CUPCAKE_LOC}/phasing/utils/run_phasing_in_dir.sh .;
# convert dos2unix
sed -i 's/\r$//' run_phasing_in_dir.sh;
#edit the bash file if needed
ls -1d by_loci/*size*|xargs -n1 -i echo "bash run_phasing_in_dir.sh {}" > cmd;
bash cmd;
ls -1d by_loci/*size*|xargs -n1 -i echo "cd {}; bash run.sh; cd ../../" > cmd2;
bash cmd2;
# to summarise the findings
python ${CUPCAKE_LOC}/phasing/utils/summarize_byloci_results.py;
python ${CUPCAKE_LOC}/phasing/utils/collect_all_vcf.py;
cd ../;
done
