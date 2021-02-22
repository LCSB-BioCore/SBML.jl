# SBML.jl

| Build status | Documentation |
|:---:|:---:|
| ![CI](https://github.com/LCSB-BioCore/SBML.jl/workflows/CI/badge.svg?branch=master) | [![doc](https://img.shields.io/badge/docs-stable-blue)](https://lcsb-biocore.github.io/SBML.jl/stable) |


This is a simple wrap of some of the libSBML functionality, mainly the model loading for purposes of COBRA analysis methods.

Other functionality will be added as needed. Feel free to submit a PR that increases the loading "coverage".

#### Acknowledgements

`SBML.jl` was developed in Luxembourg Centre for Systems Biomedicine of the
University of Luxembourg ([uni.lu/lcsb](https://www.uni.lu/lcsb)). The
development was supported by European Union's Horizon 2020 Programme under
PerMedCoE project ([permedcoe.eu](https://www.permedcoe.eu/)) agreement no.
951773.

<img src="docs/src/assets/unilu.svg" alt="Uni.lu logo" height="64px">   <img src="docs/src/assets/lcsb.svg" alt="LCSB logo" height="64px">   <img src="docs/src/assets/permedcoe.svg" alt="PerMedCoE logo" height="64px">


## Usage

```julia
using SBML
m = readSBML("myModel.xml")

# m is now a Model structure with:
m.reactions
m.species
m.compartments
...
```

There are several helper functions, for example you can get a nice list of reactions, metabolites and the stoichiometric matrix as follows:

```julia
mets, rxns, S = getS(m)
```
