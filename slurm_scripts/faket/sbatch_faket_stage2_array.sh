#!/bin/bash
############################################################################################
# Description:
#   Pipeline Stage 2: SLURM array job script for per-tomogram style transfer and
#   reconstruction. One array task processes one tomogram.
#
# Usage:
#   - Do not run directly. Called by submit_simulation_synapse.sh or submit_simulation_default.sh,
#     which passes --array based on N_TOMOS. One array task processes one tomogram.
#
# Resources requested per array task:
#   - Partition:      grete:shared
#   - Time limit:     2 hours
#   - CPUs per task:  8
#   - Memory:         20G
#   - GPU:            A100:1
#
# Notes:
#   - IMOD module is loaded for 3D reconstruction.
############################################################################################

#SBATCH -p grete:shared
#SBATCH --job-name=faket_stage2
#SBATCH -t 4:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=20G
#SBATCH -G A100:1

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
  --stage 2
