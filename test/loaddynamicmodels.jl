compartment = SBML.MathIdent("compartment")
k1 = SBML.MathIdent("k1")
k2 = SBML.MathIdent("k2")
reaction1_k = SBML.MathIdent("reaction1_k")
S1 = SBML.MathIdent("S1")

sbmlfiles = [
    # sbml_test_suite case 00001
    (
        joinpath(@__DIR__, "data", "00001-sbml-l3v2.xml"),
        SBML.test_suite_url(1, level = 3, version = 2),
        "3e9a8bfe27343459d7a1e462fc3fd4eb2b01dc7b32af1db06a98f366287da01a",
        x -> nothing,
        1,
        ("reaction1", SBML.MathApply("*", [SBML.MathApply("*", [compartment, k1]), S1])),
        ("S1", 0.00015),
    ),
    # case 00001 in older level and version
    (
        joinpath(@__DIR__, "data", "00001-sbml-l2v1.xml"),
        SBML.test_suite_url(1, level = 2, version = 1),
        "71a145c58b08e475d76bdec644589b2a55b5c5c2fee218274c91677c0f30b508",
        SBML.set_level_and_version(3, 2),
        1,
        ("reaction1", SBML.MathApply("*", [SBML.MathApply("*", [compartment, k1]), S1])),
        ("S1", 0.00015),
    ),
    # case 00057 with localParameters
    (
        joinpath(@__DIR__, "data", "00057-sbml-l3v2.xml"),
        SBML.test_suite_url(57, level = 3, version = 2),
        "3e84e19cebbb79eea879847f541b1d22db6eb239f1f070ef4609f04c77688659",
        SBML.libsbml_convert("promoteLocalParameters"),
        2,
        (
            "reaction1",
            SBML.MathApply("*", [SBML.MathApply("*", [compartment, reaction1_k]), S1]),
        ),
        ("S1", 0.0003),
    ),
    # case 00025 with functionDefinition
    (
        joinpath(@__DIR__, "data", "00025-sbml-l3v2.xml"),
        SBML.test_suite_url(25, level = 3, version = 2),
        "d3231ae3858d9e5dca1b106aa7b106a0caee9e6967ef8413de6b9acde9171c3e",
        SBML.libsbml_convert("expandFunctionDefinitions"),
        1,
        ("reaction1", SBML.MathApply("*", [compartment, SBML.MathApply("*", [k1, S1])])),
        ("S1", 0.0015),
    ),
    # case 00036 with initialAssignment
    (
        joinpath(@__DIR__, "data", "00037-sbml-l3v2.xml"),
        SBML.test_suite_url(37, level = 3, version = 2),
        "074f0caeaf2cdc390967bfdf06d80ccad519c648df7f421dc4e9c69e71551dff",
        SBML.libsbml_convert("expandInitialAssignments"),
        2,
        ("reaction1", SBML.MathApply("*", [SBML.MathApply("*", [compartment, k2]), S1])),
        ("S1", 0.01125),
    ),
    # case 00928 with an ID-less event
    (
        joinpath(@__DIR__, "data", "00928-sbml-l3v2.xml"),
        SBML.test_suite_url(928, level = 3, version = 2),
        "d2a95aee820712696a2056bb09fd7d3befcd99e331809105e12ee081073a4985",
        x -> nothing,
        1,
        (
            "reaction1",
            SBML.MathApply(
                "*",
                SBML.Math[
                    SBML.MathApply(
                        "*",
                        SBML.Math[SBML.MathIdent("C"), SBML.MathIdent("k1")],
                    ),
                    SBML.MathIdent("S1"),
                ],
            ),
        ),
        ("S1", 0.0),
    ),
]

@testset "Loading of models from sbml_test_suite" begin
    for (sbmlfile, url, hash, converter, expected_par, expected_rxn, expected_u0) in
        sbmlfiles

        if !isfile(sbmlfile)
            Downloads.download(url, sbmlfile)
        end

        cksum = bytes2hex(sha256(open(sbmlfile)))
        if cksum != hash
            @warn "The downloaded model `$sbmlfile' seems to be different from the expected one. Tests will likely fail." cksum
        end

        @testset "Loading of $sbmlfile" begin
            mdl = readSBML(sbmlfile, converter)

            @test typeof(mdl) == Model

            @test length(mdl.parameters) == expected_par

            id, math = expected_rxn
            @test isequal(repr(mdl.reactions[id].kinetic_math), repr(math))

            id, ic = expected_u0
            if basename(sbmlfile) == "00037-sbml-l3v2.xml"
                # When expanding initial assignments with libsbml, the initial amount
                # becomes empty.
                @test_broken mdl.species[id].initial_amount == ic
            else
                @test mdl.species[id].initial_amount == ic
            end
        end
    end
end
