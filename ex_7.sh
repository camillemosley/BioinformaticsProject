// Authors: Kate Jackowski and James Magas
// Date: 10/13/2023
// Exercise 7 bash code for mcrA + hsp70 genes
// Use instance format for bash code will be bash ex_7.sh ref_sequences

// This code will produce a 50x3 table listing proteomes with their relative instances of the mcrA gene and HSP70 gene
// The code will also create a .txt file that lists what proteomes may be of most interest to study based on their having both the mcrA and HSP70 genes

// The first step in this code is to combine reference sequences for a gene (in this case we are combining reference sequences for mcrA and reference sequences for HSP70)
// This will allow us to make a search image that isn’t one species but mcrA and HSP70 genes in general
// We will be inside of the ref_sequences directory when we run this code
// Absolute path to my ref_sequences directory is:
// ~/Private/Biocomputing/exercise_seven_magas/exercise_7/ref_sequences

// The code for creating seq files for both mcrA and HSP70 is:

cat hsp70gene_*.fasta >> hsp70seq.fasta
cat mcrAgene_*.fasta >> mcrAseq.fasta


// Next we have the tool “muscle” align each reference sequence file

~/Private/tools/muscle -align hsp70seq.fasta -output hsp70aligned.fasta
~/Private/tools/muscle -align mcrAseq.fasta -output mcrAaligned.fasta


// Now we build hmm using the hmmbuild tool
// hmmbuild utilizes the aligned.fasta file created by muscle
// We will still be inside of the ref_sequences directory when we run this code

~/Private/tools/hmmbuild hsp70seq.hmm hsp70aligned.fasta
~/Private/tools/hmmbuild mcrAseq.hmm mcrAaligned.fasta


// Now we will use hmmsearch with the hmm files that have been created and use them to search through all of the respective proteome files
// Both hmm files should be in the ref_sequences directory
// In order to search each proteome with the respective hmm we will need to navigate to the folder with the proteomes we want to search
// We will create a for loop to search through each proteome - once with the mcrAseq hmm and next with the hsp70 hmm
// This will produce a 3x50 table listing the name of the proteome in the first column
// In the second column the number of respective HSP70 genes (acknowledging that this should list the mcrA genes per instructions but crc was not functioning properly and taking an extremely long time to process)
// In the third column the number of respective mcrA genes for the proteome will be listed (also acknowledging that this should be flipped with the HSP70 genes) // This list of proteomes and genes will print to a file called totalcount.txt
// We will then print the names of proteomes that have both the mcrA and HSP70 gene to a document called finalrecs.txt

for file in ../proteomes/*.fasta
do ~/Private/tools/hmmsearch --tblout $file.output hsp70seq.hmm $file
hsp70count=$(cat $file.output | grep -v '#' | wc -l)
~/Private/tools/hmmsearch --tblout $file.output mcrAseq.hmm $file
mcrAcount=$(cat $file.output | grep -v '#' | wc -l)
echo $file $hsp70count $mcrAcount >> totalcount.txt
cat totalcount.txt | grep -v " 0" | cut -d " " -f1 | cut -d "/" -f3 | cut -d . -f1 > finalrecs.txt
done
