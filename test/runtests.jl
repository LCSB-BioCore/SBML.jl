
using Test
using SBML
import Pkg

@testset "CCall to SBML works and SBML returns a version" begin
    @test typeof(SBMLVersion())==Pkg.VersionNumber
end
