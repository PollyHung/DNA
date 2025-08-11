#!/bin/bash
#PBS -l nodes=1:ppn=12
#PBS -l mem=120g
#PBS -l walltime=24:00:00
#PBS -m a
#PBS -q large
#PBS -N compress

## Global Calling 
module load miniconda3/24.1.2


## Set Working Directory 
ORIG="/home/polly_hung"
DATA="/home/polly_hung/WES/F25A430000757_HOMukwhX"
SAMPLES="$DATA/mutect_oaw28.txt" 

cores=$(nproc)

## Hard Coded Parameters 
RGLB="Whole Exome library"                                                      ## [alignment.sh]
RGPL="DNBSEQ"                                                                   ## [alignment.sh]
PARAM="-g -q15 -Q20 -P100 -r25,0"                                               ## [facets.sh]
PAIRED_NORMAL="/home/polly_hung/WES/F25A430000757_HOMukwhX/Kura_C_DNA/Kura_C_DNA.sort.tag.dedup.cal.bam"

# References  
REF="/home/polly_hung/reference"
HG38="$REF/hg38/Homo_sapiens.GRCh38.dna.primary_assembly.fa"
KNOWN_INDELS="$REF/vcf/Homo_sapiens_assembly38.known_indels.vcf.gz"
MILL_INDELS="$REF/vcf/Mills.indels.contig.adjusted.hg38.vcf.gz"
DBSNP="$REF/vcf/Homo_sapiens_assembly38.dbsnp138.vcf.gz"
SORTED_VCF="$REF/vcf/sorted_vcf_file.vcf.gz"
GNOMAD="$REF/vcf/af-only-gnomad.hg38.vcf.gz"
INTERVAL="$REF/interval/hg38_wes_gatk_stripped.interval_list"
PON="$REF/vcf/somatic-hg38_1000g_pon.hg38.vcf.gz"
PON_DB="$REF/gatk_pondb"
ANNOVARDB="$REF/humandb/"
CONFIG="$REF/TMB/config"
BAIT="$REF/interval/SureSelectV6r2/S07604514_Covered_Clean_Ensembl.bed"
PURECNOUT="$REF/purecn"
MAPPABILITY="$REF/bigwig/GCA_000001405.15_GRCh38_no_alt_analysis_set_100.bw"
REPEAT="$REF/bed/hg38.repeats.ensembl.sorted.bed"

## Sub-scripts 
CODE="/home/polly_hung/WES/codes"
prepare="$CODE/prepare.sh"
alignment="$CODE/alignment.sh"
mutation="$CODE/mutation.sh"
facets="$CODE/facets.sh"

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
    
    ## Copy Number Estimation by FACETS on WES/WGS/Targeted Sequencing, a two-step process
    ## first by SNP-pileup given a tumour and a normal bam file (preferablly matched), followed
    ## by copy number calling using FACETS R package 
    source "$facets"
    
    ## Somatic Mutation Analysis by Mutect2 in combination with annotation tools like Annovar
    ## and funcotator. Somatic mutation called with paired normal sample, panel of normal 
    ## downloaded from GATK gs://gatk-best-practices/somatic-hg38/1000g_pon.hg38.vcf.gz, 
    ## unless specified otherwise in mutation.sh. 
    source "$mutation"

    
done < "$SAMPLES" 

