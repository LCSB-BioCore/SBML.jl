
# SBML.jl — load systems biology models from SBML files

This package provides a straightforward way to load model- and
simulation-relevant information from SBML files.

The library provides a single function [`readSBML`](@ref) to load a
[`Model`](@ref):

```julia
julia> using SBML
julia> mdl = readSBML("Ec_core_flux1.xml")
Model(…)

julia> mdl.compartments
2-element Array{String,1}:
 "Extra_organism"
 "Cytosol"
```

There are several functions to help you with using the data in the usual
COBRA-style workflows, such as [`getS`](@ref):

```julia
julia> metabolites, reactions, S = getS(mdl)
julia> metabolites
77-element Array{String,1}:
 "M_succoa_c"
 "M_ac_c"
 "M_etoh_c"
  ⋮

julia> S
77×77 SparseArrays.SparseMatrixCSC{Float64,Int64} with 308 stored entries:
  [60,  1]  =  -1.0
  [68,  1]  =  1.0
  [1 ,  2]  =  1.0
  [6 ,  2]  =  -1.0
  ⋮
  [23, 76]  =  1.0
  [56, 76]  =  -1.0
  [30, 77]  =  -1.0
  [48, 77]  =  1.0

julia> Matrix(S)
77×77 Array{Float64,2}:
 0.0   1.0  0.0  0.0  0.0  0.0  0.0  …  0.0   0.0  0.0   0.0  0.0  0.0  0.0
 0.0   0.0  0.0  0.0  0.0  0.0  0.0     0.0   0.0  0.0   0.0  0.0  0.0  0.0
 0.0   0.0  0.0  0.0  0.0  0.0  0.0     0.0   0.0  0.0   0.0  0.0  0.0  0.0
 0.0   0.0  1.0  0.0  0.0  0.0  0.0     0.0   0.0  0.0   0.0  0.0  0.0  0.0
 0.0   0.0  0.0  0.0  0.0  0.0  0.0     0.0   0.0  0.0   0.0  0.0  0.0  0.0
 0.0  -1.0  0.0  0.0  0.0  0.0  0.0  …  0.0   0.0  0.0   0.0  0.0  0.0  0.0
 0.0   0.0  0.0  0.0  0.0  0.0  0.0     0.0   0.0  1.0  -1.0  0.0  0.0  0.0
 0.0   0.0  0.0  0.0  0.0  0.0  0.0     0.0   0.0  0.0   0.0  0.0  0.0  0.0
 0.0   0.0  0.0  0.0  0.0  0.0  0.0     0.0   0.0  0.0   0.0  0.0  0.0  0.0
 0.0   0.0  0.0  0.0  0.0  0.0  0.0     0.0  -1.0  0.0   0.0  0.0  0.0  0.0
 ⋮                         ⋮         ⋱  ⋮                          ⋮    
```

## Functions

### Data structures

```@autodocs
Modules = [SBML]
Pages = ["structs.jl"]
```

### Base functions

```@autodocs
Modules = [SBML]
Pages = ["version.jl", "readsbml.jl"]
```

## Data helpers

```@autodocs
Modules = [SBML]
Pages = ["utils.jl"]
```
