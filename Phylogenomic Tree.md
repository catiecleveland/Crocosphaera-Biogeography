# Crocosphaera Phylogenomic Tree

## create initial tree with GToTree

```bash
#Install GToTree with conda before this analysis

conda activate gtotree
# download GenBank file to be used as the root
# list this file's name in the following file:
ls *.gbff >> genbank_files.txt

#Download accession list for all assemblies in family "Aphanothecacea" and genus "Cyanothece" from NCBI. Use "accessions.tsv" file below

#list all novel .fasta or .fa files in one document
ls *.fasta >> fasta_files.txt

GToTree -a accessions.tsv -g genbank_files.txt -f fasta_files.txt -H Cyanobacteria -t -L Species,Strain -j 4 -o Cyanothece_tree_031522
```

## create final consensus tree with IQTree2 and ModelFinder

```bash
#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=120GB
#SBATCH --partition=largemem
#SBATCH --time=47:55:00

source /home1/csclevel/.bashrc
conda activate gtotree

iqtree -s /project/eawebb_94/Catie/cyanothece/gtotree/Cyanothece_tree_031522/Aligned_SCGs_mod_names.faa \
-spp /project/eawebb_94/Catie/cyanothece/gtotree/Cyanothece_tree_031522/run_files/Partitions.txt \
-m MFP -bb 1000 -nt 16 -pre iqtree_031522_out
```