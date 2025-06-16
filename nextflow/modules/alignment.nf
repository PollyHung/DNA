process alignment {
    tag "${sample_id}"
    cpus 12
    memory '50 GB'
    time '24h'
    
    input:
    tuple val(sample_id), path(r1), path(r2)
    val params
    
    output:
    tuple val(sample_id), path("${sample_id}.sort.tag.dedup.cal.bam"), path("*.bai")
    
    script:
    """
    #!/bin/bash
    folder="${params.home_dir}/${sample_id}"
    cd \$folder
    
    # BWA alignment
    bwa mem -M -t $task.cpus "${params.hg38}" "$r1" "$r2" > "${sample_id}.sam"
    
    # Picard processing
    java -jar /software/Picard/3.2.0/picard.jar SortSam \
        --INPUT "${sample_id}.sam" \
        --OUTPUT "${sample_id}.sort.sam" \
        --SORT_ORDER coordinate \
        --VALIDATION_STRINGENCY SILENT
    rm -f "${sample_id}.sam"
    
    # Read group extraction (simplified)
    READ_NAMES=\$(zgrep -m1 '^@' "$r1" | sed 's/^@//')
    if [[ \$READ_NAMES =~ ^([^L]+)L([0-9]+)C[0-9]+R[0-9]+[^/]+/ ]]; then
        RGPU="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"
        RGID="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"
    else
        IFS=':' read -ra ADDR <<< "\${READ_NAMES// /:}"
        RGPU="\${ADDR[2]}.\${ADDR[3]}"
        RGID="\${ADDR[0]}.\${ADDR[3]}"
    fi
    
    # Add read groups
    java -jar /software/Picard/3.2.0/picard.jar AddOrReplaceReadGroups \
        --INPUT "${sample_id}.sort.sam" \
        --OUTPUT "${sample_id}.sort.tag.sam" \
        --RGID "\$RGID" \
        --RGLB "${params.rglb}" \
        --RGPL "${params.rgpl}" \
        --RGPU "\$RGPU" \
        --RGSM "$sample_id"
    rm -f "${sample_id}.sort.sam"
    
    # Mark duplicates
    java -jar /software/Picard/3.2.0/picard.jar MarkDuplicates \
        --INPUT "${sample_id}.sort.tag.sam" \
        --OUTPUT "${sample_id}.sort.tag.dedup.bam" \
        --METRICS_FILE "${sample_id}.marked_dup_metrics.txt" \
        --ASSUME_SORTED true \
        --REMOVE_DUPLICATES true \
        --VALIDATION_STRINGENCY SILENT \
        --CREATE_INDEX true
    rm -f "${sample_id}.sort.tag.sam"
    
    # Base recalibration
    gatk BaseRecalibrator \
        -I "${sample_id}.sort.tag.dedup.bam" \
        -R "${params.hg38}" \
        --known-sites "${params.known_indels}" \
        --known-sites "${params.mill_indels}" \
        --known-sites "${params.dbsnp}" \
        -O "${sample_id}.recalibration_table.txt"
    
    # Apply BQSR
    gatk ApplyBQSR \
        -R "${params.hg38}" \
        -I "${sample_id}.sort.tag.dedup.bam" \
        --bqsr-recal-file "${sample_id}.recalibration_table.txt" \
        -O "${sample_id}.sort.tag.dedup.cal.bam"
    """
}