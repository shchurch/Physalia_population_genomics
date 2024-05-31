#!/bin/bash
#SBATCH --job-name=popgen
#SBATCH --output=popgen_%j.log
#SBATCH --requeue
#SBATCH --time=2-00:00:00
#SBATCH --partition=ycga_bigmem
#SBATCH --nodes=1                    # number of cores and nodes
#SBATCH --cpus-per-task=32           # number of cores
#SBATCH --mem-per-cpu=4G             # shared memory, scaling with CPU request

# Set up modules
module purge # Unload any existing modules that might conflict
module load SAMtools
module load BWA
module load picard
module load BCFtools
module load miniconda
module load BEDTools
module load Trimmomatic
module load FastQC
#module load GATK
module list

conda activate pcangsd

snakemake --scheduler greedy --verbose --rerun-incomplete --cores $SLURM_CPUS_PER_TASK --latency-wait 60
