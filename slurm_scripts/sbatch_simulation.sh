#!/bin/bash
################################################################################
# Description: 
#   Simulation pipeline for cryo-ET data. 
#   Resource allocation designed for generating 20 tomograms with CZII shape.
#
# Author: Sage Martineau
# Date: 16-02-2026
#
# Steps:
#   1) polnet-synaptic: generate tomograms with specified features
#   2) faket-polnet: noise addition using faket style transfer, followed by 
#                    3D reconstruction using IMOD
#
# Usage:
#   sbatch sbatch_simulation.sh <config.toml>
#
# Resources requested:
#   Partition: grete:interactive
#   Walltime: 6:00:00 if membranes enabled
#             2:00:00 if membranes disabled
#   Nodes: 1
#   CPUs per task: 8
#   Memory: 40G
#   GPU: NVIDIA A100-SXM4-80GB MIG 1g.20gb (1 slice with 20G)
################################################################################

#SBATCH -p grete:interactive
#SBATCH --job-name=JOB_NAME
#SBATCH -o slurm_logs/slurm-%j_%x.out
#SBATCH -t 2:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=40G
#SBATCH -G 1g.20gb

CONFIG=$1

# Step 1 - polnet-synaptic
source ~/.bashrc
micromamba activate -n simulation-main

SCRIPT_DIR=/user/muth9/u12095/simulation/polnet-synaptic/scripts/data_gen
cd $SCRIPT_DIR

python all_features_argument.py --config "$CONFIG"

# Step 2 - faket-polnet
module load gcc/13.2.0
module load imod/5.1.0
export IMOD_DIR=/sw/rev/25.04/rome_mofed_cuda80_rocky8/linux-rocky8-zen2/gcc-13.2.0/imod-5.1.0-ucflk2pud47w7jj27xr5zzitis7kredg
source $IMOD_DIR/IMOD-linux.sh

micromamba activate -p /mnt/vast-nhr/home/muth9/u12095/micromamba/envs/simulation-main

SCRIPT_DIR=/user/muth9/u12095/simulation/faket-polnet
cd $SCRIPT_DIR

python pipeline.py --config "$CONFIG"