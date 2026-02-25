# An integrated pipeline for cryo-ET data simulation with PolNet and FakET.

## Overview
The original source code used in our simulation pipeline:
1. [PolNet](https://github.com/anmartinezs/polnet/tree/main)
   Generate tomograms from specified features. 

2. [FakET](https://github.com/paloha/faket)
   Noise addition using FakET style transfer.
   
3. 3D reconstruction with IMOD
   
## Installation
These are instructions for installing both PolNet and FakET in one `simulation-main` environment. Requires cloning three repositories. Make sure they are cloned in separate directories. 

1. simulation-main
2. [polnet-synaptic](https://github.com/computational-cell-analytics/polnet-synaptic/tree/main/scripts)
3. [faket-polnet](https://github.com/computational-cell-analytics/faket-polnet/tree/main)
   
```bash
# clone this repository
git clone https://github.com/computational-cell-analytics/simulation-main.git

# clone polnet-synaptic repository
git clone https://github.com/computational-cell-analytics/polnet-synaptic.git

# clone faket-polnet repository
git clone https://github.com/computational-cell-analytics/faket-polnet.git

cd simulation-main
conda create -n simulation-main -f environment-gpu.yaml --channel-priority flexible

# activate the new environment 
conda activate simulation-main

# install polnet-synaptic and faket-polnet packages inside the environment 
cd ../polnet-synaptic && pip install -e .
cd ../faket-polnet && pip install -e .
```
## Setup

1. Setup config, see example at `configs/czii.toml`. The config specifies parameters for both [polnet-synaptic](https://github.com/computational-cell-analytics/polnet-synaptic/tree/main/scripts) and [faket-polnet](https://github.com/computational-cell-analytics/faket-polnet/tree/main); check those repositories for more details.
2. Setup FakET `base_dir` with `style_tomograms_{style_index}`. In `base_dir`, PolNet will create a directory called `simulation_dir_{simulation_index}`, which will be used as the input for FakET, along with the user-provided style tomograms.

## Usage

After defining your config you can run the integregated pipeline using the example SLURM script at `slurm_scripts/sbatch_simulation.sh`.

Alternatively you can create a folder containing multiple configs. I have created a submission script which will create one SLURM job for each config in a directory; see `slurm_scripts/submit_simulation.sh`.
