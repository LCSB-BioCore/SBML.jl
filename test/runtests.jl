
using Test, SHA, SparseArrays, Downloads
using SBML
using SBML: Model, Reaction, Species
using Symbolics
using Unitful

@testset "SBML test suite" begin
    include("version.jl")
    include("ecoli_flux.jl")
    include("loadmodels.jl")
    include("symbolics.jl")
end
