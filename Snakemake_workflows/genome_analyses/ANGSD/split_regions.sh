DIR="region_files/"
REGIONS="../regions_filtered.list"
SAMPLE_SIZE=100000
REGION_SIZE=100

mkdir $DIR
shuf -n $SAMPLE_SIZE $REGIONS > angsd_regions_filtered.list
split -a 4 -l $REGION_SIZE angsd_regions_filtered.list $DIR

