# brainPlotMNI

MATLAB library for 3D brain visualization and atlas-based anatomical mapping of intracranial EEG (iEEG) data in MNI space. Covers the full workflow - loading [NIfTI](https://nifti.nimh.nih.gov/nifti-1.html) atlas volumes, localizing electrode channels to anatomical areas, and producing publication-ready 3D renders of channel positions, labeled atlas areas/ROIs, and inter-regional connectivity. Example scripts included for every feature.

Developed primarily for stereo-EEG (SEEG), but applicable to ECoG and other neuroimaging methods.

![img](img/example01_simpleBrain.png)


## Requirements

- **MATLAB** R2019b or later (uses `arguments` block syntax)
- [**Image Processing Toolbox**](https://www.mathworks.com/help/images/index.html) (for `niftiread`)

## Installation

Clone the repository and add the `src/` folder to your MATLAB path:

```matlab
addpath('/path/to/brainPlotMNI/src');
```

The `+brainatlas` and `+brainvis` packages will be available on the path.

## Examples

**[example01_simpleBrain](examples/example01_simpleBrain.m)** - Basic brain outline plot with the Colin27 template. *(see image above)*

**[example02_MNIchannels](examples/example02_MNIchannels.m)** - Channel coordinates from two subjects with per-subject colors.
![](img/example02_MNIchannels.png)

**[example03_BrainnetomeAreas](examples/example03_BrainnetomeAreas.m)** - Selected left-hemisphere Brainnetome areas/regions of interests (ROIs).
![](img/example03_BrainnetomeAreas.png)

**[example04_YeoAtlas](examples/example04_YeoAtlas.m)** - All 7 Yeo resting-state networks with labels.
![](img/example04_YeoAtlas.png)

**[example05_channelsLocalization](examples/example05_channelsLocalization.m)** - Brainnetome areas colored by channel count per area.
![](img/example05_channelsLocalization.png)

**[example06_connectivity](examples/example06_connectivity.m)** - Inter- and intra-hemispheric connectivity between selected Brainnetome atlas areas.
![](img/example06_connectivity.png)


## Project Structure

```
brainPlotMNI/
├── src/                       # Library source (add this folder to path)
│   ├── +brainatlas/           # Atlas loading and MNI coordinate mapping
│   │   ├── loadAtlasVolume    Load a NIfTI atlas file
│   │   ├── loadAtlasLabels    Read and process atlas label CSV
│   │   ├── volume2MNI         Convert 3D volume to MNI coordinates
│   │   ├── importAtlasVolume  Load + convert in one step
│   │   ├── MNI2Atlas          Map channel MNI coords to atlas labels (numeric)
│   │   └── MNI2AtlasLabels    Map channel MNI coords to atlas labels (string)
│   └── +brainvis/             # 3D brain visualization
│       ├── BRAINplot          Base function: empty brain outline with views
│       ├── MNIplot            Plot electrode points in MNI space
│       ├── AREAplot           Render atlas regions with user-defined colors
│       ├── AREAplotConnectivity  Add connectivity lines/edges between areas
│       └── addLegend          Helper for colored-dot legends
├── examples/                  # Runnable demo scripts
├── data/                      # Atlas and template files (.nii, .csv, .ctbl)
└── img/                       # README showcase images
```

## Functions

### `+brainatlas` - Data Loading & Coordinate Mapping

| Function | Description |
|---|---|
| `loadAtlasVolume(atlasPath)` | Load a `.nii` atlas and return the 3D volume array and affine transform matrix. |
| `loadAtlasLabels(csvPath)` | Read a label CSV and collapse left/right index columns into a single sorted table with laterality prefixes (L_/R_). |
| `volume2MNI(Volume, transform)` | Convert a labeled 3D volume to Nx3 MNI coordinates with corresponding label values. Filters out background voxels (configurable `ignoreVal`). |
| `importAtlasVolume(atlasPath)` | Convenience wrapper that combines `loadAtlasVolume` and `volume2MNI` into a single call. |
| `MNI2Atlas(channelsMNI, atlasMNI, labels, radiusInit)` | Probabilistic channels localization in brain atlas. Assign atlas labels to channel coordinates using a spherical search with growing radius (up to `maxRadius`, default 10 mm). Returns the most probable label, distance to nearest labeled voxel, and optional probability distributions. |
| `MNI2AtlasLabels(channelsMNI, atlasMNI, labels, areasNumbers, areasLabels)` | Wraps `MNI2Atlas` to convert numeric labels to human-readable string labels with probability filtering. |

### `+brainvis` - 3D Visualization

| Function | Description |
|---|---|
| `BRAINplot(hfig, volumeMNI)` | Render an empty brain outline (`alphaShape`) with configurable views (left/front/top), anatomical direction labels, and axis styling. Shared base for all other plot functions. |
| `MNIplot(hfig, volumeMNI, channelsMNI, colors)` | Plot channel/electrode points as markers on the brain outline with user-defined colors. |
| `AREAplot(hfig, volumeMNI, atlasLabels, areaIDs, colors)` | Render specific atlas regions as colored 3D patches on the brain surface. |
| `AREAplotConnectivity(hfig, volumeMNI, atlasLabels, areaIDs, connMatrix, colors)` | Place spheres at atlas area centroids and draw connectivity lines between connected pairs. |
| `addLegend(names, colors)` | Create a horizontal legend with colored dot markers positioned at the bottom of the current axes. |

## Channel Localization

To assign an anatomical label to each iEEG electrode, `MNI2AtlasLabels` searches the atlas volume around each channel's MNI coordinate using a growing spherical radius. The most frequent atlas label found within the sphere is assigned, and the distance to the nearest voxel of that label is returned as a confidence metric (large distances suggest white matter or unlabeled regions).

The workflow is:

```matlab
% 1. Load an atlas (e.g. Brainnetome)
[Volume, transform] = brainatlas.loadAtlasVolume('data/BrainnetomeAtlas/BN_Atlas_246_1mm.nii');
[volumeMNI, volumeLabels] = brainatlas.volume2MNI(Volume, transform);

% 2. Load the label table (numeric IDs -> area names)
atlasLabelsTable = brainatlas.loadAtlasLabels('data/BrainnetomeAtlas/BN_Atlas_labels.csv');

% 3. Localize your channels (Nx3 MNI coordinates)
[chanLabels, chanDist, chanProbs] = brainatlas.MNI2AtlasLabels( ...
    channelsMNI, volumeMNI, volumeLabels, atlasLabelsTable.Index, atlasLabelsTable.Label);
```

The output `chanLabels` contains the most probable anatomical area name per channel, `chanDist` gives the distance to the nearest labeled voxel, and `chanProbs` provides a comma-separated breakdown of all label probabilities above 10%.

## Data

The repository includes the MNI152 brain template and the following atlases in NIfTI format, all registered to MNI space:

- **Brainnetome Atlas** - 246 sub-regions, structural + functional connectivity
- **Yeo 7/17 Networks** - 7 or 17 resting-state functional networks
- **Mars Atlas** - cortical parcellation based on macroanatomical landmarks ([*requires separate download*](https://meca-brain.org/software/marsatlas-colin27/))

Other atlases can be added as long as they are provided as a `.nii` volume (ideally in MNI space) with a corresponding labels `.csv`. See [data/README.md](data/README.md) for more detail on brain templates and brain atlases, file descriptions, download sources and citations.


## License & Attribution

Source code in `src/` and `examples/` is under the [MIT License](LICENSE). Atlas data files in `data/` are redistributed under their original terms:

**Brainnetome Atlas** - non-commercial use only (commercial use requires a request - see [terms](https://www.nitrc.org/include/glossary.php)).
> Fan L, Li H, Zhuo J, Zhang Y, Wang J, Chen L, Yang Z, Chu C, Xie S, Laird AR, Fox PT, Eickhoff SB, Yu C, Jiang T. The Human Brainnetome Atlas: A New Brain Atlas Based on Connectional Architecture. Cereb Cortex. 2016 Aug;26(8):3508-26. doi: 10.1093/cercor/bhw157. Epub 2016 May 26. PMID: 27230218; PMCID: PMC4961028.

**Yeo 7/17 Networks** - distributed under the [FreeSurfer Software License Agreement](freeSurferLicense.txt), which permits redistribution. Original brain parcellation under MIT license (see [here](https://github.com/ThomasYeoLab/CBIG/tree/master/stable_projects/brain_parcellation/Yeo2011_fcMRI_clustering/1000subjects_reference/Yeo_JNeurophysiol11_SplitLabels)). However this provides a splited parcellation.
> Yeo BT, Krienen FM, Sepulcre J, Sabuncu MR, Lashkari D, Hollinshead M, Roffman JL, Smoller JW, Zöllei L, Polimeni JR, Fischl B, Liu H, Buckner RL. The organization of the human cerebral cortex estimated by intrinsic functional connectivity. J Neurophysiol. 2011 Sep;106(3):1125-65. doi: 10.1152/jn.00338.2011. Epub 2011 Jun 8. PMID: 21653723; PMCID: PMC3174820.

**Mars Atlas** - license unknown; the volumetric `.nii` data is not included in this repository. Users must [download it directly](https://meca-brain.org/software/marsatlas-colin27/).
> Auzias G, Coulon O, Brovelli A. MarsAtlas: A cortical parcellation atlas for functional mapping. Hum Brain Mapp. 2016 Apr;37(4):1573-92. doi: 10.1002/hbm.23121. Epub 2016 Jan 27. PMID: 26813563; PMCID: PMC6867384.
