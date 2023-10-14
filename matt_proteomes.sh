#!/bin/bash 

hmmsearch='/afs/crc.nd.edu/user/m/meleazar/Private/Biocomputing/tools/hmmsearch'
proteomes='/afs/crc.nd.edu/user/m/meleazar/Private/Biocomputing/BioinformaticsProject/proteomes'

for i in {1..9}; do
    $hmmsearch --tblout genome.output refseq.hmm "$proteomes"/proteome_0$i.fast 
done


for i in {10..50}; do
    $hmmsearch --tblout genome.output refseq.hmm "$proteomes"/proteome_$i.fasta
done
# 4 matches in proteome_05
# how many matches per gene per file >> new file
