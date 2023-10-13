#The Code for Daniel Gatewood, Mark Jantz, and Mae Czerwiec for the Bash Bioinformatics Project

#Usage: ls proteomes | bash projectcode.sh "hsp" "mcrA"
#Usage cont: the assumption is made that the individual gene sequences to be references are in a subdirectory titled ref_sequences and the proteome files to be references are in a subdirectory of the current working directory titled proteomes
#Usage cont: it is also assumed that the muscle and hmm files are in a sister directory to the current working directory titled tools

#This command makes a variable that lists all the protomes which need to be searched
list=$(cat)

#this for loop takes all the sequences of both genes of interest and prepares one fasta file containing them all, forwarding it to muscle for alignment, and then forwarding that to hmmbuild to create the hmm
for GeneAlign in $@
do
cat ref_sequences/$GeneAlign*.fasta > $GeneAlign.refseqs.fasta
../tools/muscle -align $GeneAlign.refseqs.fasta -output $GeneAlign.aligned.fasta
../tools/bin/hmmbuild $GeneAlign.hmm $GeneAlign.aligned.fasta
done

#the following is a for loop which performs hmmsearch for each proteome in the standard-in and outputs the number of hsp and mcrA genes in each proteome and inputs those values into a csv file../tools/bin/hmmsearch --tblout $1.output $1.hmm proteomes/$prot
echo "proteome,num of hsp,num of mcrA" >> finalgenecount.csv
for prot in $list
do
../tools/bin/hmmsearch --tblout $1.output $1.hmm proteomes/$prot
num1=$(cat $1.output | grep -v -E "^#" | wc -l)
../tools/bin/hmmsearch --tblout $2.output $2.hmm proteomes/$prot
num2=$(cat $2.output | grep -v -E "^#" | wc -l)
echo "$prot,$num1,$num2" >> finalgenecount.csv
done


#the following code provides a list of target genes
echo "The following proteomes each have at least 1 hsp70 gene and at least 1 mcrA gene and would be good candidates for further study. The first number lists the number of hsp70 genes and the second lists the number of mcrA genes" > proteomesofinterest.txt
cat finalgenecount.csv | grep -v -E ",0" | tr "," " " >> proteomesofinterest.txt
