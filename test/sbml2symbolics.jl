using Symbolics

A = Symbolics.Variable(Symbol("A"))
B = Symbolics.Variable(Symbol("B"))
C = Symbolics.Variable(Symbol("C"))
D = Symbolics.Variable(Symbol("D"))
E = Symbolics.Variable(Symbol("E"))

@testset "Math to Symbolics conversions" begin

    test = SBML.MathApply("*", SBML.Math[
        SBML.MathApply("+", SBML.Math[
            SBML.MathApply("*", SBML.Math[
                SBML.MathIdent("A"),
                SBML.MathIdent("B")]),
            SBML.MathApply("-", SBML.Math[
                SBML.MathApply("*", SBML.Math[
                    SBML.MathIdent("C"),
                    SBML.MathIdent("D")])])]),           
        SBML.MathIdent("E")])

    expr_true = (A*B - C*D) * E
    ex = convert(Num,test)
    @test isequal(convert(Num,test), expr_true)
end
