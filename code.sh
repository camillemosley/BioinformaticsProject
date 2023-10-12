# path to working directory (BioinformaticsProject)

# WD_PATH=/afs/crc.nd.edu/user/m/mzarodn2/Private/Biocomputing/BioinformaticsProject
WD_PATH=$1

# Concatenating all reference sequences into one fasta file
cd ${WD_PATH}/ref_sequences

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
/afs/crc.nd.edu/user/m/mzarodn2/Private/Biocomputing/tools/hmmbuild ./hmmer_out/mcrAgene.hmm ./ref_sequences/mcrAgene_aligned.fasta
/afs/crc.nd.edu/user/m/mzarodn2/Private/Biocomputing/tools/hmmbuild ./hmmer_out/hsp70gene.hmm ./ref_sequences/hsp70gene_aligned.fasta

# Hmmsearch
mkdir hmmsearch_out
for i in "./proteomes/proteome_"*".fasta"
do
	proteome_no=$(echo $i | cut -f3 -d/ | cut -f1 -d. | cut -f2 -d_)
	/afs/crc.nd.edu/user/m/mzarodn2/Private/Biocomputing/tools/hmmsearch --tblout "./hmmsearch_out/mcrAgene_hmmsearch_${proteome_no}.txt" ./hmmbuild_out/mcrAgene.hmm "$i"
done


for i in "./proteomes/proteome_"*".fasta"
do
	proteome_no=$(echo $i | cut -f3 -d/ | cut -f1 -d. | cut -f2 -d_)
	/afs/crc.nd.edu/user/m/mzarodn2/Private/Biocomputing/tools/hmmsearch --tblout "./hmmsearch_out/hsp70gene_hmmsearch_${proteome_no}.txt" ./hmmbuild_out/hsp70gene.hmm "$i"
done


for i in "./proteomes/proteome_"*".fasta"
do
	proteome_no=$(echo $i | cut -f3 -d/ | cut -f1 -d. | cut -f2 -d_)
	prefix=$(echo $i | cut -f3 -d/ | cut -f1 -d.)
	hsp70_count=$(grep -vc "^#" "./hmmsearch_out/hsp70gene_hmmsearch_${proteome_no}.txt")
	mcrA_count=$(grep -vc "^#" "./hmmsearch_out/mcrAgene_hmmsearch_${proteome_no}.txt")
	echo -e $prefix"\t"$mcrA_count"\t"$hsp70_count >> hits_table.txt
done

grep -wv 0 hits_table.txt | sort -rnk3 > candidate_methanogens.txt
