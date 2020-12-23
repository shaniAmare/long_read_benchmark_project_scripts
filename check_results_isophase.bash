#!/bin/bash
# compare VCF files generated through isophase
#

#unning on the VM in unix500
module load bedtools/1.9

VCF_LOC="/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench_PacBio/short_term/isophase"

# I would want to compare between the two cell lines
bcftools isec first.vcf.gz second.vcf.gz -p first_second

bgzip -c ${VCF_LOC}/1R_m64087_200413_100303/IsoSeq_IsoPhase.vcf > ${VCF_LOC}/1R_m64087_200413_100303/IsoSeq_IsoPhase.vcf.gz
bgzip -c ${VCF_LOC}/4R_m64087_200413_100303/IsoSeq_IsoPhase.vcf > ${VCF_LOC}/4R_m64087_200413_100303/IsoSeq_IsoPhase.vcf.gz

bcftools index ${VCF_LOC}/1R_m64087_200413_100303/IsoSeq_IsoPhase.vcf.gz
bcftools index ${VCF_LOC}/4R_m64087_200413_100303/IsoSeq_IsoPhase.vcf.gz

#present in 1R but not in 4R
bcftools isec --complement --prefix=${VCF_LOC}/1R_4R ${VCF_LOC}/1R_m64087_200413_100303/IsoSeq_IsoPhase.vcf.gz ${VCF_LOC}/4R_m64087_200413_100303/IsoSeq_IsoPhase.vcf.gz 
# present in 4R but not in 1R
bcftools isec --complement --prefix=${VCF_LOC}/4R_1R ${VCF_LOC}/4R_m64087_200413_100303/IsoSeq_IsoPhase.vcf.gz ${VCF_LOC}/1R_m64087_200413_100303/IsoSeq_IsoPhase.vcf.gz 