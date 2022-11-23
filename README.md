# SBML.jl

| Build status | Documentation | Stats |
|:---:|:---:|:---:|
| ![CI status](https://github.com/LCSB-BioCore/SBML.jl/workflows/CI/badge.svg?branch=master) [![codecov](https://codecov.io/gh/LCSB-BioCore/SBML.jl/branch/master/graph/badge.svg?token=eJehiv1yWs)](https://codecov.io/gh/LCSB-BioCore/SBML.jl) | [![stable documentation](https://img.shields.io/badge/docs-stable-blue)](https://lcsb-biocore.github.io/SBML.jl/stable) [![dev documentation](https://img.shields.io/badge/docs-dev-cyan)](https://lcsb-biocore.github.io/SBML.jl/dev) | [![SBML Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/SBML)](https://pkgs.genieframework.com?packages=SBML) |


This is a simple wrap of some of the libSBML functionality, mainly the model loading for purposes of COBRA analysis methods and exploration of ODE system and reaction dynamics.

You might like to try the packages that use SBML.jl; these now include:

- [COBREXA.jl](https://github.com/LCSB-BioCore/COBREXA.jl), the exascale-ready
  constraint-based analysis and reconstruction toolkit for finding and modeling
  steady metabolic fluxes with the models
- [SBMLToolkit.jl](https://github.com/SciML/SBMLToolkit.jl), for working with
  the reaction dynamics of the models as ODE systems, well connected to the
  [SciML](https://github.com/SciML)
  [ModelingToolkit](https://github.com/SciML/ModelingToolkit.jl) ecosystem.

Other functionality will be added as needed. Feel free to submit a PR that increases the loading "coverage".

#### Acknowledgements

`SBML.jl` was developed at the Luxembourg Centre for Systems Biomedicine of the
University of Luxembourg ([uni.lu/lcsb](https://www.uni.lu/lcsb)), and the UCL
Research Software Development Group
([ucl.ac.uk/arc](https://www.ucl.ac.uk/arc)). The development was supported by
European Union's Horizon 2020 Programme under PerMedCoE project
([permedcoe.eu](https://www.permedcoe.eu/)) agreement no.  951773, and Chan
Zuckerberg Initiative ([chanzuckerberg.com](https://chanzuckerberg.com/)) under
grant 2020-218578 (5022).

<img src="docs/src/assets/unilu.svg" alt="Uni.lu logo" height="64px">   <img src="docs/src/assets/lcsb.svg" alt="LCSB logo" height="64px">   <img src="docs/src/assets/permedcoe.svg" alt="PerMedCoE logo" height="64px">   <img src="docs/src/assets/ucl.svg" alt="UCL logo" height="64px">

## Installation

```julia
]add SBML # or
using Pkg; Pkg.add("SBML")
```

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
mets, rxns, S = stoichiometry_matrix(m)
```
