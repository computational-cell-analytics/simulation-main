#!/bin/bash
################################################################################
# Description: 
#   Submit script for sbatch_simulation.sh.
#   Loops over config files in CONFIG_DIR and submits one SLURM job per file. 
################################################################################

CONFIG_DIR=/user/muth9/u12095/simulation/simulation-main/configs

for CONFIG in $CONFIG_DIR/*.toml; do
    JOB_NAME=$(basename "$CONFIG" .toml)
    sbatch --job-name="$JOB_NAME" slurm_scripts/sbatch_simulation.sh "$CONFIG"
done