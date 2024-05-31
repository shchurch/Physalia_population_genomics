#!/bin/bash
#SBATCH --job-name=SNP
#SBATCH --output=SNP_%j.log
#SBATCH --requeue
#SBATCH --time=1-00:00:00
#SBATCH --partition=ycga
#SBATCH --nodes=1                    # number of cores and nodes
#SBATCH --cpus-per-task=24           # number of cores
#SBATCH --mem-per-cpu=12G             # shared memory, scaling with CPU request

# Set up modules
module purge # Unload any existing modules that might conflict
ml miniconda

conda activate pcangsd

./paup4a168_centos64 -n bootstrap.paup 
