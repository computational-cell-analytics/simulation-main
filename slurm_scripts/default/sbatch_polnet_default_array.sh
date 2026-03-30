#!/bin/bash
############################################################################################
# Description:
#   Pipeline Step 1: SLURM job array script for default simulation using PolNet.
#
# Usage:
#   - sbatch sbatch_polnet_default_array.sh <config>
#   - The job array size specified by --array should be set to the desired number of
#     tomograms, where one array task produces one tomogram. To generate 10 tomograms:
#
#       #SBATCH --array=0-9
#
# Resources requested per array task:
#   - Partition:      large96s
#   - Time limit:     12 hours
#   - CPUs per task:  8
#   - Memory:         20G
#
# Notes:
#   Using the large96s partition allows a large number of tomograms to be simulated
#   simultaneously. The array size can be scaled without adjusting the resources requested.
############################################################################################

#SBATCH -p large96s
#SBATCH --job-name=polnet_default_array
#SBATCH --array=0-2
#SBATCH -o /projects/extern/nhr/nhr_ni/nim00020/dir.project/sage/data/simulation/slurm_logs/slurm-%A_%a.out
#SBATCH -t 24:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=20G

CONFIG=$1
source ~/.bashrc
micromamba activate -n simulation-main

SCRIPT_DIR=/projects/extern/nhr/nhr_ni/nim00020/dir.project/sage/source/polnet-synaptic/scripts/data_gen
cd $SCRIPT_DIR

python all_features_default.py \
  --config $CONFIG
