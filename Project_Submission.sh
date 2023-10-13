#Combine reference sequences for a gene into one file
#cat *.fasta >> AllmcrAgene.fasta
#cat *.fasta >> Allhsp70gene.fasta

#Combined file goes into Muscle to align
#This will be done for mcrA and hsp70

~/Private/Biocomputing/Tools/Muscle -align Allhsp70gene.fasta  -output alignment_hsp70gene.fasta
~/Private/Biocomputing/Tools/Muscle -align AllmcrAgene.fasta  -output alignment_mcrAgenes.fasta

#Build hmm using hmm build from alignment
#This will be done for mcrA and hsp70

~/Private/Biocomputing/Tools/hmmbuild BuildFor_hsp70.fasta alignment_hsp70gene.fasta
~/Private/Biocomputing/Tools/hmmbuild BuildFor_mcrA.fasta alignment_mcrAgenes.fasta

#Use hmm search with hmmProfile we created and proteome sequences

for i in {01..50}
do
~/Private/Biocomputing/Tools/hmmsearch --tblout SearchOut_hsp70_$i.fasta BuildFor_hsp70.fasta proteome_$i.fasta
~/Private/Biocomputing/Tools/hmmsearch --tblout SearchOut_mcrA_$i.fasta BuildFor_mcrA.fasta proteome_$i.fasta
done


#Use grep to find matches

for i in {01..50}
do
        echo "proteome $i">> test.csv
        cat SearchOut_mcrA_$i.fasta | grep -v "[#]" | wc -l >> test.csv
        cat SearchOut_hsp70_$i.fasta | grep -v "[#]" | wc -l >> test.csv
done

#Summary table
	#headers
echo "Proteome# mcrA hsp70" >> Table.csv

paste -s -d ' \t\n' test.csv >> Table.csv

cat Table.csv | column -t

# New table with only pH resitant methanogenic matches 

sort -n -k 2,2 Table.csv | tail -n 17 >> New_Table.csv
