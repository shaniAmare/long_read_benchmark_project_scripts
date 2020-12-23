# running bambu

if (!requireNamespace("devtools", quietly = TRUE))
  install.packages("devtools")
devtools::install_github("GoekeLab/bambu")


# The default mode to run *bambu is using 
    # a set of aligned reads (bam files), 
    # reference genome annotations (gtf file, TxDb object, or bambuAnnotation object), and 
    # reference genome sequence (fasta file or BSgenome). 

# bambu will return a summarizedExperiment object with the genomic coordinates for annotated and new transcripts and transcript expression estimates.

