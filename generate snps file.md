# OPEN THE TERMINAL, GIT BASH OR POWERSHELL

## LOG INTO THE HPC
- SSH into the HPC:
  ```bash
  ssh your-psc-username@bridges2.psc.edu
  ```
- When prompted, type your password. You will not see any characters appear on the screen as you type (not even * symbols), but your input is still being recorded. Press Enter when done.

## GO TO PERSONAL STORAGE DIRECTORY
- Navigate to your personal storage directory:
  ```bash
  cd /ocean/projects/agr250001p/your-psc-username
  ```

## MAKE SURE YOU HAVE THE FOLLOWING INPUT FILES

1. The SRA reads `ERR251429_1.fastq` and `ERR251429_2.fastq`. These files should have been downloaded after you submitted the [`sra-download.slurm`](https://github.com/biologysvsu/week-4-repository/blob/main/updated%20slurm%20instructions.md) script.

- These FASTQ files will be subsampled because they are too large for our purposes. We use the software `seqtk`.
- First, add the `seqtk` file to your `PATH` using the following lines of code:
  ```bash
  echo 'export PATH=/ocean/projects/agr250001p/shared/software/seqtk:$PATH' >> ~/.bashrc
  source ~/.bashrc
  ```
- Now you are ready to subsample the files. We will sample 10% of the original file.
  ```bash
  seqtk sample -s100 ERR251429_1.fastq 0.1 > ERR251429_1_subsampled.fastq &
  seqtk sample -s100 ERR251429_2.fastq 0.1 > ERR251429_2_subsampled.fastq &
  ```

2. These are the files required for this run:
   - `ERR251429_1_subsampled.fastq`
   - `ERR251429_2_subsampled.fastq`
3. The Human Genome nucleotide sequences in `fna` format: `GCF_000001405.40_GRCh38.p14_genomic.fna`
4. The Human Genome Bowtie Index Files. These are a list of files with the following characteristics:
   - `human_genome_reference.1.bt2`
   - `human_genome_reference.2.bt2`
   - `human_genome_reference.3.bt2`
   - `human_genome_reference.4.bt2`
   - `human_genome_reference.rev.1.bt2`
   - `human_genome_reference.rev.2.bt2`

#### Note: This index file will take a couple of hours to create if using a single core and a few GB of memory. If you would like to generate these files, you can run the following commands:
```bash
# Request computing resources for 3 hours
interact -t 3:00:00 --ntasks-per-node=16 --mem=31G

# Load the required software
module load bowtie2/2.4.4

# Create the Bowtie Index Files (do not run this if your `.bt2` files are already available)
WORKDIR="/ocean/projects/agr250001p/your-username"
REFERENCE="$WORKDIR/GCF_000001405.40_GRCh38.p14_genomic.fna"

bowtie2-build --threads 16 $REFERENCE human_genome_reference
```

## PREPARE THE SLURM SCRIPT TO RUN THE SNP CALL JOB

- If you do not have the script, you can copy it from our shared weekly folder:
  ```bash
  cp /ocean/projects/agr250001p/shared/week-4-data/snpcall.slurm .
  ```
- If you would like to write the script, simply create the script using the `vi` editor:
  ```bash
  vi snpcall.slurm
  ```
- Type `i` to enter `Insert` mode
- Copy and paste the following workflow. **Make sure you replace `your-username` and `your-email@svsu.edu` with your actual information.**
  ```bash
  #SBATCH --job-name=ERR251429_bowtie2
  #SBATCH --partition=RM-shared
  #SBATCH --ntasks=16
  #SBATCH --mem=31G # Memory for sorting
  #SBATCH --time=04:00:00
  #SBATCH --output=ERR251429_bowtie2.log
  #SBATCH --mail-user=your-email@svsu.edu
  #SBATCH --mail-type=ALL

  # Load required software
  module load bowtie2/2.4.4
  module load samtools
  module load bcftools

  # Define file paths and directories
  WORKDIR="/ocean/projects/agr250001p/your-username"
  READS_1="$WORKDIR/ERR251429_1_subsampled.fastq"
  READS_2="$WORKDIR/ERR251429_2_subsampled.fastq"
  REFERENCE="$WORKDIR/GCF_000001405.40_GRCh38.p14_genomic.fna"
  SAM_OUTPUT="$WORKDIR/ERR251429.sam"
  SORTED_BAM="$WORKDIR/ERR251429_sorted.bam"
  BCF_OUTPUT="$WORKDIR/ERR251429.bcf"
  VCF_OUTPUT="$WORKDIR/ERR251429.vcf"
  COMPRESSED_VCF="$WORKDIR/ERR251429.vcf.gz"

  BOWTIEREF="$WORKDIR/human_bowtie_reference"

  echo "Running Bowtie2..."
  bowtie2 --very-fast -p 16 -x $BOWTIEREF -1 $READS_1 -2 $READS_2 -S $SAM_OUTPUT

  echo "Converting and Sorting BAM in one step..."
  samtools view -@ 16 -bS $SAM_OUTPUT | samtools sort -@ 16 -m 16G -T /scratch/tmp_sort -o $SORTED_BAM

  echo "Indexing BAM file..."
  samtools index $SORTED_BAM

  echo "Calling SNPs with BCFtools..."
  bcftools mpileup -Ou -f $REFERENCE $SORTED_BAM | bcftools call -mv -Ob -o $BCF_OUTPUT

  echo "Converting BCF to VCF..."
  bcftools view -Ov -o $VCF_OUTPUT $BCF_OUTPUT

  echo "Compressing and indexing VCF..."
  bgzip -c $VCF_OUTPUT > $COMPRESSED_VCF
  bcftools index $COMPRESSED_VCF

  echo "Pipeline completed successfully!"
  ```

## SUBMIT YOUR JOB
- Submit your job to the HPC:
  ```bash
  sbatch snpcall.slurm
  ```
- Check your email for an HPC notification or check the status of your run by typing:
  ```bash
  squeue -u your-username
  ```

## YOU HAVE JUST ASSEMBLED A HUMAN GENOME AND COMPARED IT TO A REFERENCE GENOME TO DISCOVER SNPs (Single Nucleotide Polymorphisms)


**The `bam` and `bam.bai` files can be added as a new track to the [IGV (Integrative Genome Viewer)](https://igv.org/app/) or the [UCSC Genome Browser](https://genome.ucsc.edu/cgi-bin/hgCustom?hgsid=2448465611_2ahqxurtL558kFyz4c844qnkzfE9). These files must always be kept together in the same directory, even when downloaded to a local computer, to ensure proper functionality.**

**The `vcf` (Variant Call Format) file contains SNPs (Single Nucleotide Polymorphisms), which are variations in the DNA sequence. This dataset includes approximately 1.5 million SNPs.**

## LET'S STUDY SOME OF THE SNPs -- HOMEWORK 4 STARTS HERE

SNPs can arise due to sequencing errors (which are rare in this curated dataset) or represent true genetic variations among individuals. Some SNPs are associated with specific traits or diseases, including various types of cancer. In this homework assignment, you will analyze 20 randomly selected SNPs from this dataset.

1. Extract 20 random SNPs from the `ERR251429.vcf` file:
   ```bash
   grep -v "^#" ERR251429.vcf | shuf -n 20 > selected_snps.txt
   ```
2. Display the selected SNPs:
   ```bash
   cat selected_snps.txt
   ```
3. Copy the extracted SNP data.
4. Navigate to [ENSEMBL VEP](https://useast.ensembl.org/Tools/VEP).
5. Register and log in if required.
6. Click on `New job`.
7. Paste the copied SNPs into the `Input data` box.
8. Explore the `Additional configurations` section. Click the `+` symbol to expand options and hover over them to understand their purpose. Under the `Prediction` tab, enable the `REVEL` and `ClinPred` options, which predict the potential pathogenicity of SNPs. You may explore other available options as well.
9. Click `Run` and wait a few minutes for the analysis to complete.
10. Review your results and answer the 15 questions provided in Homework 4.
