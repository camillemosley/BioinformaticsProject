#usage: search hsp70 and put in file


mkdir hsp70results
for i in {1..9}
do
	mv hsp70proteome_$i.output hsp70results/
done

for i in {10..50}
do
	mv hsp70proteome_$i.output hsp70results/
done 
