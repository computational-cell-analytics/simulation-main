#!/bin/bash
############################################################################################
# Description:
#   Pipeline Step 2: SLURM job script for noise edition using FakET.
#
# Usage:
#   - sbatch sbatch_faket_synapse.sh <config>
#
# Resources requested:
#   - Partition:      grete:interactive
#   - Time limit:     2 hours
#   - CPUs per task:  8
#   - Memory:         20G
#   - GPU:            1g.20gb
#
# Notes:
#   - IMOD module is loaded for 3D reconstruction. 
############################################################################################

#SBATCH -p grete:interactive
#SBATCH --job-name=faket
#SBATCH -o data/simulation/slurm_logs/slurm-%j_%x.out
#SBATCH -t 1:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=20G
#SBATCH -G 1g.20gb:1
#SBATCH --qos=2h

CONFIG=$1

source ~/.bashrc
micromamba activate simulation-main
module load gcc/13.2.0
module load imod/5.1.0
export IMOD_DIR=/sw/rev/25.04/rome_mofed_cuda80_rocky8/linux-rocky8-zen2/gcc-13.2.0/imod-5.1.0-ucflk2pud47w7jj27xr5zzitis7kredg
source $IMOD_DIR/IMOD-linux.sh

# add style tomograms if not already in TARGET_DIR
TARGET_DIR=/projects/extern/nhr/nhr_ni/nim00020/dir.project/sage/data/simulation/testing/run7/style_tomograms_0

if [ ! -e "$TARGET_DIR" ]; then
    ln -s /projects/extern/nhr/nhr_ni/nim00020/dir.project/sage/data/synapse/tomos "$TARGET_DIR"
fi

SCRIPT_DIR=/projects/extern/nhr/nhr_ni/nim00020/dir.project/sage/source/faket-polnet
cd $SCRIPT_DIR

python pipeline.py \
  --config "$CONFIG"
