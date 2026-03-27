#!/bin/bash
############################################################################################
# Description:
#   Submit script for the 3-stage parallel FakET pipeline.
#   Loops over config files in CONFIG_DIR and submits three chained SLURM jobs per file.
#
# Usage:
#   1) Before running, set the following variables at the top of the script:
#       - PARENT_DIR: Root directory of the project.
#       - CONFIG_DIR: Directory containing config files.
#       - JSON_DIR:   Directory to collect SLURM metrics.
#       - SCRIPT1:    Path to sbatch_faket_stage1.sh.
#       - SCRIPT2:    Path to sbatch_faket_stage2_array.sh.
#       - SCRIPT3:    Path to sbatch_faket_stage3.sh.
#
#   2) Set --array in sbatch_faket_stage2_array.sh to match the number of tomograms.
#
# Pipeline:
#   Stage 1: Setup (single job, CPU)
#       Projects style micrographs and runs label transformation.
#
#   Stage 2: Style transfer (array job, GPU)
#       Per-tomogram: projects content micrographs, applies FakET style transfer,
#       and reconstructs the tomogram with IMOD. Depends on Stage 1.
#
#   Stage 3: Cleanup (single job, CPU)
#       Merges per-tomogram JSON metadata, collects reconstructed tomograms to the
#       training directory, and removes intermediate directories. Depends on Stage 2.
#
# Notes:
#   - Stage 3 depends on afterok:Stage2, so it only runs if all array tasks succeed.
#   - After each stage, a metrics job is submitted to collect walltime, CPU, and memory.
############################################################################################

PARENT_DIR=/projects/extern/nhr/nhr_ni/nim00020/dir.project/sage
CONFIG_DIR=$PARENT_DIR/data/simulation/synapse_dataset_0/configs
JSON_DIR=$PARENT_DIR/data/simulation/synapse_dataset_0/slurm_metrics
mkdir -p $JSON_DIR

SCRIPT1=$PARENT_DIR/slurm_scripts/synapse/faket/sbatch_faket_stage1.sh
SCRIPT2=$PARENT_DIR/slurm_scripts/synapse/faket/sbatch_faket_stage2_array.sh
SCRIPT3=$PARENT_DIR/slurm_scripts/synapse/faket/sbatch_faket_stage3.sh

submit_job() {
    local job_name=$1
    local script=$2
    local config=$3
    local dependency=$4
    local is_array=$5

    local dependency_flag=""
    [[ -n "$dependency" ]] && dependency_flag="--dependency=afterok:$dependency"

    local job_id=$(sbatch --job-name=$job_name $dependency_flag $script $config | awk '{print $4}')
    echo "Submitted $job_name as job $job_id." >&2

    local json="${JSON_DIR}/slurm-${job_id}_${job_name}.json"
    local array_flag=""
    [[ -n "$is_array" ]] && array_flag="--is_array"

    sbatch --job-name="${job_name}_metrics" \
        --dependency=afterany:$job_id \
        --wrap="source ~/.bashrc && \
                micromamba activate simulation-main && \
                python $PARENT_DIR/slurm_scripts/collect_slurm_metrics.py $job_id --out_path $json $array_flag" > /dev/null

    echo $job_id
}

for CONFIG in $CONFIG_DIR/*.toml; do
    CONFIG_NAME=$(basename $CONFIG .toml)

    STAGE1_ID=$(submit_job "faket_s1_${CONFIG_NAME}" $SCRIPT1 $CONFIG "" "")
    STAGE2_ID=$(submit_job "faket_s2_${CONFIG_NAME}" $SCRIPT2 $CONFIG $STAGE1_ID "is_array")
    STAGE3_ID=$(submit_job "faket_s3_${CONFIG_NAME}" $SCRIPT3 $CONFIG $STAGE2_ID "")
done
