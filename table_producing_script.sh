#!/bin/bash
# table_producing_script.sh


# Function to display the script's usage
show_usage() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  -h  Display this help message"
  echo "  -r  Remove table.txt and proteome_Files_of_Interest.txt"
  echo "Flexible to inputs, yes...(inputs not specified)"
  exit 1
}

rem_files(){
    echo "Removing files..."
    rm table.txt proteome_Files_of_Interest.txt
    sleep 0.5
    echo "Done."
    exit 0
}


# Process command-line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h)
      show_usage
      ;;
    -r)
      rem_files
      ;;
    *)
      echo "Invalid option: $1"
      show_usage
      ;;
  esac
  shift
done


# Before we even use muscle, we combine all the hsp70 and mcrA reference sequences into one file
cat ref_sequences/mcrAgene_* > combined_mcrAgene.fasta
cat ref_sequences/hsp70gene_* > combined_hsp70gene.fasta

# Muscle alignment for mcrA and hsp70
./muscle -align combined_mcrAgene.fasta -output aligned_combined_mcrAgene.fasta
./muscle -align combined_hsp70gene.fasta -output aligned_combined_hsp70Agene.fasta

# hmmbuild for mcrA and hsp70 
./hmmbuild mcrAgene.hmm aligned_combined_mcrAgene.fasta
./hmmbuild hsp70.hmm aligned_combined_hsp70Agene.fasta


# Check to see if mcrAgeneResultsFinal dir exists
if [ ! -d "mcrAgeneResultsFinal" ]; then
	mkdir mcrAgeneResultsFinal
else
	echo "mcrAgeneResultsFinal directory already exists."
fi

# Check to see if hsp70ResultsFinal dir exists
if [ ! -d "hsp70ResultsFinal" ]; then
	mkdir hsp70ResultsFinal
else
	echo "hsp70ResultsFinal directory already exists."
fi

# Initialize Table

echo "--------------------------------------------------------------------" >> table.txt
echo "Proteome File      |  mcrA Gene Matches   |  hsp70 Gene Matches   |" >> table.txt 
echo "--------------------------------------------------------------------" >> table.txt


# for loop that does hmmsearch for both mcrA and hsp70
for i in {01..50}; do 
	# generate the table of matched genes for mcrA
	./hmmsearch --tblout mcrAgeneProteome_$i.output mcrAgene.hmm ./proteomes/proteome_$i.fasta > /dev/null
	mv mcrAgeneProteome_$i.output mcrAgeneResultsFinal/ 

	
	# generate the table of matched genes for hsp70
	./hmmsearch --tblout hsp70Proteome_$i.output hsp70.hmm ./proteomes/proteome_$i.fasta > /dev/null
	mv hsp70Proteome_$i.output hsp70ResultsFinal/

	mcrAmatches=$(cat ./mcrAgeneResultsFinal/mcrAgeneProteome_$i.output | grep -E "WP*" | wc -l)
	hsp70matches=$(cat ./hsp70ResultsFinal/hsp70Proteome_$i.output | grep -E "WP*" | wc -l)
	echo "proteome_$i.output |  $mcrAmatches                   |  $hsp70matches                    |" >> table.txt	
    if [ $mcrAmatches -gt 0 ] && [ $hsp70matches -gt 0 ]; then
        echo "proteome_$i.fasta |mcrA: $mcrAmatches hsp70: $hsp70matches" >> proteome_Files_of_Interest.txt
    fi



done

echo "****Results located in table.txt.****************************************"
echo "****pH-resistant methanogens found in proteome_Files_of_Interest.txt.****"
