
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
end
