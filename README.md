# An integrated pipeline for cryo-ET data simulation with PolNet and FakET.

## Overview
The original source code used in our simulation pipeline:
1. [PolNet](https://github.com/anmartinezs/polnet/tree/main)
   Generate tomograms from specified features. 

2. [FakET](https://github.com/paloha/faket)
   Noise addition using neural style transfer.
   
3. 3D reconstruction with IMOD
   
## Installation
These are instructions for installing both PolNet and FakET in the `simulation-main` environment. This requires cloning three repositories; make sure they are cloned in separate directories. 

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

### 1. Setup config.

See example config at `configs/czii.toml`. 

The config specifies parameters for both [polnet-synaptic](https://github.com/computational-cell-analytics/polnet-synaptic/tree/main/scripts) and [faket-polnet](https://github.com/computational-cell-analytics/faket-polnet/tree/main); check those repositories for more details.


### 2. Setup directory structure.

Setup FakET `base_dir` with `style_tomograms_{style_index}`. 

In `base_dir`, PolNet will create a directory called `simulation_dir_{simulation_index}`, which will be used as the input for FakET, along with the user-provided style tomograms.

## Usage

### 1. Download pretrained weights.

Faket uses a pretrained VGG19 model for neural style transfer.

On most HPC systems, compute nodes do not have internet access, therefore it is recommended to first download the model weights using the login node before running the pipeline. Run the following command inside your environment:

```bash
python - <<'EOF'
from torchvision.models import vgg19, VGG19_Weights
vgg19(weights=VGG19_Weights.DEFAULT)
EOF
```
The weights will be cached locally, and SLURM will automatically locate the cached file.

### 2. Running the pipeline.

After defining your config you can run the integregated pipeline using the example SLURM script at `slurm_scripts/sbatch_simulation.sh`.

Alternatively, you can create a folder containing multiple configs. I have created a submission script which will create one SLURM job for each config in a directory; see `slurm_scripts/submit_simulation.sh`.
