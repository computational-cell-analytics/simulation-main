# An Integrated Pipeline for Cryo-ET Data Simulation

This repository orchestrates a two-step pipeline for generating synthetic cryo-ET training datasets with ground-truth labels for downstream machine learning tasks (e.g., particle picking, segmentation). All simulation parameters are controlled through TOML configuration files, enabling reproducible and scalable experiments on HPC systems.

## Overview

Pipeline dependencies:

1. **[polnet-synaptic](https://github.com/computational-cell-analytics/polnet-synaptic)** — Simulates a 3D cellular environment (membranes, actin filaments, microtubules, cytosolic proteins, membrane-bound proteins) and outputs clean 3D density maps with ground-truth labels.
2. **[faket-polnet](https://github.com/computational-cell-analytics/faket-polnet)** — Takes those density maps, simulates the TEM imaging process (tilt series projection), applies VGG19-based neural style transfer to impose real cryo-ET noise textures, and reconstructs final 3D tomograms via IMOD weighted back-projection.
3. **IMOD** — Used for tilt series projection (`xyzproj`) and 3D reconstruction (`tilt`). Must be available as a module on your HPC.

This repository (`simulation-main`) does not contain source code; it only provides TOML configs and SLURM scripts that coordinate the two phases of the pipeline. 

---

## Pipeline Variants

The polnet synaptic has two modes, each with a different entry point script:

| Mode | Script | Membranes | Cytoskeleton | Proteins |
|---|---|---|---|---|
| **Default** | `all_features_default.py` | sphere, ellipsoid, toroid | actin, microtubules | cytosolic proteins, membrane proteins |
| **Synapse** | `all_features_synapse.py` | ellipsoid (synaptic vesicles) | actin, microtubules | synaptic membrane proteins |

The **Default** mode is a general-purpose simulator that can enable or disable any combination of features. The **Synapse** mode handles a special case where all membranes are ellipsoidal to approximate synaptic vesicles, and synaptic membrane proteins are generated on the vesicle surfaces.

---

## Data Flow

```
TOML Config
    │
    ▼
Phase 1: polnet-synaptic (`all_features_default.py`  OR  `all_features_synapse.py`)
  ├── Generate membranes (sphere, ellipsoid, toroid)
  ├── Generate actin networks
  ├── Generate microtubule networks
  ├── Place cytosolic proteins
  └── Place membrane-bound proteins 
       │
       ▼
  simulation_dir_{simulation_dir_index}/
    ├── tomo_den_N.mrc               ← clean 3D density map
    ├── tomo_lbls_N.mrc              ← label mask
    └── tomos_motif_list_{N}.csv     ← particle types, positions, orientations (per tomogram)
       │
       ▼
Phase 2: faket-polnet (pipeline_parallel.py, 3 stages)
  Stage 1 (CPU):
  ├── Project style tomograms        → style tilt series (IMOD `xyzproj`)
  └── Label transform                → output JSON annotations in CZII challenge format
  Stage 2 (GPU, array job — one task per tomogram):
  ├── Project synthetic densities    → clean + noisy tilt series (IMOD `xyzproj`)
  ├── FakET neural style transfer    → style-transferred tilt series
  └── 3D reconstruction              → style-transferred tomograms (IMOD `tilt`)
  Stage 3 (CPU):
  └── Merge JSON metadata and collect reconstructed tomograms
       │
       ▼
  train_dir_{train_dir_index}/
    ├── faket_tomograms/             ← final style-transferred, reconstructed tomograms
    └── overlay/                     ← ground-truth particle annotations (JSON)
```

---

## Installation

Clone all three repositories into the same parent directory:

```bash
git clone https://github.com/computational-cell-analytics/simulation-main.git
git clone https://github.com/computational-cell-analytics/polnet-synaptic.git
git clone https://github.com/computational-cell-analytics/faket-polnet.git
```

Create and activate the conda environment:

```bash
cd simulation-main
conda env create -n simulation-main -f environment-gpu.yaml --channel-priority flexible
conda activate simulation-main
```

Install polnet-synaptic and faket-polnet into the environment:

```bash
cd ../polnet-synaptic && pip install -e .
cd ../faket-polnet && pip install -e .
```

---

## Setup

### 1. Configure the TOML file

A single TOML file controls both phases of the pipeline. See `configs/czii.toml` (default mode) or `configs/synapse.toml` (synapse mode) for examples.

- `[tool.polnet]` — Phase 1 (polnet-synaptic)
- `[tool.faket]` — Phase 2 (faket-polnet)

See [polnet-synaptic](https://github.com/computational-cell-analytics/polnet-synaptic) and [faket-polnet](https://github.com/computational-cell-analytics/faket-polnet) for more detailed parameter documentation.

### 2. Set up the directory structure

In your `base_dir` (defined in `[tool.faket]`), create a `style_tomograms_{style_index}` directory containing experimental tomograms to use as style references for neural style transfer.

In Phase 1, PolNet will automatically create `simulation_dir_{simulation_index}/` inside `base_dir`. Phase 2 will use the the simulation generated by PolNet and the user-provided style tomograms as input.

### 3. Download pretrained VGG19 weights

FakET uses a pretrained VGG19 model for neural style transfer. On most HPC systems, compute nodes do not have internet access, so download the weights from the login node before running any jobs:

```bash
python - <<'EOF'
from torchvision.models import vgg19, VGG19_Weights
vgg19(weights=VGG19_Weights.DEFAULT)
EOF
```

The weights will be cached locally, and SLURM will automatically locate the cached file.

---

## Usage

### Default mode

Place multiple `.toml` files in a directory and use the submission wrapper, which runs both phases of the pipeline for each config in parallel.

```bash
bash slurm_scripts/default/submit_simulation_default.sh
```

### Synapse mode

For the synapse mode, use the submission wrapper:

```bash
bash slurm_scripts/synapse/submit_simulation_synapse.sh
```
