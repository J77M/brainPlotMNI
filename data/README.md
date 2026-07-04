# Brain atlases

The atlases are in NIfTI-format neuroimaging file (`.nii` extension) representing the atlas parcellation overlaid on the brain template in MNI space. The following atlases are used: 

## [Brainnetome Atlas](https://atlas.brainnetome.org/download.html)

Brainnetome Atlas provides a multi-level parcellation of the human brain. It is a structural and functional atlas, integrating connectivity data from diffusion MRI and resting-state fMRI. Based on the MNI152 template space.

+ [`BN_Atlas_246_1mm.nii`](BrainnetomeAtlas/BN_Atlas_246_1mm.nii): Atlas parcellation (voxels with label `0` represent not-parceled areas - white matter or space around the brain).
+ [`BN_Atlas_labels.csv`](BrainnetomeAtlas/BN_Atlas_labels.csv): Table assigning voxel labels (numeric) to atlas labels (names), description, gyruses, lobes.
+ [`BN_Atlas_246_LUT.ctbl`](BrainnetomeAtlas/BN_Atlas_246_LUT.ctbl): Color table for Slicer 3D (colors and labels).

> Fan L, Li H, Zhuo J, Zhang Y, Wang J, Chen L, Yang Z, Chu C, Xie S, Laird AR, Fox PT, Eickhoff SB, Yu C, Jiang T. The Human Brainnetome Atlas: A New Brain Atlas Based on Connectional Architecture. Cereb Cortex. 2016 Aug;26(8):3508-26. doi: 10.1093/cercor/bhw157. Epub 2016 May 26. PMID: 27230218; PMCID: PMC4961028.

## [Yeo Atlases (Yeo7 and Yeo17)](https://surfer.nmr.mgh.harvard.edu/fswiki/CorticalParcellation_Yeo2011)

Yeo atlases (Yeo7 and Yeo17) divide the cortex into 7 or 17 networks based on resting-state fMRI. They are functional atlases focused on intrinsic connectivity. Based on the MNI152 template space.

+ [`Yeo2011_7Networks_MNI152_FreeSurferConformed1mm.nii`](YeoAtlas/Yeo2011_7Networks_MNI152_FreeSurferConformed1mm.nii): Atlas parcellation into 7 functional networks (voxels with label `0` represent not-parceled areas - white matter or space around the brain).
+ [`Yeo2011_7Networks_labels.csv`](YeoAtlas/Yeo2011_7Networks_labels.csv): Table assigning voxel labels (numeric) to atlas labels (network names).
+ [`Yeo2011_7Networks_ColorLUT.txt`](YeoAtlas/Yeo2011_7Networks_ColorLUT.txt): Color lookup table for the 7 networks.
+ [`Yeo2011_7Networks_LABELS_ColorLUT.ctbl`](YeoAtlas/Yeo2011_7Networks_LABELS_ColorLUT.ctbl): Color table for Slicer 3D (colors and labels).

An analogous set of files exists for the 17-Network variant (prefix `Yeo2011_17Networks_`).

> Yeo BT, Krienen FM, Sepulcre J, Sabuncu MR, Lashkari D, Hollinshead M, Roffman JL, Smoller JW, Zöllei L, Polimeni JR, Fischl B, Liu H, Buckner RL. The organization of the human cerebral cortex estimated by intrinsic functional connectivity. J Neurophysiol. 2011 Sep;106(3):1125-65. doi: 10.1152/jn.00338.2011. Epub 2011 Jun 8. PMID: 21653723; PMCID: PMC3174820.


## [Mars Atlas](https://meca-brain.org/software/marsatlas-colin27/)

MarsAtlas is a cortical parcellation atlas designed for functional neuroimaging studies. It is primarily a structural atlas based on macroanatomical landmarks, optimized for mapping functional data like fMRI or SEEG. Based on the Colin27 template space.

+ [`colin27_MNI_MarsAtlas.nii`](MarsAtlas/colin27_MNI_MarsAtlas.nii): Atlas parcellation (voxels with label `255` represent not-parceled areas - white matter or space around the brain). [**Download from here**](https://meca-brain.org/software/marsatlas-colin27/)
+ [`marsAtlas_labels.csv`](MarsAtlas/marsAtlas_labels.csv): Table assigning voxel labels (numeric) to atlas labels (names), description, Broadmann areas, lobes.
+ [`marsAtlas_LUT.ctbl`](MarsAtlas/marsAtlas_LUT.ctbl): Color table for Slicer 3D (colors and labels).

> Auzias G, Coulon O, Brovelli A. MarsAtlas: A cortical parcellation atlas for functional mapping. Hum Brain Mapp. 2016 Apr;37(4):1573-92. doi: 10.1002/hbm.23121. Epub 2016 Jan 27. PMID: 26813563; PMCID: PMC6867384.


## Expected Atlas Label CSV Format

The labels table (`.csv`) must use one of two formats:

**Left/Right index format** (e.g. Brainnetome, MarsAtlas) - each row encodes both hemispheres:
```
LeftIndex,RightIndex,Label,...
```
`loadAtlasLabels` splits each row into two entries with `L_`/`R_` prefixes applied to the Label and Gyrus columns.

**Single index format** (e.g. Yeo 7-Network) - the index represents a bilateral region:
```
Index,Label,...
```
Returned as-is with no laterality prefixing.

Both formats must include a `Label` column. Additional columns (e.g. `FullName`, `Gyrus`, `Lobe`, `BrodmanArea`) are preserved.

## Brain templates

Colin27 derives from 27 high-resolution T1-weighted MRI scans of a single individual (Colin Holmes), averaged after processing, making it detailed but less representative of population variability. MNI152 averages 152 healthy subjects' T1-weighted scans (often with T2/PD variants), using linear (e.g., 9-parameter) and nonlinear registrations for a more unbiased, symmetric template. Both the Colin27 and MNI152 brain templates use the same MNI (Montreal Neurological Institute) coordinate system.

> One is more suitable for our data than the other. It depends on which template was used to obtain the MNI coordinates (the MRI scans are fitted to the brain template).


> Holmes CJ, Hoge R, Collins L, Woods R, Toga AW, Evans AC. Enhancement of MR images using registration for signal averaging. J Comput Assist Tomogr. 1998 Mar-Apr;22(2):324-33. doi: 10.1097/00004728-199803000-00032. PMID: 9530404.

> Mandal PK, Mahajan R, Dinov ID. Structural brain atlases: design, rationale, and applications in normal and pathological cohorts. J Alzheimers Dis. 2012;31 Suppl 3(0 3):S169-88. doi: 10.3233/JAD-2012-120412. PMID: 22647262; PMCID: PMC4324755.
