## If prepare.sh is executed, then previous directory is inherited here. 
## But in case you skipped prepare.sh, we'll set directory here again, just in case :D
folder="$HOME/$sample_id"
cd $folder 


## Load All Modules 
module load ANNOVAR/2020Jun08


## Download Database 
# annotate_variation.pl -buildver hg38 -downdb -webfrom annovar refGeneWithVer humandb/
# annotate_variation.pl -buildver hg38 -downdb cytoBand humandb/
# annotate_variation.pl -buildver hg38 -downdb -webfrom annovar gnomad211_exome humandb/ 
# annotate_variation.pl -buildver hg38 -downdb -webfrom annovar avsnp151 humandb/ 
# annotate_variation.pl -buildver hg38 -downdb -webfrom annovar dbnsfp47a humandb/
# annotate_variation.pl -buildver hg38 -downdb -webfrom annovar clinvar_20240611 humandb/


## Run 
table_annovar.pl "${sample_id}.filt.vcf" \
    humandb/ \
    -buildver hg38 \
    -out "${sample_id}.tmb_anno" \
    -remove \
    -protocol refGene,gnomad30_genome,clinvar \
    -operation g,f,f \
    -nastring . \
    -vcfinput \
    -polish \
    -arg '-hgvs',, \
    -thread 12












