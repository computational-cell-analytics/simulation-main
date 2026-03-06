#!/bin/bash
############################################################################################
# Description: 
#   Submit script for synapse simulation pipeline.
#   Loops over config files in CONFIG_DIR and submits one SLURM job per file.
#
# Steps:
#   1) polnet-synaptic
#      Generate tomograms with specified features, including synaptic vesicles with 
#      membrane proteins, actin, and microtubule filaments.
#
#   2) faket-polnet
#      Noise addition using FakET style transfer, followed by 3D reconstruction using IMOD.
#
# Notes:
#   Step 2 is submitted with a dependency so that it runs after the sucessful completion of 
#   Step 1. This way, we can request different resource allocations for Step 1 and 2.
############################################################################################

SCRIPT1=./slurm_scripts/synapse/sbatch_polnet_synapse.sh
SCRIPT2=./slurm_scripts/synapse/sbatch_faket_synapse.sh

CONFIG_DIR=/projects/extern/nhr/nhr_ni/nim00020/dir.project/sage/data/simulation/testing/run7/configs

for CONFIG in $CONFIG_DIR/*.toml; do
    JOB_NAME=$(basename $CONFIG .toml)
    SCRIPT1_JOB_ID=$(sbatch --job-name=$JOB_NAME $SCRIPT1 $CONFIG | awk '{print $4}')
    sbatch --job-name=$JOB_NAME --dependency=afterok:$SCRIPT1_JOB_ID $SCRIPT2 $CONFIG
done