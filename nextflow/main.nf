nextflow.enable.dsl = 2

// Configuration parameters
params {
    home_dir = "/home/polly_hung/WES/F25A430000757_HOMukwhX"
    samples_file = "${params.home_dir}/mutect_oaw28.txt"
    paired_normal = "${params.home_dir}/OAW28_C_DNA/OAW28_C_DNA.sort.tag.dedup.cal.bam"
    
    // Reference files
    ref_dir = "/home/polly_hung/reference"
    hg38 = "${params.ref_dir}/hg38/Homo_sapiens.GRCh38.dna.primary_assembly.fa"
    known_indels = "${params.ref_dir}/vcf/Homo_sapiens_assembly38.known_indels.vcf.gz"
    mill_indels = "${params.ref_dir}/vcf/Mills.indels.contig.adjusted.hg38.vcf.gz"
    dbsnp = "${params.ref_dir}/vcf/Homo_sapiens_assembly38.dbsnp138.vcf.gz"
    gnomad = "${params.ref_dir}/vcf/af-only-gnomad.hg38.vcf.gz"
    interval = "${params.ref_dir}/interval/hg38_wes_gatk_stripped.interval_list"
    pon = "${params.ref_dir}/vcf/somatic-hg38_1000g_pon.hg38.vcf.gz"
    annovardb = "${params.ref_dir}/humandb/"
    
    // Hardcoded parameters
    rglb = "Whole Exome library"
    rgpl = "DNBSEQ"
}

// Read sample IDs
Channel.fromPath(params.samples_file)
    | splitCsv(header: false) 
    | map { row -> row[0] } 
    | set { sample_ch }

workflow {
    prepare(sample_ch)
    alignment(prepare.out, params)
    mutation(alignment.out, params)
}

// Include process definitions
include { prepare } from './modules/prepare'
include { alignment } from './modules/alignment'
include { mutation } from './modules/mutation'