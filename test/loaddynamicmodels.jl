using Test
using SBML
using Symbolics

@testset "Loading of models from various sources" begin
    @variables s1, s2, s3, s4, t, k1, c1, reaction_1_k1

    sbmlfiles = [
        (
            joinpath(@__DIR__, "data", "reactionsystem_02.xml"),
            Pair{String,Dict{String,String}}[],
            1,
            ("reaction", c1*k1*s1*s2)
        ),
        (
            joinpath(@__DIR__, "data", "reactionsystem_02.xml"),
            ["promoteLocalParameters" => Dict{String,String}()],
            2,
            ("reaction_1", c1*reaction_1_k1*s3)
        ),
        (
            joinpath(@__DIR__, "data", "reactionsystem_02.xml"),
            ["expandFunctionDefinitions" => Dict{String,String}()],
            1,
            ("reaction_2", c1*3.0*s4)
        ),
        (
            joinpath(@__DIR__, "data", "reactionsystem_03.xml"),
            ["expandInitialAssignments" => Dict{String,String}()],
            1,
            ("reaction_2", c1*k1*s4)
        ),
        (
            joinpath(@__DIR__, "data", "reactionsystem_04.xml"),
            # PL: TODO: Unfortunately, libSBML has an inconsistent API here I think. Hence
            # my solution with the Dict of level and version. Make sure users won't be
            # surprised.
            ["setLevelAndVersion" => Dict("level" => "3", "version" => "1")],
            1,
            ("reaction_2", c1*k1*s4)
        )]

    for (sbmlfile, conversion_options, expected_pars, expected_rxn) in sbmlfiles
        @testset "Loading of $sbmlfile" begin
            mdl = readSBML(sbmlfile, libsbml_convert(conversion_options))

            @test mdl isa Model

            @test length(mdl.parameters) == expected_pars

            id, math = expected_rxn
           
            # PL: TODO: Comment in once MathML is done
            @test isequal(convert(Num, mdl.reactions[id].kinetic_math), math)

            @test mdl.species["s1"].initial_concentration[1] == 1.0
        end
    end
end
