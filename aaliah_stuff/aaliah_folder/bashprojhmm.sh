for i in {1..9}
do
	hmmsearch --tblout proteome_0$i.output refseq.hmm ./proteomes/proteomes_0$i.fasta
done

for i in {10..50}
do
	hmmsearch --tblout proteome_$i.output refseq.hmm ./proteomes/proteome_$i.fasta 
done

