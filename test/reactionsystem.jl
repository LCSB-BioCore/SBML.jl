using Catalyst, ModelingToolkit, OrdinaryDiffEq

sbmlfile = "reactionsystem_01.xml"

@parameters t, k1, c1
@variables s1, s2, s1s2

# t = Variable(:t)
# k1 = Num(Sym{ModelingToolkit.Parameter{Real}}(:k1))
# c1 = Num(Sym{ModelingToolkit.Parameter{Real}}(:c1))

COMP1 = SBML.Compartment("c1", true, 3, 2., "nl") 
SPECIES1 = SBML.Species("s1", "c1", false, nothing, nothing, (1., "substance"), nothing, true)  # Todo: Maybe not support units in initial_concentration?
SPECIES2 = SBML.Species("s2", "c1", false, nothing, nothing, nothing, (1., "substance/nl"), false)
KINETICMATH1 = SBML.MathIdent("k1")
KINETICMATH2 = SBML.MathApply("*", SBML.Math[
    SBML.MathIdent("k1"), SBML.MathIdent("s2")])
REACTION1 = SBML.Reaction(Dict("s1" => 1), nothing, nothing, nothing, nothing, KINETICMATH1)
REACTION2 = SBML.Reaction(Dict("s2" => -1), nothing, nothing, nothing, nothing, KINETICMATH2)
MODEL1 = SBML.Model(Dict("k1" => 1.), Dict(), Dict("c1" => COMP1), Dict("s1" => SPECIES1), Dict("r1" => REACTION1), nothing, nothing)  # PL: For instance in the compartments dict, we may want to enforce that key and compartment.name are identical
MODEL2 = SBML.Model(Dict("k1" => 1.), Dict(), Dict("c1" => COMP1), Dict("s2" => SPECIES2), Dict("r2" => REACTION2), nothing, nothing)


@testset "Model to MTK conversions" begin

    # Test ReactionSystem constructor
    rs = ReactionSystem(MODEL1)
    @test isequal(Catalyst.get_eqs(rs), ModelingToolkit.Reaction[ModelingToolkit.Reaction(k1, nothing, [s1], nothing, [1.]; use_only_rate=true)])
    @test isequal(Catalyst.get_iv(rs), t)
    @test isequal(Catalyst.get_states(rs), [s1])
    @test isequal(Catalyst.get_ps(rs), [k1,c1])
    @named rs = ReactionSystem(MODEL1)
    isequal(nameof(rs), :rs)

    rs = ReactionSystem(sbmlfile)
    @test isequal(Catalyst.get_eqs(rs), ModelingToolkit.Reaction[ModelingToolkit.Reaction(c1*k1*2.0*s1*2.0*s2, [s1, s2], [s1s2], [1., 1.], [1.]; use_only_rate=true)])
    @test isequal(Catalyst.get_iv(rs), t)
    @test isequal(Catalyst.get_states(rs), [s1, s1s2, s2])
    @test isequal(Catalyst.get_ps(rs), [k1,c1])
    @named rs = ReactionSystem(MODEL1)
    isequal(nameof(rs), :rs)

    # Test ODESystem constructor
    odesys = ODESystem(MODEL1)
    trueeqs = Equation[Differential(t)(s1) ~ k1]
    @test isequal(Catalyst.get_eqs(odesys), trueeqs)
    @test isequal(Catalyst.get_iv(odesys), t)
    @test isequal(Catalyst.get_states(odesys), [s1])
    @test isequal(Catalyst.get_ps(odesys), [k1, c1])
    u0 = [s1 => 1.]
    par = [k1 => 1., c1 => 2.]
    @test isequal(odesys.defaults, Dict(append!(u0, par)))  # PL: @Anand: for some reason this does not work with `Catalyst.get_default()`
    @named odesys = ODESystem(MODEL1)
    isequal(nameof(odesys), :odesys)

    odesys = ODESystem(sbmlfile)
    trueeqs = Equation[Differential(t)(s1) ~ -c1 * k1 * 2.0s1 * 2.0s2,
                       Differential(t)(s1s2) ~ c1 * k1 * 2.0s1 * 2.0s2,
                       Differential(t)(s2) ~ -c1 * k1 * 2.0s1 * 2.0s2]
    @test isequal(Catalyst.get_eqs(odesys), trueeqs)
    @test isequal(Catalyst.get_iv(odesys), t)
    @test isequal(Catalyst.get_states(odesys), [s1, s1s2, s2])
    @test isequal(Catalyst.get_ps(odesys), [k1, c1])
    u0 = [s1 => 2*1., s2 => 2*1., s1s2 => 2*1.]
    par = [k1 => 1., c1 => 2.]
    @test isequal(odesys.defaults, Dict(append!(u0, par)))
    @named odesys = ODESystem(MODEL1)
    isequal(nameof(odesys), :odesys)

    # Test ODEProblem
    oprob = ODEProblem(MODEL1, [0., 1.])
    sol = solve(oprob, Tsit5())
    @test isapprox(sol.u, [[1.], [2.]])

    @test_nowarn ODEProblem(sbmlfile, [0., 1.])

    # Test checksupport

    # Test make_extensive
    model = SBML.make_extensive(MODEL2)
    @test isequal(model.species["s2"].initial_amount, (2., ""))
    @test isequal(model.species["s2"].initial_concentration, nothing)

    kineticmath2_true = SBML.MathApply("*", SBML.Math[
        SBML.MathIdent("k1"),
        SBML.MathApply("*", SBML.Math[
            SBML.MathVal(2.0),
            SBML.MathIdent("s2")])
        ])
    @test isequal(repr(model.reactions["r2"].kinetic_math), repr(kineticmath2_true))
    @test model.species["s2"].only_substance_units

    # Test to_initial_amounts
    model = SBML.to_initial_amounts(MODEL1)
    @test isequal(model.species["s1"].initial_amount, (1., "substance"))
    @test isequal(model.species["s1"].initial_concentration, nothing)
    model = SBML.to_initial_amounts(MODEL2)
    @test isequal(model.species["s2"].initial_amount, (2., ""))
    @test isequal(model.species["s2"].initial_concentration, nothing)

    # Test to_extensive_math!
    model = SBML.to_extensive_math!(MODEL1)
    @test isequal(model.reactions["r1"].kinetic_math, KINETICMATH1)
    model = SBML.to_extensive_math!(MODEL2)
    @test isequal(repr(model.reactions["r2"].kinetic_math), repr(kineticmath2_true))
    #PL: Todo @Mirek/Anand: Why does this not work without the `repr()`?
    # Do we need to write a isequal(x::SBML.Math, y::SBML.Math) method to get this work?
    @test model.species["s2"].only_substance_units

    # Test _get_substitutions
    truesubs = Dict(Num(Variable(:c1)) => c1,
                Num(Variable(:k1)) => k1,
                Num(Variable(:s1)) => s1)
    subs = SBML._get_substitutions(MODEL1)
    @test isequal(subs, truesubs)

    # Test mtk_reactions
    reaction = SBML.mtk_reactions(MODEL1)[1]
    truereaction = ModelingToolkit.Reaction(k1, nothing, [s1], nothing, [1]; only_use_rate=true)  # Todo: implement Sam's suggestion on mass action kinetics
    @test isequal(reaction, truereaction)

    # Test get_u0
    true_u0map = [s1 => 1.]
    u0map = SBML.get_u0(MODEL1)
    @test isequal(true_u0map, u0map)

    # Test get_paramap
    trueparamap = [k1 => 1., c1 => 2.]
    paramap = SBML.get_paramap(MODEL1)
    @test isequal(paramap, trueparamap)

end
