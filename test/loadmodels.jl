
sbmlfiles = [
    # a test model from BIGG
    (
        joinpath(@__DIR__, "data", "e_coli_core.xml"),
        "http://bigg.ucsd.edu/static/models/e_coli_core.xml",
        "b4db506aeed0e434c1f5f1fdd35feda0dfe5d82badcfda0e9d1342335ab31116",
        72,
        95,
        fill(1000.0, 3),
    ),
    # a relatively new non-curated model from biomodels
    (
        joinpath(@__DIR__, "data", "T1M1133.xml"),
        "https://www.ebi.ac.uk/biomodels/model/download/MODEL1909260004.4?filename=T1M1133.xml",
        "2b1e615558b6190c649d71052ac9e0dc1635e3ad281e541bc7d4fdf2892a5967",
        2517,
        3956,
        fill(1000.0, 3),
    ),
    # a curated model from biomodels
    (
        joinpath(@__DIR__, "data", "Dasgupta2020.xml"),
        "https://www.ebi.ac.uk/biomodels/model/download/BIOMD0000000973.3?filename=Dasgupta2020.xml",
        "958b131d4df2f215dae68255433542f228601db0326d26a54efd08ddcf823489",
        2,
        6,
        fill(Inf, 3),
    ),
    # a cool model with `time` from SBML testsuite
    (
        joinpath(@__DIR__, "data", "sbml00852.xml"),
        "https://raw.githubusercontent.com/sbmlteam/sbml-test-suite/master/cases/semantic/00852/00852-sbml-l3v2.xml",
        "d013765aa358d265941420c2e3d81fcbc24b0aa4e9f39a8dc8852debd1addb60",
        4,
        3,
        fill(Inf, 3),
    ),
    # a cool model with assignmentRule for a compartment
    (
        joinpath(@__DIR__, "data", "sbml00140.xml"),
        "https://raw.githubusercontent.com/sbmlteam/sbml-test-suite/master/cases/semantic/00140/00140-sbml-l3v2.xml",
        "43f0151c4f414b610b46bb62033fdcc177f4ac5cc39f3fe8b208e2e335c8d847",
        3,
        1,
        fill(Inf, 1),
    ),
    # another model from SBML suite, with initial concentrations
    (
        joinpath(@__DIR__, "data", "sbml00374.xml"),
        "https://raw.githubusercontent.com/sbmlteam/sbml-test-suite/master/cases/semantic/00374/00374-sbml-l3v2.xml",
        "424683eea6bbb577aad855d95f2de5183a36e296b06ba18b338572cd7dba6183",
        4,
        2,
        fill(Inf, 2),
    ),
    # this contains some special math
    (
        joinpath(@__DIR__, "data", "sbml01565.xml"),
        "https://raw.githubusercontent.com/sbmlteam/sbml-test-suite/master/cases/semantic/01565/01565-sbml-l3v1.xml",
        "14a80fbce316eea2adb566f67b4668ad151db8954e487309852ece7f730c8c99",
        104,
        52,
        fill(Inf, 3),
    ),
    # this contains l3v1-incompatible contents
    (
        joinpath(@__DIR__, "data", "sbml01289.xml"),
        "https://raw.githubusercontent.com/sbmlteam/sbml-test-suite/master/cases/semantic/01289/01289-sbml-l3v2.xml",
        "35ffa072052970b92fa358ee0f5750394ad74958e889cb85c98ed238642de4d0",
        0,
        0,
        Float64[],
    ),
    # this contains a relational operator
    (
        joinpath(@__DIR__, "data", "sbml00191.xml"),
        "https://raw.githubusercontent.com/sbmlteam/sbml-test-suite/master/cases/semantic/00191/00191-sbml-l3v2.xml",
        "c474e94888767d70f9e9e03b32778f18069641563953de60dabac7daa7f481ce",
        4,
        2,
        fill(Inf, 2),
    ),
    # expandInitialAssignments converter gives some warning
    (
        joinpath(@__DIR__, "data", "01234-sbml-l3v2.xml"),
        "https://raw.githubusercontent.com/sbmlteam/sbml-test-suite/52d94baf97a005b6e1fdbdb6116f5c7b4a8a100c/cases/semantic/01234/01234-sbml-l3v2.xml",
        "9610ef29f2d767af627042a15bde505b068ab75bbf00b8983823800ea8ef67c8",
        0,
        0,
        Float64[],
    ),
    (
        joinpath(@__DIR__, "data", "00489-sbml-l3v2.xml"),
        "https://raw.githubusercontent.com/sbmlteam/sbml-test-suite/master/cases/semantic/00489/00489-sbml-l3v2.xml",
        "dab2bce4e5036fa47ad8137055ca5f6dec6dfcb183542ce38573ca2e5a615813",
        3,
        2,
        fill(Inf, 2),
    ),
    # has listOfEvents
    (
        joinpath(@__DIR__, "data", "00026-sbml-l3v2.xml"),
        "https://raw.githubusercontent.com/sbmlteam/sbml-test-suite/master/cases/semantic/00026/00026-sbml-l3v2.xml",
        "991381015d9408164bf00206848ba5796d0c86dc055be91968cd7f0f68daa903",
        2,
        1,
        fill(Inf, 1),
    ),
    # has all rules types
    (
        joinpath(@__DIR__, "data", "00983-sbml-l3v2.xml"),
        "https://raw.githubusercontent.com/sbmlteam/sbml-test-suite/master/cases/semantic/00983/00983-sbml-l3v2.xml",
        "b84e53cc48edd5afc314e17f05c6a30a509aadb9486b3d788c7cf8df82a7527f",
        0,
        0,
        Float64[],
    ),
    # has all kinds of default model units
    (
        joinpath(@__DIR__, "data", "00054-sbml-l3v2.xml"),
        "https://raw.githubusercontent.com/sbmlteam/sbml-test-suite/master/cases/semantic/00054/00054-sbml-l3v2.xml",
        "987038ec9bb847123c41136928462d7ed05ad697cc414cab09fcce9f5bbc8e73",
        3,
        2,
        fill(Inf, 2),
    ),
    # has conversionFactor model attribute
    (
        joinpath(@__DIR__, "data", "00975-sbml-l3v2.xml"),
        "https://raw.githubusercontent.com/sbmlteam/sbml-test-suite/release/cases/semantic/00975/00975-sbml-l3v2.xml",
        "e32c12b7bebfa8f146b8860cd8b82d5cad326c96c6a0d8ceb191591ac4e2f5ac",
        2,
        3,
        fill(Inf, 3),
    ),
    # has the Avogadro "constant"
    (
        joinpath(@__DIR__, "data", "01323-sbml-l3v2.xml"),
        "https://raw.githubusercontent.com/sbmlteam/sbml-test-suite/release/cases/semantic/01323/01323-sbml-l3v2.xml",
        "9d9121b4f1f38f827a81a884c106c8ade6a8db29e148611c76e515775923a7fc",
        0,
        0,
        [],
    ),
    # contains initialAssignment
    (
        joinpath(@__DIR__, "data", "00878-sbml-l3v2.xml"),
        "https://raw.githubusercontent.com/sbmlteam/sbml-test-suite/release/cases/semantic/00878/00878-sbml-l3v2.xml",
        "5f70555d27469a2fdc63dedcd8d02d50b6f4f1c760802cbb5e7bb17363c2e931",
        2,
        1,
        fill(Inf, 1),
    ),
]

@testset "Loading of models from various sources - $(reader)" for reader in (
    readSBML,
    readSBMLFromString,
)
    for (sbmlfile, url, hash, expected_mets, expected_rxns, expected_3_ubs) in sbmlfiles
        if !isfile(sbmlfile)
            Downloads.download(url, sbmlfile)
        end

        cksum = bytes2hex(sha256(open(sbmlfile)))
        if cksum != hash
            @warn "The downloaded model `$sbmlfile' seems to be different from the expected one. Tests will likely fail." cksum
        end

        @testset "Loading of $sbmlfile" begin
            mdl = if reader === readSBML
                readSBML(sbmlfile)
            else
                readSBMLFromString(readchomp(sbmlfile))
            end

            @test typeof(mdl) == Model

            mets, rxns, _ = stoichiometry_matrix(mdl)

            @test length(mets) == expected_mets
            @test length(rxns) == expected_rxns

            lbs, ubs = flux_bounds(mdl)
            @test length(lbs) == expected_rxns
            @test length(ubs) == expected_rxns
            @test first.(ubs)[1:min(3, length(ubs))] == expected_3_ubs

            ocs = flux_objective(mdl)
            @test length(ocs) == expected_rxns
        end
    end
end

@testset "readSBMLFromString" begin
    @test_logs (:error, r"^SBML reported error") @test_throws AssertionError readSBMLFromString(
        "",
    )
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

@testset "Units" begin
    m = readSBML(joinpath(@__DIR__, "data", "sbml00852.xml"))
    @test SBML.unitful(m.units["volume"]) == 1 * u"L"
    @test SBML.unitful(m.units["time"]) == 1 * u"s"
    @test SBML.unitful(m.units["substance"]) == 1 * u"mol"

    m = readSBML(joinpath(@__DIR__, "data", "custom.xml"))
    @test SBML.unitful(m.units["non_existent"]) == 0.00314
    @test SBML.unitful(m.units["no_dimensions"]) == 20.0
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

@testset "Initial assignments" begin
    m = readSBML(joinpath(@__DIR__, "data", "00489-sbml-l3v2.xml"))
    @test m.initial_assignments ==
          Dict("S1" => SBML.MathApply("*", [SBML.MathVal{Int32}(2), SBML.MathIdent("p1")]))

    m = readSBML(joinpath(@__DIR__, "data", "sbml01289.xml"))
    @test m.initial_assignments == Dict(
        "p2" => SBML.MathApply("gt5", [SBML.MathVal{Int32}(8)]),
        "p1" => SBML.MathApply("gt5", [SBML.MathVal{Int32}(3)]),
    )
end

@testset "Rules" begin
    m = readSBML(joinpath(@__DIR__, "data", "Dasgupta2020.xml"))
    @test m.rules == [
        SBML.AssignmentRule(
            "s",
            SBML.MathApply(
                "/",
                [
                    SBML.MathApply(
                        "-",
                        [SBML.MathIdent("ModelValue_6"), SBML.MathIdent("P")],
                    ),
                    SBML.MathIdent("N"),
                ],
            ),
        ),
    ]

    m = readSBML(joinpath(@__DIR__, "data", "00983-sbml-l3v2.xml"))
    @test m.rules == [
        SBML.RateRule("x", SBML.MathVal{Int32}(1)),
        SBML.AlgebraicRule(
            SBML.MathApply(
                "+",
                [
                    SBML.MathApply("*", [SBML.MathVal{Int32}(-1), SBML.MathIdent("temp")]),
                    SBML.MathApply("/", [SBML.MathTime("time"), SBML.MathVal{Int32}(2)]),
                ],
            ),
        ),
        SBML.AssignmentRule(
            "y",
            SBML.MathApply("delay", [SBML.MathIdent("x"), SBML.MathIdent("temp")]),
        ),
    ]
end

@testset "Constraints" begin
    m = readSBML(joinpath(@__DIR__, "data", "custom.xml"))
    @test only(m.constraints) == SBML.Constraint(
        SBML.MathApply(
            "and",
            [
                SBML.MathApply("lt", [SBML.MathVal{Float64}(1.0), SBML.MathIdent("S1")]),
                SBML.MathApply("lt", [SBML.MathIdent("S1"), SBML.MathVal{Float64}(100.0)]),
            ],
        ),
        " Species S1 is out of range. ",
    )
end

@testset "Extensive kinetic math" begin
    m = readSBML(joinpath(@__DIR__, "data", "sbml00852.xml"))

    subterm =
        SBML.extensive_kinetic_math(m, m.reactions["reaction1"].kinetic_math).args[1].args[2]
    @test subterm.fn == "/"
    @test subterm.args[1] == SBML.MathIdent("S1")
    @test subterm.args[2] == SBML.MathIdent("C")

    m = readSBML(joinpath(@__DIR__, "data", "sbml00140.xml"))

    subterm = SBML.extensive_kinetic_math(m, m.reactions["reaction1"].kinetic_math).args[2]
    @test subterm.fn == "/"
    @test subterm.args[1] == SBML.MathIdent("S1")
    @test subterm.args[2] == SBML.MathIdent("compartment")
end

@testset "logBase and root math functions" begin
    m = readSBML(joinpath(@__DIR__, "data", "sbml01565.xml"))

    if TEST_SYMBOLICS
        @test interpret_as_num(m.reactions["J23"].kinetic_math) == 0.0

        @variables S29 S29b
        @test isequal(interpret_as_num(m.reactions["J29"].kinetic_math), 2.0 * S29 * S29b)
    end
end

@testset "rationals in math" begin
    m = readSBML(joinpath(@__DIR__, "data", "custom.xml"))
    @test m.reactions["rationalTest"].kinetic_math.val == 1 // 5000
end

@testset "converters work and fail gracefully" begin
    @test_logs (:error, r"^SBML reported error:") (:error, r"^SBML reported error:") @test_throws ErrorException readSBML(
        joinpath(@__DIR__, "data", "sbml01289.xml"),
        doc -> begin
            set_level_and_version(3, 1)(doc)
            convert_simplify_math(doc)
        end,
    )

    test_math = readSBML(
        joinpath(@__DIR__, "data", "sbml00878.xml"),
        doc -> begin
            set_level_and_version(3, 1)(doc)
            convert_promotelocals_expandfuns(doc)
        end,
    ).initial_assignments["S2"]

    @test test_math.fn == "*"
    @test test_math.args[1].fn == "*"
    @test test_math.args[1].args[1].id == "p1"
    @test test_math.args[1].args[2].id == "S1"
    @test test_math.args[2].id == "time"

    test_math =
        readSBML(
            joinpath(@__DIR__, "data", "sbml01565.xml"),
            libsbml_convert("expandInitialAssignments"),
        ).reactions["J31"].kinetic_math

    @test test_math.args[2].fn == "sin"
    @test test_math.args[2].args[1].val == 2.1

    @test_logs (:warn,) (:warn,) (:warn,) (:warn,) readSBML(
        joinpath(@__DIR__, "data", "01234-sbml-l3v2.xml"),
        doc ->
            libsbml_convert("expandInitialAssignments", ["Fatal", "Error", "Warning"])(doc),
    )
end

@testset "relational operators are decoded correctly" begin
    test_math =
        readSBML(joinpath(@__DIR__, "data", "sbml00191.xml")).reactions["reaction2"].kinetic_math

    @test test_math.args[2].fn == "geq"
end

@testset "custom show" begin
    m = readSBML(joinpath(@__DIR__, "data", "custom.xml"))
    @test repr(MIME("text/plain"), m) ==
          "Model with 1 reactions, 0 species, and 0 parameters."
    @test eval(Meta.parse(repr(m))) isa SBML.Model
end

@testset "events" begin
    m = readSBML(joinpath(@__DIR__, "data", "00026-sbml-l3v2.xml"))
    @test length(m.events) == 1
end

@testset "model attributes" begin
    m = readSBML(joinpath(@__DIR__, "data", "00054-sbml-l3v2.xml"))
    @test m.name == "case00054"
    @test m.id == "case00054"
    @test isnothing(m.conversion_factor)
    @test m.area_units == "area"
    @test m.extent_units == "substance"
    @test m.length_units == "metre"
    @test m.substance_units == "substance"
    @test m.time_units == "second"
    @test m.volume_units == "volume"
    @test isnothing(m.active_objective)

    m = readSBML(joinpath(@__DIR__, "data", "00975-sbml-l3v2.xml"))
    @test m.name == "case00975"
    @test m.id == "case00975"
    @test m.conversion_factor == "modelconv"
    @test isnothing(m.area_units)
    @test isnothing(m.extent_units)
    @test isnothing(m.length_units)
    @test isnothing(m.substance_units)
    @test isnothing(m.time_units)
    @test isnothing(m.volume_units)
    @test isnothing(m.active_objective)
end

@testset "names of objects" begin
    m = readSBML(joinpath(@__DIR__, "data", "e_coli_core.xml"))
    @test m.compartments["e"].name == "extracellular space"
    @test m.species["M_nh4_c"].name == "Ammonium"
    @test m.species["M_nh4_c"].sbo == "SBO:0000247"
    @test m.gene_products["G_b1241"].name == "adhE"
    @test m.gene_products["G_b1241"].sbo == "SBO:0000243"
    @test m.reactions["R_PFK"].name == "Phosphofructokinase"
    @test m.reactions["R_PFK"].sbo == "SBO:0000176"
    @test m.parameters["cobra_default_ub"].sbo == "SBO:0000626"
    @test m.active_objective == "obj"
end

@testset "constantness" begin
    m = readSBML(joinpath(@__DIR__, "data", "00975-sbml-l3v2.xml"))
    @test m.species["S1"].constant == false
    @test m.parameters["S1conv"].constant == true
end

function fix_constant!(model::SBML.Model)
    # We only write SBML L3v2. If a model is L2 or less, the `constant`
    # attributes may be missing (which is true for some models). We add the
    # main problematic ones (in speciesReferences) here, to make sure the
    # round trip has a chance to finish.
    _clean(sr::SBML.SpeciesReference) = SBML.SpeciesReference(
        species = sr.species,
        stoichiometry = sr.stoichiometry,
        constant = isnothing(sr.constant) ? true : sr.constant,
    )
    for (_, r) in model.reactions
        r.reactants .= map(_clean, r.reactants)
        r.products .= map(_clean, r.products)
    end
end

@testset "writeSBML" begin
    model = readSBML(joinpath(@__DIR__, "data", "Dasgupta2020.xml"))
    fix_constant!(model)
    expected = read(joinpath(@__DIR__, "data", "Dasgupta2020-written.xml"), String)
    # Remove carriage returns, if any
    expected = replace(expected, '\r' => "")
    @test @test_logs(writeSBML(model)) == expected
    mktemp() do filename, _
        @test_logs(writeSBML(model, filename))
        content = read(filename, String)
        # Remove carriage returns, if any
        content = replace(content, '\r' => "")
        @test content == expected
    end

    # Make sure that the model we read from the written out file is consistent
    # with the original model.
    @testset "Round-trip - $(basename(file))" for file in first.(sbmlfiles)
        model = readSBML(file)
        fix_constant!(model)
        round_trip_model = readSBMLFromString(@test_logs(writeSBML(model)))
        @test model.parameters == round_trip_model.parameters
        @test model.units == round_trip_model.units
        @test model.compartments == round_trip_model.compartments
        @test model.species == round_trip_model.species
        @test model.initial_assignments == round_trip_model.initial_assignments
        @test model.rules == round_trip_model.rules
        @test model.constraints == round_trip_model.constraints
        @test model.reactions == round_trip_model.reactions
        @test model.objectives == round_trip_model.objectives
        @test model.active_objective == round_trip_model.active_objective
        @test model.gene_products == round_trip_model.gene_products
        @test model.function_definitions == round_trip_model.function_definitions
        @test model.events == round_trip_model.events
        @test model.name == round_trip_model.name
        @test model.id == round_trip_model.id
        @test model.metaid == round_trip_model.metaid
        @test model.conversion_factor == round_trip_model.conversion_factor
        @test model.area_units == round_trip_model.area_units
        @test model.extent_units == round_trip_model.extent_units
        @test model.length_units == round_trip_model.length_units
        @test model.substance_units == round_trip_model.substance_units
        @test model.time_units == round_trip_model.time_units
        @test model.volume_units == round_trip_model.volume_units
        @test model.notes == round_trip_model.notes
        # We can't compare the two strings verbatim because `writeSBML` may write some
        # elements of the annotation in a slightly different order.
        @test isnothing(model.annotation) == isnothing(round_trip_model.annotation)
    end
end
