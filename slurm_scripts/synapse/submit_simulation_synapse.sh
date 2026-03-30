#!/bin/bash
############################################################################################
# Description:
#   Submit script for the full simulation pipeline: PolNet + 3-stage FakET.
#   Loops over config files in CONFIG_DIR and submits four chained SLURM jobs per file.
#
# Usage:
#   1) Before running, set the following variables at the top of the script:
#       - PARENT_DIR:     Root directory of the project.
#       - CONFIG_DIR:     Directory containing config files.
#       - JSON_DIR:       Directory to collect SLURM metrics.
#       - N_TOMOS:        Number of tomograms to generate.
#       - POLNET_SCRIPT:  Path to sbatch_polnet_synapse_array.sh.
#       - FAKET_SCRIPT1:  Path to sbatch_faket_stage1.sh.
#       - FAKET_SCRIPT2:  Path to sbatch_faket_stage2_array.sh.
#       - FAKET_SCRIPT3:  Path to sbatch_faket_stage3.sh.
#
# Pipeline:
#   PolNet (array job, CPU):
#       Generate tomograms with PolNet. One array task produces one tomogram.
#
#   FakET Stage 1 (single job, CPU):
#       Projects style micrographs and runs label transformation.
#
#   FakET Stage 2 (array job, GPU):
#       Per-tomogram: projects content micrographs, applies FakET style transfer,
#       and reconstructs the tomogram with IMOD.
#
#   FakET Stage 3 (single job, CPU):
#       Merges per-tomogram JSON metadata, collects reconstructed tomograms to the
#       training directory, and removes intermediate directories.
#
# Notes:
#   - Each stage depends on afterok from the previous, so the pipeline aborts if any job fails.
#   - After each stage, a metrics job is submitted to collect walltime, CPU, and memory.
############################################################################################

PARENT_DIR=/projects/extern/nhr/nhr_ni/nim00020/dir.project/sage
CONFIG_DIR=$PARENT_DIR/data/simulation/synapse_dataset_0/configs
JSON_DIR=$PARENT_DIR/data/simulation/synapse_dataset_0/slurm_metrics
LOG_DIR=$PARENT_DIR/data/simulation/slurm_logs
mkdir -p $JSON_DIR $LOG_DIR

N_TOMOS=3
ARRAY_RANGE="0-$((N_TOMOS - 1))"

POLNET_SCRIPT=$PARENT_DIR/slurm_scripts/synapse/sbatch_polnet_synapse_array.sh
FAKET_SCRIPT1=$PARENT_DIR/slurm_scripts/faket/sbatch_faket_stage1.sh
FAKET_SCRIPT2=$PARENT_DIR/slurm_scripts/faket/sbatch_faket_stage2_array.sh
FAKET_SCRIPT3=$PARENT_DIR/slurm_scripts/faket/sbatch_faket_stage3.sh

submit_job() {
    local job_name=$1
    local script=$2
    local config=$3
    local dependency=$4
    local array_range=$5   # e.g. "0-9", empty for non-array jobs

    local dependency_flag=""
    [[ -n "$dependency" ]] && dependency_flag="--dependency=afterok:$dependency"

    local array_flag=""
    [[ -n "$array_range" ]] && array_flag="--array=$array_range"

    local log_pattern=""
    if [[ -n "$array_range" ]]; then
        log_pattern="$LOG_DIR/slurm-%A_%a.out"
    else
        log_pattern="$LOG_DIR/slurm-%j_%x.out"
    fi

    local job_id=$(sbatch --job-name=$job_name $dependency_flag $array_flag \
        --output="$log_pattern" \
        $script $config | awk '{print $4}')
    if [[ -z "$job_id" ]]; then
        echo "ERROR: Failed to submit $job_name. Aborting." >&2
        exit 1
    fi
    echo "Submitted $job_name as job $job_id." >&2

    local json="${JSON_DIR}/slurm-${job_id}_${job_name}.json"
    local metrics_array_flag=""
    [[ -n "$array_range" ]] && metrics_array_flag="--is_array"

    sbatch --job-name="${job_name}_metrics" \
        --dependency=afterany:$job_id \
        --output=/dev/null \
        --wrap="source ~/.bashrc && \
                micromamba activate simulation-main && \
                python $PARENT_DIR/slurm_scripts/collect_slurm_metrics.py $job_id --out_path $json $metrics_array_flag" > /dev/null

    echo $job_id
}

for CONFIG in $CONFIG_DIR/*.toml; do
    CONFIG_NAME=$(basename $CONFIG .toml)

    JOB1_ID=$(submit_job "polnet_${CONFIG_NAME}" $POLNET_SCRIPT $CONFIG "" "$ARRAY_RANGE")
    JOB2_ID=$(submit_job "faket_s1_${CONFIG_NAME}" $FAKET_SCRIPT1 $CONFIG $JOB1_ID "")
    JOB3_ID=$(submit_job "faket_s2_${CONFIG_NAME}" $FAKET_SCRIPT2 $CONFIG $JOB2_ID "$ARRAY_RANGE")
    JOB4_ID=$(submit_job "faket_s3_${CONFIG_NAME}" $FAKET_SCRIPT3 $CONFIG $JOB3_ID "")
done
