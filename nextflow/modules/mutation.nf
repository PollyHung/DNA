process mutation {
    tag "${sample_id}"
    cpus 12
    memory '50 GB'
    time '24h'

    input:
    tuple val(sample_id), path(bam), path(bai)
    val params

    output:
    path("${sample_id}.tmb_anno.hg38_multianno.txt")

    script:
    """
    #!/bin/bash
    folder="${params.home_dir}/${sample_id}"
    cd \$folder

    # Mutect2 calling
    gatk Mutect2 \
        -R "${params.hg38}" \
        -I "$bam" \
        -I "${params.paired_normal}" \
        --panel-of-normals "${params.pon}" \
        -germline-resource "${params.gnomad}" \
        -O "${sample_id}.vcf.gz"

    # Contamination estimation
    gatk GetPileupSummaries \
        -I "$bam" \
        -V "${params.gnomad}" \
        -L "${params.interval}" \
        -O "${sample_id}.pileup.table"

    gatk CalculateContamination \
        -I "${sample_id}.pileup.table" \
        -tumor-segmentation "${sample_id}.segment.txt" \
        -O "${sample_id}.contam.txt"

    # Filter variants
    gatk FilterMutectCalls \
        -O "${sample_id}.filt.vcf.gz" \
        -R "${params.hg38}" \
        -V "${sample_id}.vcf.gz" \
        --contamination-table "${sample_id}.contam.txt" \
        --tumor-segmentation "${sample_id}.segment.txt"

    # Annotation
    gunzip "${sample_id}.filt.vcf.gz"
    table_annovar.pl "${sample_id}.filt.vcf" \
        "${params.annovardb}" \
        -buildver hg38 \
        -out "${sample_id}.tmb_anno" \
        -remove \
        -protocol refGeneWithVer,cytoBand,gnomad211_exome,clinvar_20240611,avsnp151,dbnsfp47a \
        -operation g,r,f,f,f,f \
        -nastring . \
        -vcfinput \
        -polish \
        -arg '-hgvs',,,,, \
        -thread $task.cpus
    """
}