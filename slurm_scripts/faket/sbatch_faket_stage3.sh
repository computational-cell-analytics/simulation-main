#!/bin/bash
############################################################################################
# Description:
#   Pipeline Stage 3: SLURM job script for FakET pipeline cleanup.
#   Merges per-tomogram JSON metadata, collects reconstructed tomograms to the
#   training directory, and removes intermediate directories.
#
# Usage:
#   - sbatch sbatch_faket_stage3.sh <config>
#
# Resources requested:
#   - Partition:      large96s
#   - Time limit:     30 minutes
#   - CPUs per task:  4
#   - Memory:         8G
############################################################################################

#SBATCH -p large96s
#SBATCH --job-name=faket_stage3
#SBATCH -t 0:30:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G

CONFIG=$1

source ~/.bashrc
micromamba activate simulation-main

SCRIPT_DIR=/projects/extern/nhr/nhr_ni/nim00020/dir.project/sage/source/faket-polnet
cd $SCRIPT_DIR

python pipeline_parallel.py \
  --config "$CONFIG" \
  --stage 3
