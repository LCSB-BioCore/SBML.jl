
sbmlfiles = [
    # a test model from BIGG
    (
        joinpath(@__DIR__, "data", "e_coli_core.xml"),
        "http://bigg.ucsd.edu/static/models/e_coli_core.xml",
        "b4db506aeed0e434c1f5f1fdd35feda0dfe5d82badcfda0e9d1342335ab31116",
        72,
        95,
    ),
    # a relatively new non-curated model from biomodels
    (
        joinpath(@__DIR__, "data", "T1M1133.xml"),
        "https://www.ebi.ac.uk/biomodels/model/download/MODEL1909260004.4?filename=T1M1133.xml",
        "2b1e615558b6190c649d71052ac9e0dc1635e3ad281e541bc7d4fdf2892a5967",
        2517,
        3956,
    ),
    # a curated model from biomodels
    (
        joinpath(@__DIR__, "data", "Dasgupta2020.xml"),
        "https://www.ebi.ac.uk/biomodels/model/download/BIOMD0000000973.3?filename=Dasgupta2020.xml",
        "958b131d4df2f215dae68255433542f228601db0326d26a54efd08ddcf823489",
        2,
        6,
    ),
    # a cool model with `time` from SBML testsuite
    (
        joinpath(@__DIR__, "data", "sbml00852.xml"),
        "https://raw.githubusercontent.com/sbmlteam/sbml-test-suite/master/cases/semantic/00852/00852-sbml-l3v2.xml",
        "d013765aa358d265941420c2e3d81fcbc24b0aa4e9f39a8dc8852debd1addb60",
        4,
        3,
    ),
    # another model from SBML suite, with initial concentrations
    (
        joinpath(@__DIR__, "data", "sbml00374.xml"),
        "https://raw.githubusercontent.com/sbmlteam/sbml-test-suite/master/cases/semantic/00374/00374-sbml-l3v2.xml",
        "424683eea6bbb577aad855d95f2de5183a36e296b06ba18b338572cd7dba6183",
        4,
        2,
    ),
    # this contains some special math
    (
        joinpath(@__DIR__, "data", "sbml01565.xml"),
        "https://raw.githubusercontent.com/sbmlteam/sbml-test-suite/master/cases/semantic/01565/01565-sbml-l3v1.xml",
        "14a80fbce316eea2adb566f67b4668ad151db8954e487309852ece7f730c8c99",
        104,
        52,
    ),
    # this contains l3v1-incompatible contents
    (
        joinpath(@__DIR__, "data", "sbml01289.xml"),
        "https://raw.githubusercontent.com/sbmlteam/sbml-test-suite/master/cases/semantic/01289/01289-sbml-l3v2.xml",
        "35ffa072052970b92fa358ee0f5750394ad74958e889cb85c98ed238642de4d0",
        0,
        0,
    ),
]

@testset "Loading of models from various sources" begin
    for (sbmlfile, url, hash, expected_mets, expected_rxns) in sbmlfiles
        if !isfile(sbmlfile)
            Downloads.download(url, sbmlfile)
        end

        cksum = bytes2hex(sha256(open(sbmlfile)))
        if cksum != hash
            @warn "The downloaded model `$sbmlfile' seems to be different from the expected one. Tests will likely fail." cksum
        end

        @testset "Loading of $sbmlfile" begin
            mdl = readSBML(sbmlfile)

            @test typeof(mdl) == Model

            mets, rxns, _ = getS(mdl)

            @test length(mets) == expected_mets
            @test length(rxns) == expected_rxns
        end
    end
end

@testset "Time variables in math" begin
    # this test is here mainly for keeping a magical constant that we need for
    # parsing time synced with libsbml source
    contains_time(x::SBML.MathTime) = true
    contains_time(x::SBML.MathApply) = any(contains_time.(x.args))
    contains_time(_) = false

    m = readSBML(joinpath(@__DIR__, "data", "sbml00852.xml"))
    @test all(contains_time.(r.kinetic_math for (_, r) in m.reactions))
end

@testset "Initial amounts and concentrations" begin
    m = readSBML(joinpath(@__DIR__, "data", "sbml00852.xml"))

    @test all(isnothing(ic) for (k, ic) in SBML.initial_concentrations(m))
    @test length(SBML.initial_amounts(m)) == 4
    @test isapprox(sum(ia for (sp, ia) in SBML.initial_amounts(m)), 0.001)
    @test isapprox(
        sum(ic for (sp, ic) in SBML.initial_concentrations(m, convert_amounts = true)),
        0.001,
    )

    m = readSBML(joinpath(@__DIR__, "data", "sbml00374.xml"))

    @test all(isnothing(ic) for (k, ic) in SBML.initial_amounts(m))
    @test length(SBML.initial_concentrations(m)) == 4
    @test isapprox(sum(ic for (sp, ic) in SBML.initial_concentrations(m)), 0.00208)
    @test isapprox(
        sum(ia for (sp, ia) in SBML.initial_amounts(m, convert_concentrations = true)),
        0.25 * 0.00208,
    )
end

@testset "Extensive kinetic math" begin
    m = readSBML(joinpath(@__DIR__, "data", "sbml00852.xml"))

    subterm =
        SBML.extensive_kinetic_math(m, m.reactions["reaction1"].kinetic_math).args[1].args[2]
    @test subterm.fn == "/"
    @test subterm.args[1] == SBML.MathIdent("S1")
    @test isapprox(subterm.args[2].val, 1.0)
end

@testset "logBase and root math functions" begin
    m = readSBML(joinpath(@__DIR__, "data", "sbml01565.xml"))

    @test convert(Num, m.reactions["J23"].kinetic_math) == 0.0

    @variables S29 S29b
    @test isequal(convert(Num, m.reactions["J29"].kinetic_math), 2.0 * S29 * S29b)
end

@testset "converters work and fail gracefully" begin
    @test_logs (:error, r"^SBML reported error:") (:error, r"^SBML reported error:") @test_throws ErrorException readSBML(
        joinpath(@__DIR__, "data", "sbml01289.xml"),
        doc -> begin
            set_level_and_version(3, 1)(doc)
            convert_simplify_math(doc)
        end,
    )

    test_math =
        readSBML(
            joinpath(@__DIR__, "data", "sbml01565.xml"),
            libsbml_convert("expandInitialAssignments"),
        ).reactions["J31"].kinetic_math

    @test test_math.args[2].fn == "sin"
    @test test_math.args[2].args[1].val == 2.1
end
