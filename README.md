# DNA-seq Alignment Pipeline - GitHub Repository
![WES_PIPELINE](docs/WES%20Pipeline.png)

### Introduction 
This repository contains a bioinformatics pipeline for aligning DNA-based sequencing samples to the hg38 reference genome. The pipeline implements a lego-like design (`compiled.sh`) that enables flexible combination of processing stages:
- Data preparation (Optional; in current repository)
- Raw sequence alignment and deduplication (Essential; in current repository)
- Somatic mutation discovery (Optional)
- Copy number variation calling (Optional; two versions: for sWGS (`QDNAseq.R`), for WES/WGS/TS)

The pipeline has been validated for:
1. Whole Exome Sequencing (`compiled.sh`, `prepare.sh`, `alignment.sh`)
2. Targeted sequencing (`compiled.sh`, `prepare.sh`, `alignment.sh`, `copy_number.sh`)
3. Shallow whole genome sequencing (`compiled.sh`, `alignment.sh`, `QDNAseq.R`) 
4. Whole Genome Sequencing (`alignment.sh`) [https://doi.org/10.1007/s00259-025-07118-0]

### Pipeline Workflow
The pipeline follows a sample-centric organization structure where each sample resides in its own directory. Within each sample directory, processing begins with forward and reverse FASTQ files and, at minimum, produces aligned, deduplicated, base-quality-calibrated BAM files.

1. Sample Preparation (`prepare.sh`): Organizes samples when directories are not pre-established:
   - Creates sample-named directories
   - Moves FASTQ files to corresponding directories
   - Converts `.fastq.gz` to `.fq.gz` format
   - Merges fragmented reads alphabetically
   - Standardizes filenames to `[sample]_1.fq.gz` and `[sample]_2.fq.gz`

2. Alignemnt (`alignment.sh`): Processes prepared samples:
   - Aligns reads to hg38 using BWA-MEM (12-thread parallel)
   - Sorts SAM files via Picard
   - Adds read groups (supports Illumina and BGI formats)
   - Marks and removes duplicates
   - Performs base quality recalibration with GATK
   - Maintains both calibrated and uncalibrated BAM files
   - Cleans interim SAM files automatically

3. Copy Number Calling (`facets.sh`, `facets.R`): Call segmentation profile from WES, WGS, and TS.
   - Run SNP-pipeup with tumour.bam and paired normal.bam or pooled_normal.bam
   - Run FACETS R package on output snp-pipeup data.

4. Copy Number Calling (`QDNAseq.R`): Call Copy Number from shallow whole genome sequencing using [QDNAseq](https://github.com/ccagc/QDNAseq.git) package
   - Define folder analysis: folder/scripts/QDNAseq.R; folder/data/BAM; folder/data/QDNAseq; folder/sample_id.txt, folder/reference_cn_unnormalised.txt
   - Define bins (500) and load BAM file
   - Generate raw copy number and perform quality control
   - Normalisation and Segmentation: correct GC bias, smooth bins, and call segmentation
   - Reference Calibration: Adjusts CN using unnormalized reference `reference_cn_unnormalised.txt`, re-segments and re-calls calibrated data
   - Output TXT, IGV, BED, VCF, SEG and save image.

### Key Package Dependencies
For this code, the following packages and dependencies were used. 
| Tool          | Version       | Purpose                     |
|---------------|---------------|-----------------------------|
| BWA           | 0.7.17        | Sequence alignment          |
| Picard        | 3.2.0         | SAM/BAM processing          |
| GATK          | 4.2.0.0       | Base recalibration          |
| Miniconda3    | 24.1.2        | Environment management      |


### Reference Files Required
Please find it in this shared google drive 
- `Homo_sapiens.GRCh38.dna.primary_assembly.fa` (hg38)
- Known variant databases:
  - `Homo_sapiens_assembly38.known_indels.vcf.gz`
  - `Mills.indels.contig.adjusted.hg38.vcf.gz`
  - `Homo_sapiens_assembly38.dbsnp138.vcf.gz`

### Usage Guide 
Configure only `compiled.sh`:
1. Configure paths in `compiled.sh`:
   ```bash
   HOME="/your/project/directory"
   REF="/path/to/reference/files"
   ```
2. Specify Platform and Library used for Alignment
3. Make a list of sample ids in `samples.txt`
Once everything is configured, submit to PBS scheduler: `qsub compiled.sh`

### Minimum Expected Output Structure
Per sample directory contains:
```
[sample_id]/
├── [sample_id]_1.fq.gz            # Processed forward reads
├── [sample_id]_2.fq.gz            # Processed reverse reads
├── [sample_id].sort.tag.dedup.bam  # uncalibrated BAM
├── [sample_id].sort.tag.dedup.bam.bai  # uncalibrated BAM's index
├── [sample_id].sort.tag.dedup.cal.bam  # Final recalibrated BAM
├── [sample_id].sort.tag.dedup.cal.bam.bai  # Final recalibrated BAM's index
├── [sample_id].recalibration_table.txt # BQSR metrics
└── [sample_id].notes.txt          # Full processing log
```
