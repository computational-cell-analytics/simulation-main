#!/bin/bash
################################################################################
# Description: 
#   Submit script for sbatch_simulation.sh.
#   Loops over config files in CONFIG_DIR and submits one SLURM job per file. 
################################################################################

CONFIG_DIR=/mnt/lustre-grete/projects/nim00020/sage/source/faket-polnet/configs

for CONFIG in $CONFIG_DIR/*.toml; do
    JOB_NAME=$(basename "$CONFIG" .toml)
    sbatch --job-name="$JOB_NAME" slurm_scripts/sbatch_simulation.sh "$CONFIG"
done