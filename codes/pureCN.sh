## If prepare.sh is executed, then previous directory is inherited here. 
## But in case you skipped prepare.sh, we'll set directory here again, just in case :D
folder="$DATA/$sample_id"
cd $folder 


## Load Modules 
module load miniconda3/24.1.2
source activate purecn

## PureCN
export PURECN="/home/polly_hung/.conda/envs/purecn/lib/R/library/PureCN/extdata"

## 2. Prepare environment and assay-specific reference files
## Download Mappability from https://s3.amazonaws.com/purecn/GCA_000001405.15_GRCh38_no_alt_analysis_set_100.bw
## Download baits interval from Sure Select https://kb.10xgenomics.com/hc/en-us/articles/115004150923-Where-can-I-find-the-Agilent-Target-BED-files
## Reptiming not used as "optional and provides only a minor benefit for coverage normalization"
## Plus we cant' find a hg38 version of it so 
## haha 
## ALSO!! You need to make the bed file 3 column only, so if you get it from Sure Select 
## Make sure to remove the first two lines 
## grep -vE '^browser|^track' S07604514_Covered.bed > S07604514_Covered_Clean.bed
## or else, ERROR!!!! 
## To avoid warning please install conda install bioconda::bioconductor-txdb.hsapiens.ucsc.hg38.knowngene
## Also conda install bioconda::bioconductor-org.hs.eg.db
## use this to clean up the bait file chr so that it goes from ucsc style to ensembl style 
# awk 'BEGIN {OFS="\t"}
#      {
#         # Remove "chr" prefix
#         gsub(/^chr/, "", $1);
# 
#         # Remove "_random" and replace "v" with "."
#         gsub(/_random/, "", $1);
#         gsub(/v/, ".", $1);
#         gsub(/^.*_/, "", $1);
# 
#         print $1, $2, $3, $4
#      }' S07604514_Covered_Clean.bed > S07604514_Covered_Clean_Ensembl.bed
# Rscript $PURECN/IntervalFile.R \
#   --in-file "$BAIT" \
#   --fasta "$HG38" \
#   --out-file "$PURECNOUT/baits_intervals.txt" \
#   --off-target \
#   --genome hg38 \
#   --export "$PURECNOUT/baits_optimized.bed" \
#   --mappability "$MAPPABILITY" \
#   --force
  
## 4.1 Coverage
Rscript $PURECN/Coverage.R \
  --out-dir "$folder" \
  --bam "${sample_id}.sort.tag.dedup.cal.bam" \
  --intervals "$PURECNOUT/baits_intervals.txt" \
  --cores 12


# ## 4.2 NormalDB
# ls -a "*C_DNA.sort.tag.dedup.cal_coverage_loess.txt.gz" | cat > "$DATA/example_normal_coverages.list"
Rscript $PURECN/NormalDB.R \
  --out-dir "$PURECNOUT" \
  --coverage-files "$DATA/example_normal_coverages.list" \
  --genome hg38 \
  --force
  
  
## 4.3 PureCN
# Download simple repeats here 
# "https://42basepairs.com/browse/web/giab/technical/ucsc_bed_files?file=hg38.repeats.bed.gz&preview=igv"
# Rscript $PURECN/PureCN.R \
#   --out $folder \
#   --sampleid "${sample_id}" \
#   --tumor "${sample_id}.sort.tag.dedup.cal_coverage_loess.txt.gz" \
#   --normal "/home/polly_hung/WES/F25A430000757_HOMukwhX/Kura_C_DNA/Kura_C_DNA.sort.tag.dedup.cal_coverage_loess.txt.gz" \
#   --vcf "${sample_id}.filt.vcf" \
#   --intervals "$PURECNOUT/baits_intervals.txt" \
#   --snp-blacklist "$REPEAT" \
#   --genome "hg38" \
#   --max-purity 0.99 \
#   --min-purity 0.90 \
#   --max-copy-number 8 \
#   --max-segments 1000 \
#   --post-optimize \
#   --model-homozygous \
#   --min-total-counts 20
Rscript $PURECN/PureCN.R \
  --out $folder \
  --tumor "${sample_id}.sort.tag.dedup.cal_coverage_loess.txt.gz" \
  --sampleid "${sample_id}" \
  --vcf "${sample_id}.filt.vcf" \
  --normaldb "$PURECNOUT/normalDB_hg38.rds" \
  --intervals "$PURECNOUT/baits_intervals.txt" \
  --genome "hg38" \
  --snp-blacklist "$REPEAT" \
  --min-total-counts 20



# gs://firecloud-tcga-open-access/tutorial/bams/C835.HCC1143_BL.4.bam

