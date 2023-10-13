###		Example usage: bash script.sh /afs/crc.nd.edu/user/m/mzarodn2/Private/Biocomputing/BioinformaticsProject ref_sequences proteomes

### 	Arguments
#		WD_PATH – path to working directory
#		REFSEQ_DIRNAME – directory containing reference sequences; must be a subdirectory in WD_PATH
#		PROTEOME_DIRNAME – directory containing proteome sequences; must be a subdirectory in WD_PATH

WD_PATH=$1
REFSEQ_DIRNAME=$2
PROTEOME_DIRNAME=$3

# Concatenating all reference sequences into one fasta file
cd ${WD_PATH}/${REFSEQ_DIRNAME}
cat mcrAgene_*.fasta > mcrAgene.fasta
cat hsp70gene_*.fasta > hsp70gene.fasta

# Muscle
/afs/crc.nd.edu/user/m/mzarodn2/Private/Biocomputing/tools/muscle/muscle3.8.31_i86linux64 \
		-in mcrAgene.fasta \
		-out mcrAgene_aligned.fasta

/afs/crc.nd.edu/user/m/mzarodn2/Private/Biocomputing/tools/muscle/muscle3.8.31_i86linux64  \
		-in hsp70gene.fasta \
		-out hsp70gene_aligned.fasta

cd ../

# Hmmbuild
mkdir hmmbuild_out
/afs/crc.nd.edu/user/m/mzarodn2/Private/Biocomputing/tools/hmmbuild ./hmmer_out/mcrAgene.hmm ./${REFSEQ_DIRNAME}/mcrAgene_aligned.fasta
/afs/crc.nd.edu/user/m/mzarodn2/Private/Biocomputing/tools/hmmbuild ./hmmer_out/hsp70gene.hmm ./${REFSEQ_DIRNAME}/hsp70gene_aligned.fasta

# Hmmsearch
mkdir hmmsearch_out
echo "proteome,mcrA_count,hsp70_count" > hits_table.txt

for i in "./${PROTEOME_DIRNAME}/proteome_"*".fasta"
do
	proteome_no=$(echo $i | cut -f3 -d/ | cut -f1 -d. | cut -f2 -d_)
	prefix=$(echo $i | cut -f3 -d/ | cut -f1 -d.)

	/afs/crc.nd.edu/user/m/mzarodn2/Private/Biocomputing/tools/hmmsearch --tblout "./hmmsearch_out/mcrAgene_hmmsearch_${proteome_no}.txt" ./hmmbuild_out/mcrAgene.hmm "$i"
	/afs/crc.nd.edu/user/m/mzarodn2/Private/Biocomputing/tools/hmmsearch --tblout "./hmmsearch_out/hsp70gene_hmmsearch_${proteome_no}.txt" ./hmmbuild_out/hsp70gene.hmm "$i"

	hsp70_count=$(grep -vc "^#" "./hmmsearch_out/hsp70gene_hmmsearch_${proteome_no}.txt")
	mcrA_count=$(grep -vc "^#" "./hmmsearch_out/mcrAgene_hmmsearch_${proteome_no}.txt")
	echo $prefix","$mcrA_count","$hsp70_count >> hits_table.txt
done

echo "proteome,mcrA_count,hsp70_count" > hits_table.txt
cat hits_table.txt | tail -n+2 | grep -wv 0 | sort -rnk3 > candidate_methanogens.txt