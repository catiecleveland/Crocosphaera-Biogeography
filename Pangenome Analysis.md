# Crocosphaera Pangenome Analysis

```bash
# install Anvi'o-7.1 with conda prior to analysis

conda activate anvio-7
```

```bash
# reformat the .fasta files using appropriate characters and headers to be used in the pangenome workflow 

anvi-script-reformat-fasta --simplify-names --prefix GCA_000017845 GCA_000017845.1_ASM1784v1_genomic.fna -o GCA_000017845.fa

anvi-script-reformat-fasta --simplify-names --prefix GCA_000169335 GCA_000169335.1_ASM16933v1_genomic.fna -o GCA_000169335.fa

anvi-script-reformat-fasta --simplify-names --prefix GCA_000235665 GCA_000235665.2_ASM23566v2_genomic.fna -o GCA_000235665.fa

anvi-script-reformat-fasta --simplify-names --prefix GCA_001039555 GCA_001039555.1_WH8502_v1_genomic.fna -o GCA_001039555.fa

anvi-script-reformat-fasta --simplify-names --prefix GCA_001039615 GCA_001039615.1_WH0401_v1_genomic.fna -o GCA_001039615.fa

anvi-script-reformat-fasta --simplify-names --prefix GCA_001039635 GCA_001039635.1_WH0402_v1_genomic.fna -o GCA_001039635.fa

anvi-script-reformat-fasta --simplify-names --prefix GCA_001050835 GCA_001050835.1_ASM105083v1_genomic.fna -o GCA_001050835.fa

anvi-script-reformat-fasta --simplify-names --prefix GCA_013215395 GCA_013215395.1_ASM1321539v1_genomic.fna -o GCA_013215395.fa

anvi-script-reformat-fasta --simplify-names --prefix GCA_000167195 GCA_000167195.1_ASM16719v1_genomic.fna -o GCA_000167195.fa

anvi-script-reformat-fasta --simplify-names --prefix ALALNI8 Bin.001.fasta_assembly.fa -o ALANI8_simple.fa

anvi-script-reformat-fasta --simplify-names --prefix SCOPE2022 GCA_022448125.1_ASM2244812v1_genomic.fna -o SCOPE2022_simple.fa

anvi-script-reformat-fasta --simplify-names --prefix BG0011 GCA_003013815.1_ASM301381v1_genomic.fna -o BG0011_simple.fa
```

```bash
# list .fna files to be used in next script

ls *.fna > samples_list.txt

sed 's/_simple.fa//' samples_list.txt > samples_list1.txt
```

# Generate contigs.db for each genome

```bash
#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64GB
#SBATCH --time=10:55:00
#SBATCH --partition=epyc-64

source /home1/csclevel/.bashrc
module load anaconda3
conda activate anvio-7.1

for samples in $(cat /scratch/csclevel/pangenome_cyanothece2/samples_list1.txt)

	do

		anvi-gen-contigs-database -f /scratch/csclevel/pangenome_cyanothece2/${samples}_simple.fa -o /scratch/csclevel/pangenome_cyanothece2/${samples}.db -T 16

	done
```

```bash
# annotate contigs.db files

for samples in $(cat /scratch/csclevel/pangenome_cyanothece2/samples_list1.txt)

	do

		anvi-run-hmms -c /scratch/csclevel/pangenome_cyanothece2/${samples}.db -T 16
		anvi-run-ncbi-cogs -c /scratch/csclevel/pangenome_cyanothece2/${samples}.db -T 16
		anvi-run-pfams -c /scratch/csclevel/pangenome_cyanothece2/${samples}.db -T 16
		anvi-run-kegg-kofams -c /scratch/csclevel/pangenome_cyanothece2/${samples}.db -T 16

	done
```

```bash
#create a path file called genomes_path.txt

nano genomes_path.txt

# file contents below

name    contigs_db_path
CCY0110 /project/eawebb_94/Catie/cyanothece/pangenome/CCY0110.db
cyanothece      /project/eawebb_94/Catie/cyanothece/pangenomecyanothece.db
subtropica      /project/eawebb_94/Catie/cyanothece/pangenome/subtropica.db
WH0003  /project/eawebb_94/Catie/cyanothece/pangenome/WH0003.db
WH0005  /project/eawebb_94/Catie/cyanothece/pangenome/WH0005.db
WH0401  /project/eawebb_94/Catie/cyanothece/pangenome/WH0401.db
WH0402  /project/eawebb_94/Catie/cyanothece/pangenome/WH0402.db
WH8501  /project/eawebb_94/Catie/cyanothece/pangenome/WH8501.db
WH8502  /project/eawebb_94/Catie/cyanothece/pangenome/WH8502.db
BG0011 /project/eawebb_94/Catie/cyanothece/pangenome/BG0011.db
```

```bash
# make a storage db 

anvi-gen-genomes-storage -e genomes_path.tsv -o storage-GENOMES.db
```

# Generate the Final Pangenome

```bash
#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64GB
#SBATCH --time=10:55:00
#SBATCH --partition=epyc-64

source /home1/csclevel/.bashrc
conda activate anvio-7.1

cd /project/eawebb_94/Catie/cyanothece/pangenome

anvi-pan-genome -g storage-GENOMES.db -n pan_db_directory -T 16
```

# Add FastANI Heatmap 

```bash
#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=47:55:00
#SBATCH --mem=64GB
#SBATCH --partition=epyc-64

source /home1/csclevel/.bashrc
conda activate anvio-7.1

anvi-compute-genome-similarity --external-genomes genomes_path.tsv \
                               --program fastANI \
                               --output-dir FastANI_042022 \
                               --num-threads 16 \
                               --pan-db pan_db_directory_042022/pan_db_directory_042022-PAN.db
```

```bash
# display pan on an HPC (can also be done locally)

anvi-display-pan -p /project/eawebb_94/Catie/cyanothece/pangenome/pan_db_directory_042022/pan_db_directory_042022-PAN.db -g /project/eawebb_94/Catie/cyanothece/pangenome/storage-GENOMES.db --server-only -P 8085
```