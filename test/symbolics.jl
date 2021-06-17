
@testset "Math to Symbolics conversions" begin
    @variables A B C D Time

    test = SBML.MathApply(
        "*",
        SBML.Math[
            SBML.MathApply(
                "+",
                SBML.Math[
                    SBML.MathApply(
                        "*",
                        SBML.Math[SBML.MathIdent("A"), SBML.MathIdent("B")],
                    ),
                    SBML.MathApply(
                        "-",
                        SBML.Math[SBML.MathApply(
                            "*",
                            SBML.Math[SBML.MathIdent("C"), SBML.MathIdent("D")],
                        )],
                    ),
                ],
            ),
            SBML.MathTime("Time"),
        ],
    )

    @test isequal(convert(Num, test), (A * B - C * D) * Time)

    test = SBML.MathApply(
        "piecewise",
        SBML.Math[
            SBML.MathApply("lt", SBML.Math[SBML.MathVal(1), SBML.MathVal(0)]),
            SBML.MathVal(123),
            SBML.MathVal(456),
        ],
    )

    @test isequal(convert(Num, test), 456)
end
