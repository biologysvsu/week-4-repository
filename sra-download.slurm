#!/bin/bash
#SBATCH --job-name=download_sra       # Name of the job
#SBATCH --output=download_sra.log     # Output log file
#SBATCH --time=04:00:00               # Time limit (3 hours to be safe and if files larger that 10 Gb)
#SBATCH --ntasks=1                    # Use 1 task
#SBATCH --mem=1G                      # Request 2 GB of memory
#SBATCH --partition=RM-shared          # Use the standard partition (ensure it has internet access)
#SBATCH --mail-user=jparedes@svsu.edu  # Add your email address here
#SBATCH --mail-type=ALL               # Send email notifications for all job states (BEGIN, END, FAIL)

# Load the SRA Toolkit module. This is the software we will use for this job. Already available in the HPC, but must be loaded.
module load sra-toolkit

# Set the storage directory. We dont want any large files outside the storage directory.
STORAGE_DIR="/ocean/projects/agr250001p/jparedesmontero"

# Navigate to the storage directory
cd $STORAGE_DIR

# Download the dataset
fastq-dump --split-files ERR251429    # Replace SRX123456 with an SRA accession number of your choice
