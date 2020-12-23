#!/bin/bash
#PBS -q submit
#PBS -l nodes=1:ppn=16,mem=100gb,walltime=1000:00:00
#PBS -M dong.x@wehi.edu.au
#PBS -m abe
#PBS -j oe

module load python/3.7.0
module load samtools/1.7

# testing the minimap2_update branch
cd /stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/long_read_benchmark/LongQC-minimap2_update/minimap2-coverage/
make extra

out=/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/LongQC_ont
input=/stornext/Projects/promethion/promethion_access/lab_ritchie/transcr_bench/long_term/transcr_bench/fq_merged

# SOURCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/LongQC/longQC.py"

SOURCE="/stornext/General/data/user_managed/grpu_mritchie_1/Shani/long_read_benchmark/LongQC-minimap2_update/longQC.py"

for barcode in barcode01 barcode02 barcode03 barcode04 barcode05 barcode06
do
echo "###################started processing $input/$barcode.fq.gz"
python ${SOURCE} sampleqc -x ont-ligation -p 4 -m 2 -o $out/$barcode $input/$barcode.fq.gz
echo "###################complete processing $input/$barcode.fq.gz"
echo "###################"
echo -ne "###################\n\n\n\n"
done


#python ${SOURCE} sampleqc -x ont-ligation -p 4 -o $out/barcode02 $input/barcode02.fq.gz
#python ${SOURCE} sampleqc -x ont-ligation -p 4 -o $out/barcode03 $input/barcode03.fq.gz
#python ${SOURCE} sampleqc -x ont-ligation -p 4 -o $out/barcode04 $input/barcode04.fq.gz
#python ${SOURCE} sampleqc -x ont-ligation -p 4 -o $out/barcode05 $input/barcode05.fq.gz
#python ${SOURCE}sampleqc -x ont-ligation -p 4 -o $out/barcode06 $input/barcode06.fq.gz