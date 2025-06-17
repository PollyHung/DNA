## If prepare.sh is executed, then previous directory is inherited here. 
## But in case you skipped prepare.sh, we'll set directory here again, just in case :D
folder="$HOME/$sample_id"
cd $folder 

## Load all Modules needed
module load miniconda3
module load GenomeAnalysisTK/4.2.0.0
source activate /software/GenomeAnalysisTK/4.2.0.0
module load ANNOVAR/2020Jun08

# get unfiltered vcf 
gatk Mutect2 \
  -R "$HG38" \
  -I "${sample_id}.sort.tag.dedup.cal.bam" \
  -I "$PAIRED_NORMAL" \
  --panel-of-normals "$PON" \
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

# gunzip the output 
gunzip "${sample_id}.filt.vcf.gz"
chmod +x "${sample_id}.filt.vcf"

# run annovar on the gunzipped output 
table_annovar.pl "${sample_id}.filt.vcf" \
    "$ANNOVARDB" \
    -buildver hg38 \
    -out "${sample_id}.tmb_anno" \
    -remove \
    -protocol refGeneWithVer,cytoBand,gnomad211_exome,clinvar_20240611,avsnp151,dbnsfp47a \
    -operation g,r,f,f,f,f \
    -nastring . \
    -vcfinput \
    -polish \
    -arg '-hgvs',,,,, \
    -thread 12

# deactivate GATK
module unload GenomeAnalysisTK/4.2.0.0
source deactivate /software/GenomeAnalysisTK/4.2.0.0


cd "$ORIG" # go to the home directory to activate pytmb ------------------------------------
module load miniconda3
source ~/.bashrc
conda activate pytmb
module load bcftools
cd $folder # then go to the individual sample folder again ---------------------------------

# TMB command 
TMB="/home/polly_hung/TMB/bin/pyTMB.py"

# run tmb calling
python "$TMB" -i "${sample_id}.filt.vcf" --effGenomeSize 33280000 \
  --sample "$sample_id" \
  --dbConfig "$CONFIG/annovar.yml" \
  --varConfig "$CONFIG/mutect2.yml" \
  --vaf 0.05 --maf 0.001 --minDepth 20 --minAltDepth 2 \
  --filterLowQual \
  --filterNonCoding \
  --filterSyn \
  --filterPolym --polymDb 1k,gnomad  > "${sample_id}.TMB_results.log"










