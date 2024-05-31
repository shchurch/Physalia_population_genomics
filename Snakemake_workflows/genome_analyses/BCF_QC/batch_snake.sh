#!/bin/bash
#SBATCH --job-name=BCF_QC
#SBATCH --output=BCF_QC_%j.log
#SBATCH --requeue
#SBATCH --time=2-00:00:00
#SBATCH --partition=ycga
#SBATCH --nodes=1                    # number of cores and nodes
#SBATCH --cpus-per-task=24           # number of cores
#SBATCH --mem-per-cpu=4G             # shared memory, scaling with CPU request

# Set up modules
module purge # Unload any existing modules that might conflict
module load VCFtools
module load BCFtools
module load miniconda
module list

conda activate pcangsd

snakemake --scheduler greedy --verbose --rerun-incomplete --cores $SLURM_CPUS_PER_TASK --latency-wait 60
