@testset "Loading of models from various sources" begin
    @variables s1, s2, s3, s4, t, k1, c1, reaction_1_k1

    sbmlfiles = [
        (
            joinpath("data", "reactionsystem_02.xml"),
            Dict(),
            1,
            ("reaction", c1*k1*s1*s2)
        ),
        (
            joinpath("data", "reactionsystem_02.xml"),
            Dict("promoteLocalParameters" => nothing),
            2,
            ("reaction_1", c1*reaction_1_k1*s3)
        ),
        (
            joinpath("data", "reactionsystem_02.xml"),
            Dict("expandFunctionDefinitions" => nothing),
            1,
            ("reaction_2", c1*3.0*s4)
        ),
        (
            joinpath("data", "reactionsystem_03.xml"),
            Dict("expandInitialAssignments" => nothing),
            1,
            ("reaction_2", c1*k1*s4)
        ),
        (
            joinpath("data", "reactionsystem_04.xml"),
            Dict("setLevelAndVersion" => Dict("level" => 3, "version" => 1)),  # PL: Todo: Unfortunately, libSBML has an inconsistent API here I think. Hence my solution with the Dict of level and version. Make sure users won't be surprised.
            1,
            ("reaction_2", c1*k1*s4)
        )]

    for (sbmlfile, conversion_options, expected_pars, expected_rxn) in sbmlfiles
        @testset "Loading of $sbmlfile" begin
            mdl = readSBML(sbmlfile;conversion_options=conversion_options)

            @test typeof(mdl) == Model

            @test length(mdl.parameters) == expected_pars

            id, math = expected_rxn
           
            @test isequal(convert(Num, mdl.reactions[id].kinetic_math), math)  # PL: Todo: Comment in once MathML is done

            @test mdl.species["s1"].initial_concentration[1] == 1.
        end
    end
end
