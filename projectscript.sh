#!/bin/bash

# Combine all of the reference sequences for hsp70 into a single file called hsp70_combined.fasta

cd BioinformaticsProject/ref_sequences
cat hsp70gene*.fasta > hsp70_combined.fasta

# Combine all of the reference sequences for mcrA into a single file called mcrA_combined.fasta

cat mcrAgene*.fasta > mcrA_combined.fasta

# Sequence alignment with muscle for hsp70_combined.fasta

tools/muscle3.8.31_i86linux64 -in hsp70_combined.fasta -out hsp70_aligned.fasta

# Sequence alignment with muscle for mcrA_combined.fasta

tools/muscle3.8.31_i86linux64 -in mcrA_combined.fasta -out mcrA_aligned.fasta

# hmmbuild for hsp70_aligned.fasta

tools/hmmbuild hsp70.hmm hsp70_aligned.fasta

# hmmbuild for mcrA_aligned.fasta

tools/hmmbuild mcrA.hmm mcrA_aligned.fasta

# Create a CSV file to store the results

echo "Proteome, HSP70 Matches, McrA Matches" > BioinformaticsProject/proteomes/proteome_analysis_results.csv

# hmmsearch for each of the proteomes

cd BioinformaticsProject/proteomes
for proteome in proteome_*.fasta
do
    # Search for hsp70 matches
    tools/hmmsearch --tblout hsp70_results.txt hsp70.hmm $proteome
    hsp70_matches=$(grep -v "#" hsp70_results.txt | wc -l)

    # Search for mcrA matches
    tools/hmmsearch --tblout mcrA_results.txt mcrA.hmm $proteome
    mcrA_matches=$(grep -v "#" mcrA_results.txt | wc -l)

    # Append results to the CSV file
    echo "$proteome, $hsp70_matches, $mcrA_matches" >> BioinformaticsProject/proteomes/proteome_analysis_results.csv
done

# Clean up intermediate files

rm hsp70_results.txt mcrA_results.txt
