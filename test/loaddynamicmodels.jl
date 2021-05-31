sbmlfiles = [
    # (
    #     "reactionsystem_02.xml",
    #     Dict(),
    #     1,
    #     "reaction"
    # ),
    # (
    #     "reactionsystem_02.xml",
    #     Dict("promoteLocalParameters" => nothing),
    #     2,
    #     "reaction_1"
    # ),
    # (
    #     "reactionsystem_02.xml",
    #     Dict("expandFunctionDefinitions" => nothing),
    #     1,
    #     "reaction_2"
    # ),
    # (
    #     "reactionsystem_03.xml",
    #     Dict("expandInitialAssignments" => nothing),
    #     1,
    #     "reaction_2"
    # ),
    (
        "reactionsystem_04.xml",
        Dict("setLevelAndVersion" => Dict("level" => 3, "version" => 1)),  # PL: Todo: Unfortunately, libSBML has an inconsistent API here I think. Hence my solution with the Dict of level and version. Make sure users won't be surprised.
        1,
        "reaction_2"
    )
]

@testset "Loading of models from various sources" begin
    @parameters t, k1, c1
    @variables s1, s2, s4

    for (sbmlfile, conversion_options, expected_pars, expected_rxn_id) in sbmlfiles
        @testset "Loading of $sbmlfile" begin
            mdl = readSBML(sbmlfile;conversion_options=conversion_options)

            @test typeof(mdl) == Model

            @test length(mdl.parameters) == expected_pars

            @test haskey(mdl.reactions, expected_rxn_id)

            @test mdl.species["s1"].initial_concentration[1] == 1.
        end
    end
end
