## Run
module load sra-toolkit
vdb-config --interactive

## BLAST Tutorial 2: Running BLAST with Custom Databases

### Steps:

``` bash
cd /ocean/projects/agr250001p/your-username
```
### Obtain resources to run job manually
```
interact -p RM-shared --ntasks-per-node=8 -t 01:00:00
```
1.  **Download the nucleotide sequence database**
   ```bash
   wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GCF_000001405.40_GRCh38.p14_cds_from_genomic.fna.gz
   gunzip GCF_000001405.40_GRCh38.p14_cds_from_genomic.fna.gz
   ```

2. **Load BLAST and create a nucleotide database**
   ```bash
   module load BLAST
   makeblastdb -in GCF_000001405.40_GRCh38.p14_cds_from_genomic.fna -dbtype nucl -out human_nucl_db
   ```

3. **Run BLASTN against the nucleotide database**
   ```bash
   blastn -task megablast -query your-unk.fasta -db human_nucl_db -out results_nucl.txt -num_threads 8 -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore stitle"
   ```

4. **Download the protein sequence database**
   ```bash
   wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GCF_000001405.40_GRCh38.p14_protein.faa.gz
   gunzip GCF_000001405.40_GRCh38.p14_protein.faa.gz
   ```

5. **Create a protein database**
   ```bash
   makeblastdb -in GCF_000001405.40_GRCh38.p14_protein.faa -dbtype prot -out human_prot_db
   ```

6. **Run BLASTP against the protein database**
   ```bash
   blastp -query unk.fasta -db human_prot_db -out results_prot.txt -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore stitle"
   ```

7. **Copy results to the repository folder and push to GitHub**
   ```bash
   cp results_nucl.txt results_prot.txt ~/repository_folder/
   cd ~/repository_folder
   git add results_nucl.txt results_prot.txt
   git commit -m "Added BLAST results"
   git push origin main
   ```

8. **Open BLAST results in Excel for visualization**
   - Open Excel and go to `File > Open`.
   - Select `results_nucl.txt` or `results_prot.txt`.
   - When prompted, choose `Delimited` and select `Tab` as the delimiter.
   - Click `Finish` to load the data into columns for easy visualization and analysis.
