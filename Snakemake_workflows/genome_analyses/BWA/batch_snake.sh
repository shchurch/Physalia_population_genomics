#!/bin/bash
#SBATCH --job-name=popgen
#SBATCH --output=popgen_%j.log
#SBATCH --requeue
#SBATCH --time=2-00:00:00
#SBATCH --partition=ycga
#SBATCH --nodes=1                    # number of cores and nodes
#SBATCH --cpus-per-task=1           # number of cores
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

snakemake --rerun-incomplete --workflow-profile /vast/palmer/pi/dunn/sc2962/20240918_Physalia_PopGen_chrom/workflow_profile --cores 1  --use-envmodules --latency-wait 60 --verbose --scheduler greedy \
