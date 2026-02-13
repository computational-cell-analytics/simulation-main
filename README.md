# An inegration pipeline for cryo-ET data simulation with PolNet and FakET.

## Overview

1. [polnet-synaptic]()
2. [faket-polnet]()

3. ## Installation
Requires cloning three repositories. Make sure they are cloned in separate directories. 

1. simulation-main
2. polnet-synaptic
3. faket-polnet
   
```bash
# clone this repository
git clone https://github.com/stmartineau99/simulation-main.git

# clone polnet-synaptic repository
git clone https://github.com/computational-cell-analytics/polnet-synaptic.git

# clone faket-polnet repository
[git clone https://github.com/stmartineau99/faket-polnet.git](https://github.com/computational-cell-analytics/faket-polnet.git)

cd simulation-main
conda create -n simulation-main -f environment-gpu.yaml --channel-priority flexible

# activate environment and install faket-polnet and polnet-synaptic inside
conda activate simulation-main
cd ../polnet-synaptic && pip install -e .

cd ../faket-polnet && pip install -e .
```
