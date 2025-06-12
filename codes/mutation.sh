## If prepare.sh is executed, then previous directory is inherited here. 
## But in case you skipped prepare.sh, we'll set directory here again, just in case :D
folder="$HOME/$sample_id"
cd $folder 

## Load all Modules needed
module load miniconda3
module load GenomeAnalysisTK/4.2.0.0
source activate /software/GenomeAnalysisTK/4.2.0.0

# get unfiltered vcf 
gatk Mutect2 \
  -R "$HG38" \
  -I "${sample_id}.sort.tag.dedup.cal.bam" \
  -I "$PAIRED_NORMAL" \
  -germline-resource "$GNOMAD" \
  -O "${sample_id}.vcf.gz"
  
# get pile up summaries for tumour 
gatk GetPileupSummaries \
  -I "${sample_id}.sort.tag.dedup.cal.bam" \
  -V "$GNOMAD" \
  -L "$INTERVAL" \
  -O "${sample_id}.pileup.table"

# filter 
gatk CalculateContamination \
  -I "${sample_id}.pileup.table" \
  -tumor-segmentation "${sample_id}.segment.txt" \
  -O "${sample_id}.contam.txt"

# filter mutect calls 
gatk FilterMutectCalls \
  -O "${sample_id}.filt.vcf.gz" \
  -R "$HG38" \
  -V "${sample_id}.vcf.gz" \
  --contamination-table "${sample_id}.contam.txt" \
  --tumor-segmentation "${sample_id}.segment.txt"
  

