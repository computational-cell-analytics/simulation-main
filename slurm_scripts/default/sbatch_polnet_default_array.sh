#!/bin/bash
############################################################################################
# Description:
#   Pipeline Step 1: SLURM job array script for default simulation using PolNet.
#
# Usage:
#   - Do not run directly. Called by submit_simulation_default.sh, which passes --array
#     based on N_TOMOS. One array task produces one tomogram.
#
# Resources requested per array task:
#   - Partition:      large96s
#   - Time limit:     2 hours
#   - CPUs per task:  8
#   - Memory:         10G
#
# Notes:
#   Using the large96s partition allows a large number of tomograms to be simulated
#   simultaneously. The array size can be scaled without adjusting the resources requested.
############################################################################################

#SBATCH -p large96s
#SBATCH --job-name=polnet_default
#SBATCH -o /projects/extern/nhr/nhr_ni/nim00020/dir.project/sage/data/simulation/slurm_logs/slurm-%A_%a.out
#SBATCH -t 2:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=10G
#SBATCH --qos=2h

CONFIG=$1
source ~/.bashrc
micromamba activate -n simulation-main

SCRIPT_DIR=/projects/extern/nhr/nhr_ni/nim00020/dir.project/sage/source/polnet-synaptic/scripts/data_gen
cd $SCRIPT_DIR

python all_features_default.py \
  --config $CONFIG
