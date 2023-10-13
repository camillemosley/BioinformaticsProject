#!/bin/bash

# Define paths
MUSCLE_PATH=~/Private/Biocomputing/tools/muscle3.8.31_i86linux64
HMMBUILD_PATH=~/Private/Biocomputing/tools/hmmbuild
HMMSEARCH_PATH=~/Private/Biocomputing/tools/hmmsearch
REF_SEQ_PATH=~/Private/Biocomputing/BioinformaticsProject/ref_sequences
PROTEOMES_PATH=~/Private/Biocomputing/BioinformaticsProject/proteomes
PROJECT_PATH=~/Private/Biocomputing/BioinformaticsProject

# Combine all of the reference sequences for hsp70 and mcrA
cd $REF_SEQ_PATH
cat hsp70gene*.fasta > hsp70_combined.fasta
cat mcrAgene*.fasta > mcrA_combined.fasta

# Sequence alignment with muscle
$MUSCLE_PATH -in hsp70_combined.fasta -out hsp70_aligned.fasta
$MUSCLE_PATH -in mcrA_combined.fasta -out mcrA_aligned.fasta

# hmmbuild
$HMMBUILD_PATH hsp70.hmm hsp70_aligned.fasta
$HMMBUILD_PATH mcrA.hmm mcrA_aligned.fasta

# Move HMM files to PROTEOMES_PATH for easier access
mv hsp70.hmm $PROTEOMES_PATH
mv mcrA.hmm $PROTEOMES_PATH

# Create a CSV file to store the results
echo "Proteome, HSP70 Matches, McrA Matches" > $PROJECT_PATH/proteome_analysis_results.csv

# hmmsearch for each of the proteomes
cd $PROTEOMES_PATH
for proteome in proteome_*.fasta
do
    # Search for hsp70 matches
    $HMMSEARCH_PATH --tblout hsp70_results.txt hsp70.hmm $proteome
    hsp70_matches=$(grep -v "#" hsp70_results.txt | wc -l)

    # Search for mcrA matches
    $HMMSEARCH_PATH --tblout mcrA_results.txt mcrA.hmm $proteome
    mcrA_matches=$(grep -v "#" mcrA_results.txt | wc -l)

    # Append results to the CSV file
    echo "$proteome, $hsp70_matches, $mcrA_matches" >> $PROJECT_PATH/proteome_analysis_results.csv
done

# Clean up intermediate files
rm hsp70_results.txt mcrA_results.txt

