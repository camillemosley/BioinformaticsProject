#usage: this shell script will show the number of matches of certain genes to proteome sequences
#to run: bash script.sh


#combining all hsp and mcra files together
cd Private/BioinformaticsProject/ref_sequences
cat hsp70gene*.fasta > hsp70combo.fasta
cat mcrAgene*.fasta > mcrAcombo.fasta

#aligning these files
~/Private/Biocomputing/tools/muscle -align hsp70combo.fasta -output hsp70aligned.fasta
~/Private/Biocomputing/tools/muscle -align mcrAcombo.fasta -output mcrAaligned.fasta

#building these files
~/Private/Biocomputing/tools/hmmbuild hsp70.hmm hsp70aligned.fasta
~/Private/Biocomputing/tools/hmmbuild mcrA.hmm mcrAaligned.fasta

#moving files to proteomes directory
mv hsp70.hmm ~/Private/BioinformaticsProject/proteomes
mv mcrA.hmm ~/Private/BioinformaticsProject/proteomes

#adding headers to csv file for later
cd ..
echo "Name_of_proteome, Hsp_Number, Mcra_Number" > sequences.csv
cd proteomes

#moving files out of proteomes
mv mcrAcombo.fasta ~/Private/BioinformaticsProject
mv hsp70combo.fasta ~/Private/BioinformaticsProject

#searching through the hmm build files, grabbing matches, and inputting the files and number of matches for hsp and mcra into the previously created csv file
for file in *.fasta
do
~/Private/Biocomputing/tools/hmmsearch --tblout hsp70output.hmm hsp70.hmm $file
~/Private/Biocomputing/tools/hmmsearch --tblout mcraoutput.hmm mcrA.hmm $file
gene=$(cat hsp70output.hmm | grep -E -c "^[^#]")
genetic_code=$(cat mcraoutput.hmm | grep -E -c "^[^#]")
echo "$file, $gene, $genetic_code" >> ~/Private/BioinformaticsProject/sequences.csv
done


cd ../

cat sequences.csv

