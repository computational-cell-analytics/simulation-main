# An integrated pipeline for cryo-ET data simulation with PolNet and FakET.

## Overview

1. [PolNet](https://github.com/anmartinezs/polnet/tree/main)
   Description.

2. [FakET](https://github.com/paloha/faket)
   Description.
   
3. 3D reconstruction with IMOD
   
## Installation
Requires cloning three repositories. Make sure they are cloned in separate directories. 

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

1. setup config
2. setup base_dir with style_tomograms

## Usage


