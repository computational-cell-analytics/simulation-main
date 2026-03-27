#!/bin/bash
############################################################################################
# Description:
#   Pipeline Stage 2: SLURM array job script for per-tomogram style transfer and
#   reconstruction. One array task processes one tomogram.
#
# Usage:
#   - sbatch sbatch_faket_stage2_array.sh <config>
#   - The job array size specified by --array should match the number of tomograms
#     generated in Stage 1. To process 3 tomograms (indices 0-2):
#
#       #SBATCH --array=0-2
#
# Resources requested per array task:
#   - Partition:      grete:interactive
#   - Time limit:     2 hours
#   - CPUs per task:  8
#   - Memory:         20G
#   - GPU:            1g.20gb
#
# Notes:
#   - IMOD module is loaded for 3D reconstruction.
#   - Run submit_faket_parallel.sh to submit the full 3-stage pipeline.
############################################################################################

#SBATCH -p grete:interactive
#SBATCH --job-name=faket_stage2
#SBATCH --array=0-2
#SBATCH -o /projects/extern/nhr/nhr_ni/nim00020/dir.project/sage/data/simulation/slurm_logs/slurm-%A_%a.out
#SBATCH -t 2:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=20G
#SBATCH -G 1g.20gb:1
#SBATCH --qos=2h

CONFIG=$1

source ~/.bashrc
micromamba activate simulation-main
module load gcc/13.2.0
module load imod/5.1.0
export IMOD_DIR=/sw/rev/25.04/rome_mofed_cuda80_rocky8/linux-rocky8-zen2/gcc-13.2.0/imod-5.1.0-ucflk2pud47w7jj27xr5zzitis7kredg
source $IMOD_DIR/IMOD-linux.sh

SCRIPT_DIR=/projects/extern/nhr/nhr_ni/nim00020/dir.project/sage/source/faket-polnet
cd $SCRIPT_DIR

python faket_polnet/pipeline_parallel.py \
  --config "$CONFIG" \
  --stage 2
