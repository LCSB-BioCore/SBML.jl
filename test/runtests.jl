
using Test, SHA, SparseArrays
using SBML
import Pkg

@testset "SBML test suite" begin
    include("version.jl")
    include("loadEColi.jl")
end
