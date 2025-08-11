## Activate Conda
source activate download

## Set Working Directory 
cd "$REF"


## Make Directories 
mkdir -p "resources-broad-hg38-v0"
mkdir -p "ucsc-annotations"
mkdir -p "references-hg38-v0"
mkdir -p "somatic-hg38"
mkdir -p "cnv_germline_pipeline"
mkdir -p "humandb"


## Compare available space to required space
## Are There Enough Space? 
available_space=$(df --output=avail -BG $HOME | tail -1 | tr -d 'G')
if (( $(echo "$available_space >= 40" | bc -l) )); then
    echo "Sufficient space available: ${available_space} GB."
    
    # Set Directory 
    cd "$REF/resources-broad-hg38-v0"
    
    # Proceed with downloading using gsutil
    gsutil -m cp -r \
       "gs://genomics-public-data/resources/broad/hg38/v0/1000G.phase3.integrated.sites_only.no_MATCHED_REV.hg38.vcf" \
       "gs://genomics-public-data/resources/broad/hg38/v0/1000G.phase3.integrated.sites_only.no_MATCHED_REV.hg38.vcf.idx" \
       "gs://genomics-public-data/resources/broad/hg38/v0/1000G_omni2.5.hg38.vcf.gz" \
       "gs://genomics-public-data/resources/broad/hg38/v0/1000G_omni2.5.hg38.vcf.gz.tbi" \
       "gs://genomics-public-data/resources/broad/hg38/v0/1000G_phase1.snps.high_confidence.hg38.vcf.gz" \
       "gs://genomics-public-data/resources/broad/hg38/v0/1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi" \
       "gs://genomics-public-data/resources/broad/hg38/v0/Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz" \
       "gs://genomics-public-data/resources/broad/hg38/v0/Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz.tbi" \
       "gs://genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf" \
       "gs://genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf.idx" \
       "gs://genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.dict" \
       "gs://genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta" \
       "gs://genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.alt" \
       "gs://genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.amb" \
       "gs://genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.ann" \
       "gs://genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.bwt" \
       "gs://genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.pac" \
       "gs://genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.sa" \
       "gs://genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.fai" \
       "gs://genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.known_indels.vcf.gz" \
       "gs://genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.known_indels.vcf.gz.tbi" \
       "gs://genomics-public-data/resources/broad/hg38/v0/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz" \
       "gs://genomics-public-data/resources/broad/hg38/v0/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi" \
       "gs://genomics-public-data/resources/broad/hg38/v0/hapmap_3.3.hg38.vcf.gz" \
       "gs://genomics-public-data/resources/broad/hg38/v0/hapmap_3.3.hg38.vcf.gz.tbi" \
       "gs://genomics-public-data/resources/broad/hg38/v0/scattered_calling_intervals" \
       "gs://genomics-public-data/resources/broad/hg38/v0/wgs_calling_regions.hg38.interval_list" \
       .

else
    echo "Insufficient space. You need at least ${required_space} GB of free space."
fi


## Compare available space to required space
available_space=$(df --output=avail -BG $HOME | tail -1 | tr -d 'G')
if (( $(echo "$available_space >= 1" | bc -l) )); then
    echo "Sufficient space available: ${available_space} GB."
    
    # Set Directory 
    cd "$REF/references-hg38-v0"
    
    # Proceed with downloading using gsutil
    gsutil -m cp -r \
       "gs://genomics-public-data/references/hg38/v0/exome_calling_regions.v1.interval_list" \
       "gs://genomics-public-data/references/hg38/v0/exome_calling_regions.v1.interval_list.deprecated.DSDEGP-652" \
       "gs://genomics-public-data/references/hg38/v0/exome_evaluation_regions.v1.interval_list" \
       "gs://genomics-public-data/references/hg38/v0/wgs_calling_regions.hg38.interval_list" \
       "gs://genomics-public-data/references/hg38/v0/wgs_coverage_regions.hg38.interval_list" \
       "gs://genomics-public-data/references/hg38/v0/wgs_evaluation_regions.hg38.interval_list" \
       "gs://genomics-public-data/references/hg38/v0/wgs_metrics_intervals.interval_list" \
       .

else
    echo "Insufficient space. You need at least ${required_space} GB of free space."
fi


## Compare available space to required space
available_space=$(df --output=avail -BG $HOME | tail -1 | tr -d 'G')
if (( $(echo "$available_space >= 1" | bc -l) )); then
    echo "Sufficient space available: ${available_space} GB."
    
    # Set Directory 
    cd "$REF/ucsc-annotations"
    
    # Proceed with downloading using gsutil
    gsutil -m cp -r \
       "gs://genomics-public-data/ucsc/annotations/knownGene-GRCh38.txt" \
       "gs://genomics-public-data/ucsc/annotations/knownGene-hg19.txt" \
       "gs://genomics-public-data/ucsc/annotations/refFlat-GRCh38.txt" \
       "gs://genomics-public-data/ucsc/annotations/refFlat-hg19.txt" \
       "gs://genomics-public-data/ucsc/annotations/refGene-GRCh38.txt" \
       "gs://genomics-public-data/ucsc/annotations/refGene-hg19.txt" \
       .

else
    echo "Insufficient space. You need at least ${required_space} GB of free space."
fi


## Compare available space to required space
available_space=$(df --output=avail -BG $HOME | tail -1 | tr -d 'G')
if (( $(echo "$available_space >= 15" | bc -l) )); then
    echo "Sufficient space available: ${available_space} GB."
    
    # Set Directory 
    cd "$REF/somatic-hg38"
    
    # Proceed with downloading using gsutil
    gsutil -m cp -r \
       "gs://gatk-best-practices/somatic-hg38/1000g_pon.hg38.vcf.gz" \
       "gs://gatk-best-practices/somatic-hg38/1000g_pon.hg38.vcf.gz.tbi" \
       "gs://gatk-best-practices/somatic-hg38/CNV.hg38liftover.bypos.v1.CR1_event_added.mod.seg" \
       "gs://gatk-best-practices/somatic-hg38/CNV_and_centromere_blacklist.hg38liftover.list" \
       "gs://gatk-best-practices/somatic-hg38/af-only-gnomad.hg38.vcf.gz" \
       "gs://gatk-best-practices/somatic-hg38/af-only-gnomad.hg38.vcf.gz.tbi" \
       "gs://gatk-best-practices/somatic-hg38/final_centromere_hg38.seg" \
       "gs://gatk-best-practices/somatic-hg38/gatk-builds_contamination-patch-5-27-2019.jar" \
       "gs://gatk-best-practices/somatic-hg38/hcc1143_N_clean.bai" \
       "gs://gatk-best-practices/somatic-hg38/hcc1143_N_clean.bam" \
       "gs://gatk-best-practices/somatic-hg38/small_exac_common_3.hg38.vcf.gz" \
       "gs://gatk-best-practices/somatic-hg38/small_exac_common_3.hg38.vcf.gz.tbi" \
       .

else
    echo "Insufficient space. You need at least ${required_space} GB of free space."
fi


## Compare available space to required space
available_space=$(df --output=avail -BG $HOME | tail -1 | tr -d 'G')
if (( $(echo "$available_space >= 1" | bc -l) )); then
    echo "Sufficient space available: ${available_space} GB."
    
    # Set Directory 
    cd "$REF/cnv_germline_pipeline"
    
    # Proceed with downloading using gsutil
    gsutil -m cp \
      "gs://gatk-best-practices/cnv_germline_pipeline/chr20xy.interval_list" \
      "gs://gatk-best-practices/cnv_germline_pipeline/contig_ploidy_priors_chr20xy.tsv" \
      "gs://gatk-best-practices/cnv_germline_pipeline/hg38.k100.umap.single.merged.bed.gz" \
      "gs://gatk-best-practices/cnv_germline_pipeline/hg38.k100.umap.single.merged.bed.gz.tbi" \
      "gs://gatk-best-practices/cnv_germline_pipeline/hg38_segmental_duplication_track.bed" \
      "gs://gatk-best-practices/cnv_germline_pipeline/hg38_segmental_duplication_track.bed.idx" \
      "gs://gatk-best-practices/cnv_germline_pipeline/ice_targets_chr20xy.interval_list" \
      "gs://gatk-best-practices/cnv_germline_pipeline/ice_targets_chr20xy.preprocessed.filtered.interval_list" \
      "gs://gatk-best-practices/cnv_germline_pipeline/segmental-duplication-20xy.bed.gz" \
      "gs://gatk-best-practices/cnv_germline_pipeline/segmental-duplication-20xy.bed.gz.tbi" \
      "gs://gatk-best-practices/cnv_germline_pipeline/umap-k100-single-read-mappability-merged-20xy.bed.gz" \
      "gs://gatk-best-practices/cnv_germline_pipeline/umap-k100-single-read-mappability-merged-20xy.bed.gz.tbi" \
      "gs://gatk-best-practices/cnv_germline_pipeline/wes-do-gc-contig-ploidy-model.tar.gz" \
      "gs://gatk-best-practices/cnv_germline_pipeline/wes-do-gc-gcnv-model-0.tar.gz" \
      "gs://gatk-best-practices/cnv_germline_pipeline/wes-do-gc-gcnv-model-1.tar.gz" \
      .

else
    echo "Insufficient space. You need at least ${required_space} GB of free space."
fi


## module load ANNOVAR/2020Jun08
available_space=$(df --output=avail -BG $HOME | tail -1 | tr -d 'G')
if (( $(echo "$available_space >= 120" | bc -l) )); then
    echo "Sufficient space available: ${available_space} GB."
    
    # Set Directory 
    module load ANNOVAR/2020Jun08
    cd "$REF/humandb/"
    
    # Proceed with downloading using gsutil
    annotate_variation.pl -buildver hg38 -downdb -webfrom annovar refGeneWithVer .
    annotate_variation.pl -buildver hg38 -downdb cytoBand .
    annotate_variation.pl -buildver hg38 -downdb -webfrom annovar gnomad211_exome .
    annotate_variation.pl -buildver hg38 -downdb -webfrom annovar avsnp151 .
    annotate_variation.pl -buildver hg38 -downdb -webfrom annovar dbnsfp47a .
    annotate_variation.pl -buildver hg38 -downdb -webfrom annovar clinvar_20240611 .
    
    # Compress 2 very large files 
    bgzip --compress-level 9 --threads $cores hg38_dbnsfp47a.txt
    bgzip --compress-level 9 --threads $cores hg38_avsnp151.txt
    
else
    echo "Insufficient space. You need at least ${required_space} GB of free space."
fi



