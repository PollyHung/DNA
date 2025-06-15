## If prepare.sh is executed, then previous directory is inherited here. 
## But in case you skipped prepare.sh, we'll set directory here again, just in case :D
folder="$HOME/$sample_id"
cd $folder 

## Command 
TMB="/home/polly_hung/TMB/bin/pyTMB.py"
EffGenomeSize="/home/polly_hung/TMB/bin/pyEffGenomeSize.py"


## Load all Modules needed
module load miniconda3
source ~/.bashrc
conda activate pytmb
module load bcftools


## Normalise the vcf 
python "$TMB" -i "${sample_id}.filt.vcf" --effGenomeSize 33280000 \
  --sample "$sample_id" \
  --dbConfig "$CONFIG/annovar.yml" \
  --varConfig "$CONFIG/mutect2.yml" \
  --vaf 0.05 --maf 0.001 --minDepth 20 --minAltDepth 2 \
  --filterLowQual \
  --filterNonCoding \
  --filterSyn \
  --filterPolym --polymDb 1k,gnomad  > "${sample_id}.TMB_results.log"

  
  