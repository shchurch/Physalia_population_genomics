#!/bin/bash
#SBATCH --job-name=kraken
#SBATCH --output=kraken_%j.log
#SBATCH --requeue
#SBATCH --time=2-00:00:00
#SBATCH --partition=ycga
#SBATCH --nodes=1                    # number of cores and nodes
#SBATCH --cpus-per-task=48           # number of cores
#SBATCH --mem-per-cpu=8G             # shared memory, scaling with CPU request

# Set up modules
module purge # Unload any existing modules that might conflict
ml miniconda
module load Trimmomatic
module list
conda activate pcangsd 

snakemake --scheduler greedy --verbose --rerun-incomplete --cores $SLURM_CPUS_PER_TASK
