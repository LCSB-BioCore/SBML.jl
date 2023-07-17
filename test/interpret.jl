
@testset "Math interpretation" begin

    test = SBML.MathApply(
        "piecewise",
        SBML.Math[
            SBML.MathVal(123),
            SBML.MathApply("lt", SBML.Math[SBML.MathVal(1), SBML.MathVal(0)]),
            SBML.MathVal(456),
        ],
    )

    @test isequal(SBML.interpret_math(test), 456)

    test = SBML.MathApply("power", SBML.Math[SBML.MathVal(2), SBML.MathVal(-1)])

    @test isequal(SBML.interpret_math(test), 0.5)

    test = SBML.MathConst("exponentiale")
    @test isequal(SBML.interpret_math(test), exp(1))

    test =
        SBML.MathApply("gt", SBML.Math[SBML.MathVal(2), SBML.MathVal(1), SBML.MathVal(0)])
    @test SBML.interpret_math(test)
    test =
        SBML.MathApply("gt", SBML.Math[SBML.MathVal(2), SBML.MathVal(1), SBML.MathVal(2)])
    @test !SBML.interpret_math(test)

    test =
        SBML.MathApply("neq", SBML.Math[SBML.MathVal(2), SBML.MathVal(1), SBML.MathVal(0)])
    @test SBML.interpret_math(test)
    test =
        SBML.MathApply("gt", SBML.Math[SBML.MathVal(2), SBML.MathVal(1), SBML.MathVal(1)])
    @test !SBML.interpret_math(test)

    @variables x
    @test isequal(SBML.sbmlPower(1, x.val), 1^x.val)
end
