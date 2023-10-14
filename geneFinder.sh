# Shell script: 'geneFinder.sh'

# This shell script returns a 50x3 table of the proteomes with the number of their respective hsp70 genes and mcrA genes. 
# This works by building a hmm based on reference sequences of the genes of interest, and using this hmm to search for the genes in the studied proteomes. 
# Then, from on this list, the shell script returns the top 10 hits, based on which proteomes have the mcrA gene, and then of these, which have the most hsp70 genes. 
# This shell script takes no arguments. The 50x3 table and list of top hits can be found in the created directory 'results' found in the pwd from which the shell script was called. 
# All intermediate files are stored in the 'processing' directory.

# Important note: the user should begin in a pwd at which the 'tools', 'ref_sequences', and 'proteomes' directories are all children.




# Usage: bash geneFinder.sh




# sets up directories to be used in shell script
mkdir processing
mkdir results


# puts all reference sequences for a gene into singular file so that these sequences can be aligned
for datafile in ref_sequences/hsp70gene_??.fasta; do cat $datafile >> processing/hsp70gene_refseqs.fasta; done
for datafile in ref_sequences/mcrAgene_??.fasta; do cat $datafile >> processing/mcrAgene_refseqs.fasta; done


# aligns reference sequences of the genes of interest for preparation of hmm buildout
# must have 'muscle' tool downloaded for this step
../tools/muscle -align processing/hsp70gene_refseqs.fasta -output processing/hsp70gene_aligned.fasta
../tools/muscle -align processing/mcrAgene_refseqs.fasta -output processing/mcrAgene_aligned.fasta


# builds an hmm for each gene of interest based on the aligned reference sequences
# must have 'hmmbuild' tool downloaded for this step
../tools/hmmbuild processing/hsp70gene_hmm.fasta processing/hsp70gene_aligned.fasta
../tools/hmmbuild processing/mcrAgene_hmm.fasta processing/mcrAgene_aligned.fasta


# performs a search of the 50 proteome genomes based on the gene of interest's hmm
# must have 'hmmsearch' tool downloaded for this step
for Number in {01..50}; do ../tools/hmmsearch --tblout processing/hsp70gene_proteome$Number.tbl processing/hsp70gene_hmm.fasta proteomes/proteome_$Number.fasta; done;
for Number in {01..50}; do ../tools/hmmsearch --tblout processing/mcrAgene_proteome$Number.tbl processing/mcrAgene_hmm.fasta proteomes/proteome_$Number.fasta; done;


# creates 50x3 table of proteomes and their respective number of hsp70 genes and mcrA genes
# tbl.csv is stored in the 'results' directory
echo proteomes,hsp70gene,mcrAgene > results/tbl.csv
for Number in {01..50}; do echo -n proteomes/proteome_$Number.fasta >> results/tbl.csv; echo -n , >> results/tbl.csv; echo -n $(grep -v -c "#" processing/hsp70gene_proteome$Number.tbl) >> results/tbl.csv; echo -n , >> results/tbl.c$


# creates a 10x3 table of top 10 proteomes that have the mcrA gene and have the most hsp70 genes
# top10proteomes.csv is stored in the 'results' directory
echo proteomes,hsp70gene,mcrAgene > results/top10proteomes.csv
cat results/tbl.csv| grep -v 0$ | sort -t ',' -k 2,2nr | head -n 10 >> results/top10proteomes.csv

