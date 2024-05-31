ml MAFFT
ml miniconda
conda activate mito

NAME="16S"
FILE="$NAME.fa"
NCBI="NCBI_sequences/cystonectae_16S.fa"

touch $FILE
cat $NCBI > $FILE
head -q -n 2 results/*/*_$NAME.fasta >> $FILE
mafft --adjustdirectionaccurately --auto $FILE > $NAME.aln.fa
iqtree -s $NAME.aln.fa -bb 1000 --redo
