process prepare {
    tag "${sample_id}"
    
    input:
    val sample_id
    
    output:
    tuple val(sample_id), path("${sample_id}_1.fq.gz"), path("${sample_id}_2.fq.gz")
    
    script:
    """
    #!/bin/bash
    folder="${params.home_dir}/${sample_id}"
    mkdir -p \$folder
    cd \$folder
    
    # Move and rename FASTQ files
    find "${params.home_dir}" -maxdepth 1 -name "${sample_id}*" -type f -exec mv {} . \;
    for file in *.fastq.gz; do [ -f "\$file" ] && mv "\$file" "\${file%.fastq.gz}.fq.gz"; done
    
    # Merge R1/R2 if fragmented
    cat *_1.fq.gz > "${sample_id}_1.fq.gz" 2>/dev/null || :
    cat *_2.fq.gz > "${sample_id}_2.fq.gz" 2>/dev/null || :
    
    # Handle single files
    [ -f "${sample_id}_1.fq.gz" ] || mv *1.fq.gz "${sample_id}_1.fq.gz"
    [ -f "${sample_id}_2.fq.gz" ] || mv *2.fq.gz "${sample_id}_2.fq.gz"
    """
}