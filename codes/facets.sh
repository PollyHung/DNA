## If prepare.sh and/or alignment.sh is executed, then previous directory is inherited here. 
## But in case you skipped both, we'll set directory here again, just in case :D
folder="$HOME/$sample_id"
cd $folder 

## Specify the command and parameter here, if you've compiled it elsewhere please 
## remember to change it here. 
SNP_COMMAND="/home/polly_hung/facets/inst/extcode/snp-pileup"
PARAM="-g -q15 -Q20 -P100 -r25,0" 

## Specify the Input and Output Files 
input="${sample_id}.sort.tag.dedup.cal.bam"
output="${sample_id}.snp-pileup.csv.gz"

## Build and Evaluate Command 
cmd="$SNP_COMMAND $PARAM $SORTED_VCF $output $PAIRED_NORMAL $input" 
eval "$cmd"

## Gunzip the output 
gunzip "$output"

# ## Load R 
# module load miniconda3/24.1.2
# conda activate my_r_env
# 
# R -e "install.packages(c('dplyr', 'ggplot2', 'magrittr'), repos='http://cran.rstudio.com/')"
# 
# 
# Rscript "$CODE/facets.R" "$sample_id"



