#!/bin/bash
#SBATCH --job-name=mito
#SBATCH --output=mito_%j.log
#SBATCH --requeue
#SBATCH --time=2-00:00:00
#SBATCH --partition=ycga
#SBATCH --nodes=1                    # number of cores and nodes
#SBATCH --cpus-per-task=48           # number of cores
#SBATCH --mem-per-cpu=8G             # shared memory, scaling with CPU request

# Set up modules
module purge # Unload any existing modules that might conflict
module load SAMtools
module load BWA
module load BCFtools
module load BEDTools
module load miniconda
module load Trimmomatic
module load PLINK
module load MAFFT
module list
conda activate go 

snakemake --scheduler greedy --verbose --rerun-incomplete --cores $SLURM_CPUS_PER_TASK
