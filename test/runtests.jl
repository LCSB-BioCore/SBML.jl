
using Test, SHA, SparseArrays, Downloads
using SBML
using SBML: Model, Reaction, Species
using Unitful

# Some utilities needed for testing
include("common.jl")

@testset "SBML test suite" begin
    include("version.jl")

    include("ecoli_flux.jl")
    include("loadmodels.jl")
    include("writemodels.jl") # depends on `sbmlfiles` from loadmodels.jl
    include("loaddynamicmodels.jl")
    include("interpret.jl")
end
