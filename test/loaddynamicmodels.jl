using ModelingToolkit

@parameters t, k1, c1
@variables s1, s2, s4

sbmlfiles = [
    # a test w/o conversion
    (
        "reactionsystem_02.xml",
        Dict(),
        1,
        ("reaction", "c1 * k1 * s1 * s2")
    ),
    (
        "reactionsystem_02.xml",
        Dict("promoteLocalParameters" => nothing),
        2,
        ("reaction_1", "c1 * reaction_1_k1 * s3")
    ),
    (
        "reactionsystem_02.xml",
        Dict("expandFunctionDefinitions" => nothing),
        1,
        ("reaction_2", "c1 * 3 * s4")
    )
]

@testset "Loading of models from various sources" begin
    for (sbmlfile, co, expected_pars, expected_rxn) in sbmlfiles
        @testset "Loading of $sbmlfile" begin
            mdl = readSBML(sbmlfile;conversion_options=co)

            @test typeof(mdl) == Model

            @test length(mdl.parameters) == expected_pars

            id, math = expected_rxn
            # @test mdl.reactions[id].kinetic_math == math  # PL: Todo: Comment in once MathML is done
        end
    end
end
