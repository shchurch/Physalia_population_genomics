#!/bin/bash

#SBATCH --job-name=kmer
#SBATCH --output=kmer_%j.txt
#SBATCH --time=2-00:00:00
#SBATCH --partition=ycga
#SBATCH --nodes=1                    # number of cores and nodes
#SBATCH --cpus-per-task=16           # number of cores
#SBATCH --mem-per-cpu=10G            # shared memory, scaling with CPU request

module load Trimmomatic
module load BEDTools
module load SAMtools
module load miniconda
module load BWA
conda activate jellyfish
snakemake --cores $SLURM_CPUS_PER_TASK
