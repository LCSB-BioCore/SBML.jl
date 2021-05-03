
sbmlfiles = [
    # a test w/o conversion
    (
        "reactionsystem_02.xml",
        Dict(),
        1
    ),
    (
        "reactionsystem_02.xml",
        Dict("promoteLocalParameters" => nothing),
        2
    ),
]

@testset "Loading of models from various sources" begin
    for (sbmlfile, co, expected_pars) in sbmlfiles
        @testset "Loading of $sbmlfile" begin
            mdl = readSBML(sbmlfile;conversion_options=co)

            @test typeof(mdl) == Model

            mets, rxns, _ = getS(mdl)

            @test length(mdl.parameters) == expected_pars
        end
    end
end
