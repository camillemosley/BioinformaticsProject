#Usage:

#for following script make sure the reference sequences are sperated into different directories 

	#puts all the references for mcrAgene in one filemcrAgene
cat *.fasta >> AllmcrAgene.fasta

	 #puts all the references for mcrAgene in one filemcrAgene
cat *.fasta >> Allhsp70gene.fasta


#following script aligns the combined files 

	#for mcrA
~/Private/Biocomputing/Tools/Muscle -align AllmcrAgene.fasta  -output alignment_mcrAgenes.fasta

	#for hsp70
~/Private/Biocomputing/Tools/Muscle -align Allhsp70gene.fasta  -output alignment_hsp70genei.fasta


#using the alignment created by muscle an hmm profile will be made using hmm build for both gene references 

	#for mcrA
~/Private/Biocomputing/Tools/hmmbuild BuildForhsp70.fasta alignment_mcrAgenes.fasta

 	#for hsp70
~/Private/Biocomputing/Tools/hmmbuild BuildFormcrA.fasta alignment_hsp70genei.fasta

#Using the hmm profile we will search the proteomes individually using hmm search and a for loop

for i in {01..50}
do
~/Private/Biocomputing/Tools/hmmsearch --tblout SearchOut_hsp70_$i.fasta BuildForhsp70.fasta proteome_$i.fasta
~/Private/Biocomputing/Tools/hmmsearch --tblout SearchOut_mcrA_$i.fasta BuildFormcrA.fasta proteome_$i.fasta
done

#searching for Matches

for i in {01..50}
do 
	echo "proteome $i">> matches.csv
	cat SearchOut_hsp70_$i.fasta | grep -v [#] | wc -l >> matches.csv
done


for i in {01..50}
do 
   	echo "proteome $i">> matches_mcrA.csv
        cat SearchOut_hsp70_$i.fasta | grep -v [#] | wc -l >> matches_mcrA.csv
done


for i in {01..50}
do
~/Private/Biocomputing/Tools/hmmsearch --tblout SearchOut_mcrA_$i.fasta BuildFormcrA.fasta proteome_$i.fasta
done



for i in {01..50}
do 
        echo "proteome $i" |  cat SearchOut_mcrA_$i.fasta | grep -v [#] | wc -l >> matches_mcrA.csv
done
