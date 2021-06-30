
@testset "CCall to SBML works and SBML returns a version" begin
    @test SBMLVersion() isa VersionNumber
end
