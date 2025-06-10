## If prepare.sh and/or alignment.sh is executed, then previous directory is inherited here. 
## But in case you skipped both, we'll set directory here again. 
folder="$HOME/$sample_id"
cd $folder


## Build an empty file to store the qualtiy control
echo "Quality Control for sample $sample_id at $(date)" > "$folder/$sample_id.qualitycontrol.txt"

## Sequence Depth 
samtools depth Kura_A15_DNA.sort.tag.dedup.cal.bam > Kura_A15_DNA.sort.tag.dedup.cal.depth.txt