#!/bin/bash
#usage : 
#trying to combine all the know instances of mcrAgene and hsp70 found within the Proteomes files  
# and how many in each file.

for i in {1..50}
do
	echo mcrAgeneProteome_$i.output
	cat ./mcrAgeneResults/mcrAgeneProteome_$i.output | grep -E "WP*" | wc -l
done

for i in {1..50}
do
        echo hsp70Proteome_$i.output
        cat ./hsp70results/hsp70proteome_$i.output | grep -E "WP*" | wc -l
done
