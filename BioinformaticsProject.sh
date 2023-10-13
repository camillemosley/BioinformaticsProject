# usage : bash BioinformaticsProject.sh

#concatenates mcrA reference sequences into one file
cat ref_sequences/mcrA*.fasta >> mcrA_seqs.fasta

#concatenates hsp70 reference sequences into one file
cat ref_sequences/hsp70*.fasta >> hsp70_seqs.fasta

#align reference sequences in muscle
#uses relative path assuming that the tools directory is one directory above current location, and that muscle is contained in tools
../muscle -align mcrA_seqs.fasta -output mcrA_aligned.fasta
../muscle -align hsp70_seqs.fasta -output hsp70_aligned.fasta

#build hmm from alignement using hmmbuild
../hmmbuild mcrA_build.hmm mcrA_aligned.fasta
../hmmbuild hsp70_build.hmm hsp70_aligned.fasta

#make directory to store the search output for mcrA
#iterate over all the proteomes, search for the mcrA gene, and store in mcrA_output directory
mkdir mcrA_output

for file in proteomes/*.fasta
do
  	file_basename=$(basename "$file" .fasta)
        output_file=mcrA_output/"$file_basename".output
        ../hmmsearch --tblout $output_file mcrA_build.hmm $file
done

#make directory to store the search output for hsp70
#iterate over all the proteomes, search for the hsp70 gene, and store in hsp70_output directory
mkdir hsp70_output

for file in proteomes/*.fasta
do
  	file_basename=$(basename "$file" .fasta)
        output_file=hsp70_output/"$file_basename".output
	../hmmsearch --tblout $output_file hsp70_build.hmm $file
done

#store proteome name, number of mcrA genes, and number of hsp70 genes in table
echo "name, mcrA, hsp70" > results_table.csv
for file in proteomes/*.fasta
do
	proteome_name=$(basename "$file" .fasta)

	#check if proteome had an mcrA match
	mcrA_count=$(cat mcrA_output/${proteome_name}.output | grep -v "^#" | wc -l)

	#check if proteome also had an hsp70 match
	hsp70_count=$(cat hsp70_output/${proteome_name}.output | grep -v "^#" | wc -l)

	#store information in table
	echo "$proteome_name, $mcrA_count, $hsp70_count" >> results_table.csv
done
