#!/bin/bash

#usage bash code.sh $1 $2 $3 $4
#$1: the directory of the ref_sequences
#$2: the directory of the tools
#$3: the directory of the proteomes
#$4: the output data name file

touch all_hsp70.fasta
touch all_mcrA.fasta
touch $4
echo "Proteomes hsp70 mcrA" >> $4


#grab all the hsp70 gene file, and put it into a single fasta file
for hsp in $1/hsp70gene_*.fasta;
do
	cat $hsp >> all_hsp70.fasta
done

#grab all the mcrA gene file, and put it into a single fasta file
for mcr in $1/mcrAgene_*.fasta;
do 
	cat $mcr >> all_mcrA.fasta
done

#align all the hsp70gene using muscle
$2/muscle -align all_hsp70.fasta -output hsp70aligned.fasta
$2/muscle -align all_mcrA.fasta -output mcrAaligned.fasta

#After having the multiple sequence alignment, use hmmbuild to generate a profile HMM from the MSA Build hmm file 
$2/hmmbuild hsp70.hmm hsp70aligned.fasta
$2/hmmbuild mcrA.hmm mcrAaligned.fasta
i=1

#Searching the proteome using the HMM profile, loop through all the proteome files
for pro in $3/proteome_*.fasta;
do
	touch hsp.txt
	touch mcr.txt
	$2/hmmsearch --tblout hsp.txt hsp70.hmm $pro
	$2/hmmsearch --tblout mcr.txt mcrA.hmm $pro
	#Number of hsp70gene aligned
	alignedhsp=$(grep -v "^#" hsp.txt | wc -l)
	#Number of mcrAgene aligned
	alignedmcr=$(grep -v "^#" mcr.txt | wc -l)
	#making a txt file comtaining all the data
	echo -n "proteome"$i" " >> $4
	echo -n $alignedhsp" "  >> $4
	echo $alignedmcr >> $4
	i=$((i+1))
done

touch selected.txt
echo "Proteomes hsp70 mcrA" >> selected.txt
cat $4 | sort -k2,2n |tail -n 8 >> selected.txt
cat $4
echo "These are the proteomes that might be interesting"
cat selected.txt
