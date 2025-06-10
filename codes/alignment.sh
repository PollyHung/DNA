## If prepare.sh is executed, then previous directory is inherited here. 
## But in case you skipped prepare.sh, we'll set directory here again, just in case :D
folder="$HOME/$sample_id"
cd $folder 



## BWA alignment turns FASTQ to SAM
echo "Start BWA alignment (fastq to sam) at $(date)==================================" >> "$folder/$sample_id.notes.txt"
# First, define the forward and backward strands. 
SEQ_1="${sample_id}_1.fq.gz"
SEQ_2="${sample_id}_2.fq.gz"

# Run BWA alignment 
module load bwa
bwa mem -M -t 12 "$HG38" "$SEQ_1" "$SEQ_2" 2>> "$folder/$sample_id.notes.txt" > "${sample_id}.sam"
module unload bwa
echo "Finish BWA alignment===========================================================" >> "$folder/$sample_id.notes.txt"



## Picard turns SAM to BAM 
echo "Start Picard (SAM to BAM)======================================================" >> "$folder/$sample_id.notes.txt"

# sort SAM files 
echo "Sort SAM at $(date)" >> "$folder/$sample_id.notes.txt"
module load Picard
java -jar /software/Picard/3.2.0/picard.jar SortSam \
  --INPUT "${sample_id}.sam" \
  --OUTPUT "${sample_id}.sort.sam" \
  --SORT_ORDER coordinate \
  --VALIDATION_STRINGENCY SILENT

# If file the sorted sam exist, delete the old file 
if [ -e "${sample_id}.sort.sam" ]; then
  rm "${sample_id}.sam"
fi

# extract read group from fastq 
READ_NAMES=$(zgrep '^@' "$SEQ_1" | sed 's/^@//' | sed -n '3p') 
echo "Extracting Read Group Information at $(date)" >> "$folder/$sample_id.notes.txt"
echo "Raw Read Group $READ_NAMES" >> "$folder/$sample_id.notes.txt"

# parse read group header by 2 difference situations
if [[ $READ_NAMES =~ ^([^L]+)L([0-9]+)C[0-9]+R[0-9]+[^/]+/ ]]; then
  RGPU="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"
  RGID="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"
  echo "Platform Unit: $RGPU; Group: $RGID" >> "$folder/$sample_id.notes.txt"
else
  READ_NAMES=${READ_NAMES// /:}  # replace " " by ":" 
  IFS=':' read -r instrument_id run_id flow_cell_id lane tile x_coord y_coord <<< "$READ_NAMES" # parse by ":"
  RGPU="$flow_cell_id.$lane"
  RGID="$instrument_id.$lane"
  echo "Platform Unit: $RGPU; Group: $RGID" >> "$folder/$sample_id.notes.txt"
fi


## Add read groups to the sorted sam
echo "Add read group to SAM at $(date)" >> "$folder/$sample_id.notes.txt"
java -jar /software/Picard/3.2.0/picard.jar AddOrReplaceReadGroups \
  --INPUT "${sample_id}.sort.sam" \
  --OUTPUT "${sample_id}.sort.tag.sam" \
  --RGID "$RGID" \
  --RGLB "$RGLB" \
  --RGPL "$RGPL" \
  --RGPU "$RGPU" \
  --RGSM "$sample_id"

# If file the tagged sam exist, delete the old file 
if [ -e "${sample_id}.sort.tag.sam" ]; then
  rm "${sample_id}.sort.sam"
fi

# Marking Duplicates 
echo "Mark Duplicates of SAM at $(date)" >> "$folder/$sample_id.notes.txt"
java -jar /software/Picard/3.2.0/picard.jar MarkDuplicates \
  --INPUT "${sample_id}.sort.tag.sam" \
  --OUTPUT "${sample_id}.sort.tag.dedup.bam" \
  --METRICS_FILE "${sample_id}.marked_dup_metrics.txt" \
  --ASSUME_SORTED true \
  --REMOVE_DUPLICATES true \
  --VALIDATION_STRINGENCY SILENT \
  --CREATE_INDEX true 

# If file the tagged sam exist, delete the old file 
if [ -e "${sample_id}.sort.tag.dedup.bam" ]; then
  rm "${sample_id}.sort.tag.sam"
fi

# change accessibility 
chmod +x "${sample_id}.sort.tag.dedup.bam"

# unload picard 
module unload Picard

echo "Finish Picard==================================================================" >> "$folder/$sample_id.notes.txt"



## GATK refines BAM by base-score recalibration 
echo "Start GATK (BAM base score recalibration)======================================" >> "$folder/$sample_id.notes.txt"

module load miniconda3
module load GenomeAnalysisTK/4.2.0.0
source activate /software/GenomeAnalysisTK/4.2.0.0

# base recalibrator 
echo "GATK base score recalibration modelling at $(date)" >> "$folder/$sample_id.notes.txt"
gatk BaseRecalibrator \
  -I "${sample_id}.sort.tag.dedup.bam" \
  -R "$HG38" \
  --known-sites "$KNOWN_INDELS" \
  --known-sites "$MILL_INDELS" \
  --known-sites "$DBSNP" \
  -O "${sample_id}.recalibration_table.txt"

# apply recalibrator 
echo "Applt base score recalibration model to BAM at $(date)" >> "$folder/$sample_id.notes.txt"
gatk ApplyBQSR \
  -R "$HG38" \
  -I "${sample_id}.sort.tag.dedup.bam" \
  --bqsr-recal-file "${sample_id}.recalibration_table.txt" \
  -O "${sample_id}.sort.tag.dedup.cal.bam"

# # If the calibrated bam file exists, remove the marked bam file 
# if [ -e "${sample_id}.sort.tag.dedup.cal.bam" ]; then
#   rm "${sample_id}.sort.tag.dedup.bam"
# fi

echo "Finish GATK ====================================================================" >> "$folder/$sample_id.notes.txt"

