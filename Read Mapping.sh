#### I followed this same workflow with the TaraOceans, GEOTRACES, GoShip, ALOHA deep trap, and ALOHA Net Trap metagenomes that I used (see manuscript for references and more details). 

#### references:
#### BioGEOTRACES: DOI:10.1038/sdata.2018.176
#### GO-SHIP: https://doi.org/10.1038/s41597-021-00889-9
#### ALOHA Net trap and 4,000 m trap: DeLong Lab, PRJNA358725, PRJNA482655
#### TaraOceans: PRJEB4352, PRJEB1787

```bash
# list the fastq file names in one document

ls *_1.fastq.gz > scope.txt
sed 's/_1.fastq.gz//' scope.txt > scope1.txt
```

## Creating a contigs database with my 5 reference genomes:

```bash
# concatenate all genomes into one fasta file "Croco5". Check headers using grep.

cat subtropica_simple.fa > croco5.fa
cat BG0011_simple.fa >> croco5.fa
cat CCY0110_simple.fa >> croco5.fa
cat Alani8_simple.fa >> croco5.fa
cat WH0003_simple.fa >> croco5.fa

nano croco5.fa

grep ">" croco5.fa

# Interactive Session

salloc --ntasks=1 --cpus-per-task=16 --time=00:55:00 --mem=64GB --partition=epyc-64

# install anvio-7.1 prior to analysis

conda activate anvio-7.1

# generate and annotate contigs db on interactive session

anvi-gen-contigs-database -f croco5.fa -o croco5.db -T 16
anvi-run-hmms -c croco5.db -T 16
anvi-run-ncbi-cogs -c croco5.db -T 16

# generate a Bowtie2 mapping db

bowtie2-build croco5.fa croco5 --threads 16

# inspect headers

bowtie2-inspect -n croco5
```

## Complete Bowtie2 read-mapping with default parameters

```bash
#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=47:55:00
#SBATCH --mem=64GB
#SBATCH --partition=epyc-64

source /home1/csclevel/.bashrc
module load anaconda3
conda activate bowtie2

for samples in $(cat /scratch1/csclevel/dark/dark.txt)

	do

		echo "____________________"
		echo "On sample: ${samples}"
			
		bowtie2 -x /scratch1/csclevel/dark/nifh -1 /scratch1/csclevel/dark/${samples}_1.fastq.gz -2 /scratch1/csclevel/scope_reads_2020/${samples}_2.fastq.gz --no-unal -S /scratch1/csclevel/scope_reads_2020/sams/${samples}.sam

	done
```

```bash
# load samtools module 

module load gcc/8.3.0 
module load intel/18.0.4
module load samtools/1.10

for samples in $(cat /scratch1/csclevel/scope_reads_2020/scope1.txt)

	do 

		echo "________________________" 
		echo "On sample: ${samples}"
 
		samtools view -bS /scratch1/csclevel/scope_reads_2020/sams/${samples}.sam > /scratch1/csclevel/scope_reads_2020/bams2/${samples}-RAW.bam 

		samtools sort --threads 16 /scratch1/csclevel/scope_reads_2020/bams2/${samples}-RAW.bam -o /scratch1/csclevel/scope_reads_2020/bams2/${samples}.bam 

	done
```

```bash
# filter with CoverM

mkdir rawbams
mv *-RAW.bam rawbams

# Ran on an interactive session

conda activate coverm1

for samples in $(cat /scratch1/csclevel/scope_reads_2020/scope1.txt)

	do

		echo "______________________"
		echo "On sample: ${samples}"

		coverm filter -b /scratch1/csclevel/scope_reads_2020/bams2/${samples}.bam -o /scratch1/csclevel/scope_reads_2020/coverm2/${samples}.bam --min-read-percent-identity 0.98

	done
```

```bash
# index files with samtools

for samples in $(cat /scratch1/csclevel/scope_reads_2020/scope1.txt)

	do

		echo "______________________"
		echo "On sample: ${samples}"
		
		samtools index /scratch1/csclevel/scope_reads_2020/coverm2/${samples}.bam

	done
```

## Anvi'o Profiling 

```bash
#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=17:55:00
#SBATCH --mem=120GB
#SBATCH --partition=largemem

source /home1/csclevel/.bashrc
conda activate anvio-7.1

for samples in $(cat /scratch1/csclevel/scope_reads_2020/scope1.txt)

	do

		echo "______________________"
		echo "On sample: ${samples}"
		anvi-profile --min-contig-length 1000 -i  /scratch1/csclevel/scope_reads_2020/coverm2/${samples}.bam -c  /scratch1/csclevel/scope_reads_2020/croco5.db

	done
```

```bash
# Merging profile.db files

salloc --ntasks=1 --cpus-per-task=16 --time=00:55:00 --mem=64GB --partition=epyc-64

anvi-merge */PROFILE.db -o scope_merge -c /scratch1/csclevel/scope_reads_2020/croco5.db
```

```bash
# Visualization

anvi-script-add-default-collection -c /scratch1/csclevel/scope_reads_2020/croco5.db -p PROFILE.db -C rm_croco

anvi-export-collection -p PROFILE.db -C rm_croco

# open collection file in Excel and bin splits by hand

anvi-import-collection -c /scratch1/csclevel/scope_reads_2020/croco5.db -p PROFILE.db -C bins collection-rm_croco.txt

# run anvi-interactive on hpc

anvi-interactive -c /scratch1/csclevel/scope_reads_2020/croco5.db -p PROFILE.db --server-only -P 8084
```
