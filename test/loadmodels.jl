
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
        joinpath(@__DIR__, "data", "00852-sbml-l3v2.xml"),
        SBML.test_suite_url(852, level = 3, version = 2),
        "d013765aa358d265941420c2e3d81fcbc24b0aa4e9f39a8dc8852debd1addb60",
        4,
        3,
        fill(Inf, 3),
    ),
    # a cool model with assignmentRule for a compartment
    (
        joinpath(@__DIR__, "data", "00140-sbml-l3v2.xml"),
        SBML.test_suite_url(140, level = 3, version = 2),
        "43f0151c4f414b610b46bb62033fdcc177f4ac5cc39f3fe8b208e2e335c8d847",
        3,
        1,
        fill(Inf, 1),
    ),
    # another model from SBML suite, with initial concentrations
    (
        joinpath(@__DIR__, "data", "00374-sbml-l3v2.xml"),
        SBML.test_suite_url(374, level = 3, version = 2),
        "424683eea6bbb577aad855d95f2de5183a36e296b06ba18b338572cd7dba6183",
        4,
        2,
        fill(Inf, 2),
    ),
    # this contains some special math
    (
        joinpath(@__DIR__, "data", "01565-sbml-l3v1.xml"),
        SBML.test_suite_url(1565, level = 3, version = 1),
        "14a80fbce316eea2adb566f67b4668ad151db8954e487309852ece7f730c8c99",
        104,
        52,
        fill(Inf, 3),
    ),
    # this contains l3v1-incompatible contents
    (
        joinpath(@__DIR__, "data", "01289-sbml-l3v2.xml"),
        SBML.test_suite_url(1289, level = 3, version = 2),
        "35ffa072052970b92fa358ee0f5750394ad74958e889cb85c98ed238642de4d0",
        0,
        0,
        Float64[],
    ),
    # this contains a relational operator
    (
        joinpath(@__DIR__, "data", "00191-sbml-l3v2.xml"),
        SBML.test_suite_url(191, level = 3, version = 2),
        "c474e94888767d70f9e9e03b32778f18069641563953de60dabac7daa7f481ce",
        4,
        2,
        fill(Inf, 2),
    ),
    # expandInitialAssignments converter gives some warning
    (
        joinpath(@__DIR__, "data", "01234-sbml-l3v2.xml"),
        SBML.test_suite_url(1234, level = 3, version = 2),
        "9610ef29f2d767af627042a15bde505b068ab75bbf00b8983823800ea8ef67c8",
        0,
        0,
        Float64[],
    ),
    (
        joinpath(@__DIR__, "data", "00489-sbml-l3v2.xml"),
        SBML.test_suite_url(489, level = 3, version = 2),
        "dab2bce4e5036fa47ad8137055ca5f6dec6dfcb183542ce38573ca2e5a615813",
        3,
        2,
        fill(Inf, 2),
    ),
    # has listOfEvents
    (
        joinpath(@__DIR__, "data", "00026-sbml-l3v2.xml"),
        SBML.test_suite_url(26, level = 3, version = 2),
        "991381015d9408164bf00206848ba5796d0c86dc055be91968cd7f0f68daa903",
        2,
        1,
        fill(Inf, 1),
    ),
    # has all rules types
    (
        joinpath(@__DIR__, "data", "00983-sbml-l3v2.xml"),
        SBML.test_suite_url(983, level = 3, version = 2),
        "b84e53cc48edd5afc314e17f05c6a30a509aadb9486b3d788c7cf8df82a7527f",
        0,
        0,
        Float64[],
    ),
    # has all kinds of default model units
    (
        joinpath(@__DIR__, "data", "00054-sbml-l3v2.xml"),
        SBML.test_suite_url(54, level = 3, version = 2),
        "987038ec9bb847123c41136928462d7ed05ad697cc414cab09fcce9f5bbc8e73",
        3,
        2,
        fill(Inf, 2),
    ),
    # has conversionFactor model attribute
    (
        joinpath(@__DIR__, "data", "00975-sbml-l3v2.xml"),
        SBML.test_suite_url(975, level = 3, version = 2),
        "e32c12b7bebfa8f146b8860cd8b82d5cad326c96c6a0d8ceb191591ac4e2f5ac",
        2,
        3,
        fill(Inf, 3),
    ),
    # has conversionFactor species attribute
    (
        joinpath(@__DIR__, "data", "00976-sbml-l3v2.xml"),
        SBML.test_suite_url(976, level = 3, version = 2),
        "6cec83157cd81a585597c02f225e814a9ce2a1c9255a039b3083c97cfe02dd00",
        2,
        3,
        fill(Inf, 3),
    ),
    # has the Avogadro "constant"
    (
        joinpath(@__DIR__, "data", "01323-sbml-l3v2.xml"),
        SBML.test_suite_url(1323, level = 3, version = 2),
        "9d9121b4f1f38f827a81a884c106c8ade6a8db29e148611c76e515775923a7fc",
        0,
        0,
        [],
    ),
    # contains initialAssignment
    (
        joinpath(@__DIR__, "data", "00878-sbml-l3v2.xml"),
        SBML.test_suite_url(878, level = 3, version = 2),
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

    m = readSBML(joinpath(@__DIR__, "data", "00852-sbml-l3v2.xml"))
    @test all(contains_time.(r.kinetic_math for (_, r) in m.reactions))
end

@testset "Units" begin
    m = readSBML(joinpath(@__DIR__, "data", "00852-sbml-l3v2.xml"))
    @test SBML.unitful(m.units["volume"]) == 1 * u"L"
    @test SBML.unitful(m.units["time"]) == 1 * u"s"
    @test SBML.unitful(m.units["substance"]) == 1 * u"mol"

    m = readSBML(joinpath(@__DIR__, "data", "custom.xml"))
    @test SBML.unitful(m.units["non_existent"]) == 0.00314
    @test SBML.unitful(m.units["no_dimensions"]) == 20.0
end

@testset "Initial amounts and concentrations" begin
    m = readSBML(joinpath(@__DIR__, "data", "00852-sbml-l3v2.xml"))

    @test all(isnothing(ic) for (k, ic) in SBML.initial_concentrations(m))
    @test length(SBML.initial_amounts(m)) == 4
    @test isapprox(sum(ia for (sp, ia) in SBML.initial_amounts(m)), 0.001)
    @test isapprox(
        sum(ic for (sp, ic) in SBML.initial_concentrations(m, convert_amounts = true)),
        0.001,
    )

    m = readSBML(joinpath(@__DIR__, "data", "00374-sbml-l3v2.xml"))

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

    m = readSBML(joinpath(@__DIR__, "data", "01289-sbml-l3v2.xml"))
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
    m = readSBML(joinpath(@__DIR__, "data", "00852-sbml-l3v2.xml"))

    subterm =
        SBML.extensive_kinetic_math(m, m.reactions["reaction1"].kinetic_math).args[1].args[2]
    @test subterm.fn == "/"
    @test subterm.args[1] == SBML.MathIdent("S1")
    @test subterm.args[2] == SBML.MathIdent("C")

    m = readSBML(joinpath(@__DIR__, "data", "00140-sbml-l3v2.xml"))

    subterm = SBML.extensive_kinetic_math(m, m.reactions["reaction1"].kinetic_math).args[2]
    @test subterm.fn == "/"
    @test subterm.args[1] == SBML.MathIdent("S1")
    @test subterm.args[2] == SBML.MathIdent("compartment")
end

@testset "logBase and root math functions" begin
    m = readSBML(joinpath(@__DIR__, "data", "01565-sbml-l3v1.xml"))

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
        joinpath(@__DIR__, "data", "01289-sbml-l3v2.xml"),
        doc -> begin
            set_level_and_version(3, 1)(doc)
            convert_simplify_math(doc)
        end,
    )

    test_math = readSBML(
        joinpath(@__DIR__, "data", "00878-sbml-l3v2.xml"),
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
            joinpath(@__DIR__, "data", "01565-sbml-l3v1.xml"),
            libsbml_convert("expandInitialAssignments"),
        ).reactions["J31"].kinetic_math

    @test test_math.args[2].fn == "sin"
    @test test_math.args[2].args[1].val == 2.1

    @test_logs (:warn,) (:warn,) (:warn,) (:warn,) readSBML(
        joinpath(@__DIR__, "data", "01234-sbml-l3v2.xml"),
        doc -> libsbml_convert(
            "expandInitialAssignments",
            report_severities = ["Fatal", "Error", "Warning"],
            throw_severities = ["Fatal", "Error"],
        )(
            doc,
        ),
    )
end

@testset "relational operators are decoded correctly" begin
    test_math =
        readSBML(joinpath(@__DIR__, "data", "00191-sbml-l3v2.xml")).reactions["reaction2"].kinetic_math

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

    m = readSBML(joinpath(@__DIR__, "data", "00976-sbml-l3v2.xml"))
    @test m.species["S1"].conversion_factor == "S1conv"
end

@testset "names and identifiers of objects" begin
    m = readSBML(joinpath(@__DIR__, "data", "e_coli_core.xml"))
    @test m.compartments["e"].name == "extracellular space"
    @test m.species["M_nh4_c"].name == "Ammonium"
    @test m.species["M_nh4_c"].sbo == "SBO:0000247"
    @test length(m.species["M_nh4_c"].cv_terms) == 1
    @test m.species["M_nh4_c"].cv_terms[1].biological_qualifier == :is
    @test issetequal(
        [
            "http://identifiers.org/bigg.metabolite/nh4",
            "http://identifiers.org/biocyc/META:AMMONIA",
            "http://identifiers.org/biocyc/META:AMMONIUM",
            "http://identifiers.org/chebi/CHEBI:13405",
            "http://identifiers.org/chebi/CHEBI:13406",
            "http://identifiers.org/chebi/CHEBI:13407",
            "http://identifiers.org/chebi/CHEBI:135980",
            "http://identifiers.org/chebi/CHEBI:13771",
            "http://identifiers.org/chebi/CHEBI:16134",
            "http://identifiers.org/chebi/CHEBI:22533",
            "http://identifiers.org/chebi/CHEBI:22534",
            "http://identifiers.org/chebi/CHEBI:28938",
            "http://identifiers.org/chebi/CHEBI:29337",
            "http://identifiers.org/chebi/CHEBI:29340",
            "http://identifiers.org/chebi/CHEBI:44269",
            "http://identifiers.org/chebi/CHEBI:44284",
            "http://identifiers.org/chebi/CHEBI:44404",
            "http://identifiers.org/chebi/CHEBI:49783",
            "http://identifiers.org/chebi/CHEBI:7434",
            "http://identifiers.org/chebi/CHEBI:7435",
            "http://identifiers.org/envipath/32de3cf4-e3e6-4168-956e-32fa5ddb0ce1/compound/41e4c903-407f-49f7-bf6b-0a94d39fa3a7",
            "http://identifiers.org/envipath/5882df9c-dae1-4d80-a40e-db4724271456/compound/27a89bdf-42f7-478f-91d8-e39881581096",
            "http://identifiers.org/envipath/650babc9-9d68-4b73-9332-11972ca26f7b/compound/96667bd9-aeae-4e8f-89d3-100d0396af05",
            "http://identifiers.org/hmdb/HMDB00051",
            "http://identifiers.org/hmdb/HMDB41827",
            "http://identifiers.org/inchi_key/QGZKDVFQNNGYKY-UHFFFAOYSA-O",
            "http://identifiers.org/kegg.compound/C00014",
            "http://identifiers.org/kegg.compound/C01342",
            "http://identifiers.org/kegg.drug/D02915",
            "http://identifiers.org/kegg.drug/D02916",
            "http://identifiers.org/metanetx.chemical/MNXM15",
            "http://identifiers.org/reactome.compound/1132163",
            "http://identifiers.org/reactome.compound/113561",
            "http://identifiers.org/reactome.compound/140912",
            "http://identifiers.org/reactome.compound/2022135",
            "http://identifiers.org/reactome.compound/29382",
            "http://identifiers.org/reactome.compound/31633",
            "http://identifiers.org/reactome.compound/389843",
            "http://identifiers.org/reactome.compound/5693978",
            "http://identifiers.org/reactome.compound/76230",
            "http://identifiers.org/sabiork/1268",
            "http://identifiers.org/sabiork/43",
            "http://identifiers.org/seed.compound/cpd00013",
            "http://identifiers.org/seed.compound/cpd19013",
        ],
        m.species["M_nh4_c"].cv_terms[1].resource_uris,
    )
    @test m.gene_products["G_b1241"].name == "adhE"
    @test m.gene_products["G_b1241"].sbo == "SBO:0000243"
    @test length(m.gene_products["G_b1241"].cv_terms) == 1
    @test m.gene_products["G_b1241"].cv_terms[1].biological_qualifier == :is
    @test issetequal(
        [
            "http://identifiers.org/asap/ABE-0004164",
            "http://identifiers.org/ecogene/EG10031",
            "http://identifiers.org/ncbigene/945837",
            "http://identifiers.org/ncbigi/16129202",
            "http://identifiers.org/refseq_locus_tag/b1241",
            "http://identifiers.org/refseq_name/adhE",
            "http://identifiers.org/refseq_synonym/adhC",
            "http://identifiers.org/refseq_synonym/ana",
            "http://identifiers.org/refseq_synonym/ECK1235",
            "http://identifiers.org/refseq_synonym/JW1228",
            "http://identifiers.org/uniprot/P0A9Q7",
        ],
        m.gene_products["G_b1241"].cv_terms[1].resource_uris,
    )
    @test m.reactions["R_PFK"].name == "Phosphofructokinase"
    @test m.reactions["R_PFK"].sbo == "SBO:0000176"
    @test length(m.reactions["R_PFK"].cv_terms) == 1
    @test m.reactions["R_PFK"].cv_terms[1].biological_qualifier == :is
    @test issetequal(
        [
            "http://identifiers.org/bigg.reaction/PFK",
            "http://identifiers.org/ec-code/2.7.1.11",
            "http://identifiers.org/metanetx.reaction/MNXR102507",
            "http://identifiers.org/rhea/16109",
            "http://identifiers.org/rhea/16110",
            "http://identifiers.org/rhea/16111",
            "http://identifiers.org/rhea/16112",
        ],
        m.reactions["R_PFK"].cv_terms[1].resource_uris,
    )
    @test m.parameters["cobra_default_ub"].sbo == "SBO:0000626"
    @test m.active_objective == "obj"
end

@testset "constantness" begin
    m = readSBML(joinpath(@__DIR__, "data", "00975-sbml-l3v2.xml"))
    @test m.species["S1"].constant == false
    @test m.parameters["S1conv"].constant == true
end
