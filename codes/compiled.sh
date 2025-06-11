#!/bin/bash
#PBS -l nodes=1:ppn=12
#PBS -l mem=50g
#PBS -l walltime=24:00:00
#PBS -m a
#PBS -q medium
#PBS -N KUROMOCHI

## Set Working Directory 
HOME="/home/polly_hung/WES/F25A430000757_HOMukwhX"
SAMPLES="$HOME/mutect_kuro.txt" 

## Hard Coded Parameters 
RGLB="Whole Exome library"                                                      ## [alignment.sh]
RGPL="DNBSEQ"                                                                   ## [alignment.sh]
PARAM="-g -q15 -Q20 -P100 -r25,0"                                               ## [facets.sh]
MUTECT2_NORMAL="/home/polly_hung/WES/F25A430000757_HOMukwhX/Kura_C_DNA/Kura_C_DNA.sort.tag.dedup.cal.bam"

# References  
REF="/home/polly_hung/reference"
HG38="$REF/hg38/Homo_sapiens.GRCh38.dna.primary_assembly.fa"
KNOWN_INDELS="$REF/vcf/Homo_sapiens_assembly38.known_indels.vcf.gz"
MILL_INDELS="$REF/vcf/Mills.indels.contig.adjusted.hg38.vcf.gz"
DBSNP="$REF/vcf/Homo_sapiens_assembly38.dbsnp138.vcf.gz"
SORTED_VCF="$REF/vcf/sorted_vcf_file.vcf.gz"
GNOMAD="$REF/vcf/af-only-gnomad.hg38.vcf.gz"
INTERVAL="$REF/interval/hg38_wes_gatk_stripped.interval_list"

## Sub-scripts 
prepare="/home/polly_hung/WES/codes/prepare.sh"
alignment="/home/polly_hung/WES/codes/alignment.sh"
mutect2="/home/polly_hung/WES/codes/mutation.sh"

## Are samples in their corresponding directory? 
while IFS= read -r sample_id; do

    ## Prepare: If the samples are not in each respective directory, create respective 
    ## directory and move them in. If there are fragments of fastq from one sample, merge
    ## them using samtools. 
    source "$prepare"
    
    ## Alignment: Now at each sample's directory, we perform BWA alignment to hg38 genome 
    ## followed by Picard sort, mark, and deduplication of the SAM file. Interim files 
    ## are deleted once the desired next step file was built to save memory. Finally GATK
    ## was used to introduce base-score recalibration to the BAM file. Both un-calibrated
    ## and calibrated BAM files were preserved. All records are stored in notes.txt
    source "$alignment"
    
    ## Copy Number Version 1 (FACETS/ASCAT): Download FACETS from "https://github.com/mskcc/facets.git"
    
    ## Mutation
    source "$mutect2"
    
done < "$SAMPLES" 


