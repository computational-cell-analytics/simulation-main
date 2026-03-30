#!/bin/bash
############################################################################################
# Description:
#   Pipeline Stage 1: SLURM job script for FakET pipeline setup.
#   Projects style micrographs from style tomograms and runs label transformation.
#
# Usage:
#   - sbatch sbatch_faket_stage1.sh <config>
#
# Resources requested:
#   - Partition:      large96s
#   - Time limit:     1 hour
#   - CPUs per task:  8
#   - Memory:         20G
#
# Notes:
#   - IMOD module is loaded for style micrograph projection.
############################################################################################

#SBATCH -p large96s
#SBATCH --job-name=faket_stage1
#SBATCH -t 1:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=20G

CONFIG=$1

source ~/.bashrc
micromamba activate simulation-main
module load gcc/13.2.0
module load imod/5.1.0
export IMOD_DIR=/sw/rev/25.04/rome_mofed_cuda80_rocky8/linux-rocky8-zen2/gcc-13.2.0/imod-5.1.0-ucflk2pud47w7jj27xr5zzitis7kredg
source $IMOD_DIR/IMOD-linux.sh

SCRIPT_DIR=/projects/extern/nhr/nhr_ni/nim00020/dir.project/sage/source/faket-polnet
cd $SCRIPT_DIR

python pipeline_parallel.py \
  --config "$CONFIG" \
  --stage 1
