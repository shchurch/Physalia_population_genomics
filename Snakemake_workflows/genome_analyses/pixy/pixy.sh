#!/bin/bash
#SBATCH --job-name=pixy
#SBATCH --output=pixy_%j.log
#SBATCH --requeue
#SBATCH --time=2-00:00:00
#SBATCH --partition=ycga
#SBATCH --nodes=1                    # number of cores and nodes
#SBATCH --cpus-per-task=16           # number of cores
#SBATCH --mem-per-cpu=4G             # shared memory, scaling with CPU request

# Set up modules
module purge # Unload any existing modules that might conflict
module load BCFtools
module load miniconda
#module load GATK
module list

conda activate pixy

pixy --stats pi fst dxy --vcf ../calls/all_filtered.vcf.gz --populations kmeans_clusters.txt --n_cores 16 --bed_file /gpfs/gibbs/pi/dunn/sc2962/20230901_Physalia_PopGen/regions_filtered.tsv --output_folder ../pixy/kmeans/ &> logs/pixy/kmeans.log
#pixy --stats pi fst dxy --vcf ../calls/all_filtered.vcf.gz --populations locations.txt --n_cores 16 --bed_file /gpfs/gibbs/pi/dunn/sc2962/20230901_Physalia_PopGen/regions_filtered.tsv --output_folder ../pixy/locations/ &> logs/pixy/locations.log

#pixy --stats pi fst dxy --vcf ../calls/all_filtered.vcf.gz --populations strict.txt --n_cores 16 --bed_file /gpfs/gibbs/pi/dunn/sc2962/20230901_Physalia_PopGen/regions_filtered.tsv --output_folder ../pixy/strict/ &> logs/pixy/strict.log
