# SBML.jl

| Build status | Documentation |
|:---:|:---:|
| ![CI](https://github.com/LCSB-BioCore/SBML.jl/workflows/CI/badge.svg?branch=develop) | [![doc](https://img.shields.io/badge/docs-stable-blue)](https://lcsb-biocore.github.io/SBML.jl/) |


This is a simple wrap of some of the libSBML functionality, mainly the model loading for purposes of COBRA analysis methods.

Other functionality will be added as needed. Feel free to submit a PR that increases the loading "coverage".

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
mets, rxns, S = getS(model)
```
