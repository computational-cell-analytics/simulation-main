#!/bin/bash
#SBATCH -p standard96s:shared
#SBATCH --job-name=polnet_run7
#SBATCH -o data/simulation/slurm_logs/slurm-%j_%x.out
#SBATCH -t 1:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=40G
#SBATCH --qos=2h
 
CCONFIG=$1
source ~/.bashrc
micromamba activate -n simulation-main

SCRIPT_DIR=/projects/extern/nhr/nhr_ni/nim00020/dir.project/sage/source/polnet-synaptic/scripts/data_gen
cd $SCRIPT_DIR

python all_features_synapse_parallel.py \
  --config "$CONFIG"