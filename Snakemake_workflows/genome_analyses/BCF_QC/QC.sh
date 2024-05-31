ml VCFtools

SUBSET_VCF=../calls/all_filtered_subsample.vcf.gz
OUT=all_filtered_subsample
vcftools --gzvcf $SUBSET_VCF --freq2 --out $OUT --max-alleles 2
vcftools --gzvcf $SUBSET_VCF --depth --out $OUT
vcftools --gzvcf $SUBSET_VCF --site-mean-depth --out $OUT
vcftools --gzvcf $SUBSET_VCF --site-quality --out $OUT
vcftools --gzvcf $SUBSET_VCF --missing-indv --out $OUT
vcftools --gzvcf $SUBSET_VCF --missing-site --out $OUT
vcftools --gzvcf $SUBSET_VCF --het --out $OUT

mv all_filtered_subsample* ../vcftools_stats/ 
