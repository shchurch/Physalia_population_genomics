#!/bin/bash
#SBATCH --job-name=shark
#SBATCH --output=shark_%j.log
#SBATCH --requeue
#SBATCH --time=1-00:00:00
#SBATCH --partition=ycga
#SBATCH --nodes=1                    # number of cores and nodes
#SBATCH --cpus-per-task=8           # number of cores
#SBATCH --mem-per-cpu=24G             # shared memory, scaling with CPU request

# Set up modules
module purge # Unload any existing modules that might conflict
ml miniconda
module list

conda activate shark

snakemake --scheduler greedy --verbose --rerun-incomplete --cores $SLURM_CPUS_PER_TASK --latency-wait 60

