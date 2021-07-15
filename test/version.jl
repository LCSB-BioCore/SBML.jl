
@testset "CCall to SBML works and SBML returns a version" begin
    @test SBML.Version() isa VersionNumber
end
