
using Test, SHA, SparseArrays
using SBML
using SBML: Model, Reaction, Species
import Pkg

@testset "SBML test suite" begin
    include("version.jl")
    include("ecoli_flux.jl")
    include("loadmodels.jl")
end
