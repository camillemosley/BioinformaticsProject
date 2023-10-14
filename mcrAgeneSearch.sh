# usage: 

#mkdir mcrAgeneResults

for i in {1..9}
do
	./hmmsearch --tblout mcrAgeneProteome_$i.output mcrAgene.hmm ./proteomes/proteome_0$i.fasta
	mv mcrAgeneProteome_$i.ouput mcrAgeneResults/ 
done

for i in {10..50}
do
	 ./hmmsearch --tblout mcrAgeneProteome_$i.output mcrAgene.hmm ./proteomes/proteome_$i.fasta
	 mv mcrAgeneProteome_$i.output mcrAgeneResults/ 
done
