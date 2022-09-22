
using Test, SHA, SparseArrays, Downloads
using SBML
using SBML: Model, Reaction, Species
using Unitful

# this can be easily switched off in case you need the tests run faster
const TEST_SYMBOLICS = true

if TEST_SYMBOLICS
    using Symbolics
else
    macro variables(args...)
        :()
    end
end

# Some utilities needed for testing
include("common.jl")

@testset "SBML test suite" begin
    include("version.jl")

    if TEST_SYMBOLICS
        # this defines a few functions used also in loadmodels.jl
        include("symbolics.jl")
    end

    include("ecoli_flux.jl")
    include("loadmodels.jl")
    include("writemodels.jl") # depends on `sbmlfiles` from loadmodels.jl
    include("loaddynamicmodels.jl")
    include("interpret.jl")
end
