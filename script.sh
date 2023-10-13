# script for identifying methanogens from a proteome directory
# usage: bash script.sh workingdirectory

## 1) combining reference genes into one file
### workign path should be: /afs/crc.nd.edu/user/a/ahansris/Private/Biocomputing/BioinformaticsProject
cd $1/ref_sequences
cat mcrAgene_*.fasta >> mcrAref.fasta
cat hsp70gene_*.fasta >> hsp70ref.fasta

## 2) making a directory to place in the reference sequences
cd $1
mkdir refseq
mv $1/ref_sequences/mcrAref.fasta $1/refseq
mv $1/ref_sequences/hsp70ref.fasta $1/refseq

## 3) creating a directory to place the files that'll be generated to identify methanogens
mkdir workingfiles
cd workingfiles

## 4) aligning the proteome files to the reference sequences using muscle
/afs/crc.nd.edu/user/a/ahansris/Private/tools/muscle -align $1/refseq/mcrAref.fasta -output mcrA_aligned.fasta
/afs/crc.nd.edu/user/a/ahansris/Private/tools/muscle -align $1/refseq/hsp70ref.fasta -output hsp70_aligned.fasta

## 5) building an HMM profile via hmmbuild for the two genes
/afs/crc.nd.edu/user/a/ahansris/Private/Biocomputing/tools/hmmbuild mcrA.hmm mcrA_aligned.fasta
/afs/crc.nd.edu/user/a/ahansris/Private/Biocomputing/tools/hmmbuild hsp70.hmm hsp70_aligned.fasta

## 6) looping through each proteome file with hmmsearch to identify number of genes, and nesting in its respective directory
mkdir mcrAsearches
cd mcrAsearches
for file in $1/proteomes/*.fasta
do
	numb=$(echo $file | grep -Eo '[0-9]{2}')
	/afs/crc.nd.edu/user/a/ahansris/Private/Biocomputing/tools/hmmsearch --tblout "proteome"$numb"mcrA.txt" $1/workingfiles/mcrA.hmm $file
done

cd $1/workingfiles
mkdir hsp70searches
cd hsp70searches
for file in $1/proteomes/*.fasta;
do
	numb=$(echo $file | grep -Eo '[0-9]{2}')
	/afs/crc.nd.edu/user/a/ahansris/Private/Biocomputing/tools/hmmsearch --tblout "proteome"$numb"hsp70.txt" $1/workingfiles/hsp70.hmm $file
done

cd $1

## 7) creating a summary file in the order: proteome # | mcrA gene counts | hsp70 gene counts
for file in $1/proteomes/*.fasta;
do
	numb=$(echo $file | grep -Eo '[0-9]{2}')
	mcrAcounts=$(grep -vc "#" "$1/workingfiles/mcrAsearches/proteome"$numb"mcrA.txt")
	hsp70counts=$(grep -vc "#" "$1/workingfiles/hsp70searches/proteome"$numb"hsp70.txt")
	echo "proteome_"$numb","$mcrAcounts","$hsp70counts >> summary.csv
done

## 8) creating a file of potential methanogens
cat summary.csv | grep -wv "0" | sort -t, -k3,3nr -k1,1n >> methanogens.csv

## 9) adding headers to summary.csv and methanogens.csv
sed -i -e '1i"Proteome #","# of mcrA genes","# of hsp70 genes"' summary.csv
sed -i -e '1i"Proteome #","# of mcrA genes","# of hsp70 genes"' methanogens.csv
