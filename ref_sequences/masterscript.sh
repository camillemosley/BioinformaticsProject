
for f in hsp70gene_*.fasta; do
cat "$f"|tail -n +2 >> "hsp70combined.fasta";

done

for f in mcrAgene_*.fasta; do
cat "$f"|tail -n +2 >> "mcrAgenecombined.fasta";

done
