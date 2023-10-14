#usage: alignedhsp70 search
for i in {1..9} 
do
	./hmmsearch --tblout hsp70proteome_$i.output hsp70.hmm ./proteomes/proteome_0$i.fasta
done

for i in {10..50}
do
	./hmmsearch --tblout hsp70proteome_$i.output hsp70.hmm ./proteomes/proteome_$i.fasta
done

