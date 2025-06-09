# WES Alignment Pipeline - GitHub Repository
![WES_PIPELINE](docs/WES%20Pipeline.png)

This repository contains a bioinformatics pipeline for aligning whole exome sequencing (WES) samples to the hg38 reference genome. The pipeline automates sample preparation, alignment, deduplication, and base quality recalibration using industry-standard tools.

### Pipeline Workflow
1. **Sample Preparation (`prepare.sh`)**  
   - Creates sample-specific directories  
   - Organizes FASTQ files  
   - Merges fragmented reads  
   - Standardizes filenames  

2. **Alignment (`alignment.sh`)**  
   - **BWA-MEM**: Aligns FASTQ → SAM  
   - **Picard Tools**:  
     - Sorts SAM files  
     - Adds read groups  
     - Marks/removes duplicates (output: BAM)  
   - **GATK**:  
     - Base Quality Score Recalibration (BQSR)  
     - Outputs refined BAM files  

3. **Execution (`compiled.sh`)**  
   - PBS job scheduler script  
   - Processes multiple samples sequentially  
   - Manages dependencies and resources  

#### Dependencies
| Tool          | Version       | Purpose                     |
|---------------|---------------|-----------------------------|
| BWA           | 0.7.17        | Sequence alignment          |
| Picard        | 3.2.0         | SAM/BAM processing          |
| GATK          | 4.2.0.0       | Base recalibration          |
| Miniconda3    | 24.1.2        | Environment management      |


#### Reference Files Required
Please find it in this shared google drive
- `Homo_sapiens.GRCh38.dna.primary_assembly.fa` (hg38)
- Known variant databases:
  - `Homo_sapiens_assembly38.known_indels.vcf.gz`
  - `Mills.indels.contig.adjusted.hg38.vcf.gz`
  - `Homo_sapiens_assembly38.dbsnp138.vcf.gz`

#### Usage
1. Configure paths in `compiled.sh`:
   ```bash
   HOME="/your/project/directory"
   REF="/path/to/reference/files"
   ```
2. Specify Platform and Library used for Alignment
3. Add sample IDs to `samples.txt`
4. Submit to PBS scheduler:
   ```bash
   qsub compiled.sh
   ```

#### Output Structure
Per sample directory contains:
```
[sample_id]/
├── [sample_id]_1.fq.gz            # Processed forward reads
├── [sample_id]_2.fq.gz            # Processed reverse reads
├── [sample_id].sort.tag.dedup.cal.bam  # Final recalibrated BAM
├── [sample_id].recalibration_table.txt # BQSR metrics
└── [sample_id].notes.txt          # Full processing log
```

1. Validate reference file paths before execution
2. Monitor PBS logs for resource usage
3. Verify read group information in `.notes.txt`
4. Store raw FASTQ files outside pipeline directory

This pipeline implements GATK best practices for WES data processing and is optimized for reproducibility in cluster environments.
