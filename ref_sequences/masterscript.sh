
for f in hsp70gene_*.fasta; do
cat "$f" >> "hsp70combined.fasta";

done

for f in mcrAgene_*.fasta; do
cat "$f" >> "mcrAgenecombined.fasta";

done


~/Private/Biocomputing/tools/muscle -align hsp70combined.fasta -output hsp70aligned.fasta
~/Private/Biocomputing/tools/hmmbuild hsp70.hmm hsp70aligned.fasta

for f in {1:50}; do

~/Private/Biocomputing/BioinformaticsProject/proteomes/proteome_01.fasta
~/Private/Biocomputing/tools/hmmsearch -tblout hsp70.output hsp70.hmm

done
