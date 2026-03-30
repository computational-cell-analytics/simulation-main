#!/bin/bash
############################################################################################
# Description: 
#   Submit script for synapse simulation pipeline.
#   Loops over config files in CONFIG_DIR and submits one SLURM job per file.
#
# Usage:
#   1) Before running, set the following variables at the top of the script:
#       - PARENT_DIR: Root directory of the project.
#       - CONFIG_DIR: Directory containing config files for simulation pipeline.
#       - JSON_DIR:   Directory to collect slurm metrics.
#       - SCRIPT1:    Path to Step 1 script, sbatch_polnet_synapse_array.sh.
#       - SCRIPT2:    Path to Step 2 script, sbatch_faket_synapse.sh.
#
#   2) Setup config. See example at configs/synapse.toml.
#       - Paths in the config should follow the directory structure described in (3):
#           - Under [tool.polnet], set `out_dir`.
#           - Under [tool.faket], set `base_dir`.
#   
#   3) Setup the pipeline directory structure. 
#       - Create a parent directory `base_dir`. 
#       - Add `style_tomograms_0` to `base_dir`.
#       - SCRIPT1 will generate `simulation_dir_{simulation_index}` inside the `base_dir`,
#           which will be directly used by SCRIPT2.
#       
#   4) Adjust resources as needed in SCRIPT1 and SCRIPT2. 
#       - Output JSON files can help identify if adjustments are needed.
#
# Pipeline:
#   Step 1: polnet-synaptic
#       Generate tomograms with specified features, including synaptic vesicles with 
#       membrane proteins, actin, and microtubule filaments.
#
#   Step 2: faket-polnet
#       Noise addition using FakET style transfer, followed by 3D reconstruction using IMOD.
#
# Notes:
#   - Step 2 is submitted with a dependency so that it runs after the successful completion of 
#   - Step 1. This way, we can request different resource allocations for Step 1 and 2.
#   - After each step, another job is submitted to collect SLURM metrics including walltime, 
#       CPU, and memory usage. The results are saved to a JSON in JSON_DIR. 
############################################################################################

PARENT_DIR=/projects/extern/nhr/nhr_ni/nim00020/dir.project/sage
CONFIG_DIR=$PARENT_DIR/data/simulation/synapse_dataset_0/configs
JSON_DIR=$PARENT_DIR/data/simulation/synapse_dataset_0/slurm_metrics
mkdir -p $JSON_DIR

SCRIPT1=$PARENT_DIR/slurm_scripts/synapse/sbatch_polnet_job_array.sh
SCRIPT2=$PARENT_DIR/slurm_scripts/synapse/sbatch_faket_synapse.sh

submit_job() {
    local job_name=$1
    local script=$2
    local config=$3
    local dependency=$4
    local is_array=$5

    # build dependency flag for simulation pipeline 
    local dependency_flag=""
    [[ -n "$dependency" ]] && dependency_flag="--dependency=afterok:$dependency"

    local job_id=$(sbatch --job-name=$job_name $dependency_flag $script $config | awk '{print $4}')
    echo "Submitted $job_name as job $job_id." >&2

    local json="${JSON_DIR}/slurm-${job_id}_${job_name}.json"

    # build array flay for slurm metrics
    local array_flag=""
    [[ -n "$is_array" ]] && array_flag="--is_array"

    sbatch --job-name="${job_name}_metrics" \
        --dependency=afterany:$job_id \
        --wrap="source ~/.bashrc && \
                micromamba activate simulation-main && \
                python $PARENT_DIR/slurm_scripts/collect_slurm_metrics.py $job_id --out_path $json $array_flag" > /dev/null

    # return job id
    echo $job_id
}

for CONFIG in $CONFIG_DIR/*.toml; do
    CONFIG_NAME=$(basename $CONFIG .toml)
    SCRIPT1_JOB_ID=$(submit_job "polnet_${CONFIG_NAME}" $SCRIPT1 $CONFIG "" "is_array")

    # submit SCRIPT2 with dependency on SCRIPT1
    SCRIPT2_JOB_ID=$(submit_job "faket_${CONFIG_NAME}" $SCRIPT2 $CONFIG $SCRIPT1_JOB_ID "")
done