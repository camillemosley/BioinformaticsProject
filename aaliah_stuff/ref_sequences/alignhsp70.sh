#usage combining all the hsp70genes

for i in {1..9}
do
	cat hsp70gene_0$i.fasta >> hsp70gene_comb.fasta
done

for i in {10..22}
do
	cat hsp70gene_$i.fasta >> hsp70gene_comb.fasta
done


