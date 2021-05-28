using Symbolics

# sbmlfile = "reactionsystem_01.xml"

# @parameters t, k1, c1
# @variables s1, s2, s1s2

# t = Variable(:t)
# k1 = Num(Sym{ModelingToolkit.Parameter{Real}}(:k1))
# c1 = Num(Sym{ModelingToolkit.Parameter{Real}}(:c1))

# COMP1 = Compartment("c1", true, 3, 2., "nl") 
# SPECIES1 = Species("s1", "c1", false, nothing, nothing, (1., "substance"), nothing, true)  # Todo: Maybe not support units in initial_concentration?
# SPECIES2 = Species("s2", "c1", false, nothing, nothing, nothing, (1., "substance/nl"), false)
# KINETICMATH1 = SBML.MathIdent("k1")  # PL: @anand or @mirek help needed. Can someone create `k1 * SPECIES1` as a `Math` type here?
# REACTION1 = SBML.Reaction(Dict("s1" => -1), nothing, nothing, nothing, nothing, KINETICMATH1)
# REACTION2 = SBML.Reaction(Dict("s2" => -1), nothing, nothing, nothing, nothing, KINETICMATH1)
# MODEL1 = Model(Dict("k1" => 1.), Dict(), Dict("c1" => COMP1), Dict("s1" => SPECIES1), Dict("r1" => REACTION1), nothing, nothing)  # PL: For instance in the compartments dict, we may want to enforce that key and compartment.name are identical
# MODEL2 = Model(Dict("k1" => 1.), Dict(), Dict("c1" => COMP1), Dict("s2" => SPECIES2), Dict("r2" => REACTION2), nothing, nothing)

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
    SBML.SBML2Symbolics(test)
    @test isequal(SBML.SBML2Symbolics(test), expr_true)
end
