using Catalyst, ModelingToolkit, OrdinaryDiffEq
using Test, SHA, SparseArrays
using SBML
using SBML: Model, Reaction, Species
using Symbolics
import Pkg

@testset "SBML test suite" begin
    include("version.jl")
    include("ecoli_flux.jl")
    include("loadmodels.jl")
    include("sbml2symbolics.jl")
    include("reactionsystem.jl")
    include("loaddynamicmodels.jl")
end
