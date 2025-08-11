## Give the folder address 
folder="$DATA/$sample_id"

## If folder not found, create folder 
if [ ! -d "$folder" ]; then
  mkdir -p "$folder"
fi

## Create a note for reproducibility 
echo "
================================================================================
Preparing Analysis for sample $sample_id at $(date)

" > "$folder/$sample_id.notes.txt"

## If fastq files exist at the same level as the folder just created, 
## move all files with same sample prefix to the corresponding folder. 
if find "$DATA" -maxdepth 1 -name "$sample_id*" -type f | grep -q .; then
  echo "Sample folder not found, created sample folder. 
        Move corresponding raw fastq/fq files to sub-directory" >> "$folder/$sample_id.notes.txt"
  find "$DATA" -maxdepth 1 -name "$sample_id*" -type f -exec mv -v {} "$folder"/ \;
fi

## change directory to corresponding sample 
cd "$folder"
echo "Change directory to $sample_id" >> "$folder/$sample_id.notes.txt"

## Rename .fastq.gz files to .fq.gz
for file in *.fastq.gz; do
  if [ -e "$file" ]; then
    echo "Renaming suffix: fastq.gz to fq.gz" >> "$folder/$sample_id.notes.txt"
    mv -- "$file" "${file%.fastq.gz}.fq.gz"
  fi
done

## List all the R1 and R2 fastq files in current directory 
r1_files=(*_1.fq.gz) ## list all the R1 fastq files, retrieve it by echo "${r1_files[@]}"
r2_files=(*_2.fq.gz) ## list all the R2 fastq files

## If there are multiple fragmented R1/R2 fastq files, merge them using samtools merge 
## if not, rename to standard naming 
## For Forward Strand 
if [ ${#r1_files[@]} -gt 1 ] ; then
  echo "Fragmented forward strand found" >> "$folder/$sample_id.notes.txt"
  echo "Merging forward strand sequences from: ${r1_files[*]}" >> "$folder/$sample_id.notes.txt"
  cat *_1.fq.gz > "${sample_id}_1.fq.gz" ## Merging
else
  echo "Single forward strand detected. Renaming to standard format..." >> "$folder/$sample_id.notes.txt"
  mv "${r1_files[0]}" "${sample_id}_1.fq.gz" ## Renaming 
fi
## For Backward Strand 
if [ ${#r2_files[@]} -gt 1 ]; then
  echo "Fragmented backward strand found" >> "$folder/$sample_id.notes.txt"
  echo "Merging backward strand sequences from: ${r2_files[*]}" >> "$folder/$sample_id.notes.txt"
  cat *_2.fq.gz > "${sample_id}_2.fq.gz"
else
  echo "Single backward strand detected. Renaming to standard format..." >> "$folder/$sample_id.notes.txt"
  mv "${r2_files[0]}" "${sample_id}_2.fq.gz"
fi

# ## Note to Self: 
# echo "
# ------------------------------------------------------------------------------
# If data is paired-end (i.e., you have corresponding R2 files for the reverse strand):
# R1 and R2 files MUST be merged in the SAME order.
# Example:
#   If you merge R1 files as R1_A.fastq + R1_B.fastq → merged_R1.fastq,
#   Then R2 files must be: R2_A.fastq + R2_B.fastq → merged_R2.fastq.
# The n-th read in merged_R1.fastq must correspond to the n-th read in merged_R2.fastq to preserve pairs.
# Mismatched orders will break pairings and cause errors in alignment/analysis.
# ------------------------------------------------------------------------------
# " >> "$folder/$sample_id.notes.txt"

## Print current directory 
echo "

Finish Sample Preparation for $sample_id at $(date)
Current Directory: $(pwd)
================================================================================
" >> "$folder/$sample_id.notes.txt"







