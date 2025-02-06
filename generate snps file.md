## Add SEQKT to your environment
``` bash
echo 'export PATH=/ocean/projects/agr250001p/shared/software/seqtk:$PATH' >> ~/.bashrc
source ~/.bashrc
```
``` bash
seqtk sample -s100 ERR251429_1.fastq 0.1 > ERR251429_1_subsampled.fastq
```


``` bash
grep -v "^#" ERR251429.vcf | shuf -n 5 > selected_snps.txt
```

Go to https://useast.ensembl.org/Tools/VEP

Paste snps and adjust filters
module loas htslib
bgzip -c vcf > vcf.gz
