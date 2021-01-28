# SBML.jl

This is a simple wrap of some of the libSBML functionality.

Current status is "under development", something works, more wrapped stuff will
be added by need.

## Usage

```julia
using SBML
m = readSBML("myModel.xml")

# m is now a Model with
m.reactions
m.species
m.compartments
...
```

There are several helper functions, for example you can get a nice list of reactions, metabolites and the stoichiometric matrix as follows:

```julia
mets, rxns, S = getS(model)
```
