ml BCFtools

# filtered according to tutorial described here: https://github.com/ForBioPhylogenomics/tutorials/tree/main/species_tree_inference_with_snp_data

bcftools view -e 'AC==0 || AC==AN || F_MISSING > 0.2' -m2 -M2 -O z -o all_filtered_phylo.vcf.gz ../calls/all_filtered.vcf.gz

bcftools +prune -w 100bp -n 1 -N 1st -o all_filtered_phylo2.vcf.gz all_filtered_phylo.vcf.gz

bcftools view -H ../calls/all_filtered.vcf.gz | wc -l
bcftools view -H all_filtered_phylo.vcf.gz | wc -l
bcftools view -H all_filtered_phylo2.vcf.gz | wc -l


# downloaded vcf2phylip.py: https://github.com/edgardomortiz/vcf2phylip

python vcf2phylip.py -i all_filtered_phylo2.vcf.gz -n

# had to drop dashes in species names

sed -i -E "s/-/_/g" all_filtered_phylo2.min4.nexus

# downloaded paup binary: https://phylosolutions.com/paup-test/

./paup4a168_centos64
execute all_filtered_phylo2.min4.nexus
svdq
savetrees file=all_filtered.tre

# pulled specimen IDs with bcftools query

bcftools query -l all_filtered_phylo2.vcf.gz > sample_ids.txt 

# used admixture results to group specimen IDs into species sets
# created a file taxpartitions.txt with specimen assignments in nexus format

cat all_filtered_phylo2.min4.nexus taxpartitions.txt > all_filtered_phylo2.min4.partition.nexus

./paup4a168_centos64
execute all_filtered_phylo2.min4.partition.nexus
svdq taxpartition=SPECIES bootstrap=standard nthreads=4
savetrees file=all_filtered.partition.tre

# Dsuite to run Dquartets on all 5 lineages

./Dsuite/Build/Dsuite Dquartets all_filtered_phylo2.vcf.gz pop.txt 

# results in file labeled BBAA