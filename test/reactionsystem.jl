using Catalyst, ModelingToolkit, OrdinaryDiffEq

sbmlfile = "reactionsystem_01.xml"

@parameters t, k1, c1
@variables s1, s2, s1s2

# t = Variable(:t)
# k1 = Num(Sym{ModelingToolkit.Parameter{Real}}(:k1))
# c1 = Num(Sym{ModelingToolkit.Parameter{Real}}(:c1))

COMP1 = Compartment("c1", true, 3, 2., "nl") 
SPECIES1 = Species("s1", "c1", false, nothing, nothing, (1., "substance"), nothing, true)  # Todo: Maybe not support units in initial_concentration?
SPECIES2 = Species("s2", "c1", false, nothing, nothing, nothing, (1., "substance/nl"), false)
KINETICMATH1 = SBML.MathIdent("k1")  # PL: @anand or @mirek help needed. Can someone create `k1 * SPECIES1` as a `Math` type here?
REACTION1 = SBML.Reaction(Dict("s1" => -1), nothing, nothing, nothing, nothing, KINETICMATH1)
REACTION2 = SBML.Reaction(Dict("s2" => -1), nothing, nothing, nothing, nothing, KINETICMATH1)
MODEL1 = Model(Dict("k1" => 1.), Dict(), Dict("c1" => COMP1), Dict("s1" => SPECIES1), Dict("r1" => REACTION1), nothing, nothing)  # PL: For instance in the compartments dict, we may want to enforce that key and compartment.name are identical
MODEL2 = Model(Dict("k1" => 1.), Dict(), Dict("c1" => COMP1), Dict("s2" => SPECIES2), Dict("r2" => REACTION2), nothing, nothing)


@testset "Model to MTK conversions" begin

    # Test to_initial_amounts
    model = SBML.to_initial_amounts(MODEL2)
    @test isequal(model.species["s2"].initial_amount, (2., ""))
    @test isequal(model.species["s2"].initial_concentration, nothing)
    model = SBML.to_initial_amounts(MODEL1)
    @test isequal(model.species["s1"].initial_amount, (1., "substance"))
    @test isequal(model.species["s1"].initial_concentration, nothing)

    # Test mtk_reaction
    reaction = SBML.mtk_reactions(MODEL1)[1]
    truereaction = ModelingToolkit.Reaction(k1, [s1], nothing, [1], nothing; only_use_rate=true)  # Todo: implement Sam's suggestion on mass action kinetics
    @test isequal(reaction, truereaction)

    # Test _get_substitutions
    truesubs = Dict(Num(Variable(:c1)) => c1,
                Num(Variable(:k1)) => k1,
                Num(Variable(:s1)) => s1)
    subs = SBML._get_substitutions(MODEL1)
    @test isequal(subs, truesubs)

    # Test get_u0
    true_u0map = [s1 => 1.]
    u0map = SBML.get_u0(MODEL1)
    @test isequal(true_u0map, u0map)

    # Test get_paramap
    trueparamap = [k1 => 1., c1 => 2.]
    paramap = SBML.get_paramap(MODEL1)
    @test isequal(paramap, trueparamap)

    # Test ReactionSystem constructor
    rs = ReactionSystem(MODEL1)
    @test isequal(Catalyst.get_eqs(rs), ModelingToolkit.Reaction[ModelingToolkit.Reaction(k1, [s1], nothing, [1.], nothing; use_only_rate=true)])
    @test isequal(Catalyst.get_iv(rs), t)
    @test isequal(Catalyst.get_states(rs), [s1])
    @test isequal(Catalyst.get_ps(rs), [k1,c1])
    @named rs = ReactionSystem(MODEL1)
    isequal(nameof(rs), :rs)

    rs = ReactionSystem(sbmlfile)
    @test isequal(Catalyst.get_eqs(rs), ModelingToolkit.Reaction[ModelingToolkit.Reaction(c1*k1*s1*s2, [s1, s2], [s1s2], [1., 1.], [1.]; use_only_rate=true)])
    @test isequal(Catalyst.get_iv(rs), t)
    @test isequal(Catalyst.get_states(rs), [s1, s1s2, s2])
    @test isequal(Catalyst.get_ps(rs), [k1,c1])
    @named rs = ReactionSystem(MODEL1)
    isequal(nameof(rs), :rs)

    # Test ODESystem constructor
    odesys = ODESystem(MODEL1)
    trueeqs = Equation[Differential(t)(s1) ~ -k1]
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
    trueeqs = Equation[Differential(t)(s1) ~ -k1 * s1 * s2,
                       Differential(t)(s2) ~ -k1 * s1 * s2,
                       Differential(t)(s1s2) ~ k1 * s1 * s2]
    # @test isequal(Catalyst.get_eqs(odesys), trueeqs)
    @test isequal(Catalyst.get_iv(odesys), t)
    # @test isequal(Catalyst.get_states(odesys), [s1, s2, s1s2])
    @test isequal(Catalyst.get_ps(odesys), [k1, c1])
    u0 = [s1 => 1., s2 => 1., s1s2 => 1.]
    par = [k1 => 1., c1 => 2.]
    # @test isequal(odesys.defaults, Dict(append!(u0, par)))
    @named odesys = ODESystem(MODEL1)
    isequal(nameof(odesys), :odesys)

    # Test ODEProblem
    oprob = ODEProblem(MODEL1, [0., 1.])
    sol = solve(oprob, Tsit5())
    println("soln")
    println(sol.u)
    println(typeof(sol.u))
    # @test isapprox(sol.u[end], [0.42857284277223784, 0.5714271572277619])
    # @named oprob = ODEProblem(MODEL1)
    # isequal(nameof(oprob), :oprob)

    # @test_nowarn ODEProblem(sbmlfile, [0., 1.])
    # @named oprob = ODEProblem(sbmlfile)
    # isequal(nameof(oprob), :oprob)








    # @test length(mdl.compartments) == 2

    # mets, rxns, S = getS(mdl)

    # @test typeof(S) <: AbstractMatrix{Float64}
    # @test typeof(getS(mdl; zeros = spzeros)[3]) <: SparseMatrixCSC{Float64}
    # @test typeof(getS(mdl; zeros = zeros)[3]) == Matrix{Float64}

    # @test length(mets) == 77
    # @test length(rxns) == 77
    # @test size(S) == (length(mets), length(rxns))

    # # totally arbitrary value tests
    # @test isapprox(sum(S), 42.1479)
    # @test mets[10:12] == ["M_akg_e", "M_fum_c", "M_pyr_c"]
    # @test rxns[10:12] == ["R_H2Ot", "R_PGL", "R_EX_glc_e_"]

    # lbs = getLBs(mdl)
    # ubs = getUBs(mdl)
    # ocs = getOCs(mdl)

    # @test length(ocs) == length(mets)
    # @test ocs[40] == 1.0
    # deleteat!(ocs, 40)
    # @test all(ocs .== 0.0)

    # @test length(getLBs(mdl)) == length(rxns)
    # @test length(getUBs(mdl)) == length(rxns)

    # getunit = (val, unit)::Tuple -> unit
    # @test all([broadcast(getunit, lbs) broadcast(getunit, ubs)] .== "mmol_per_gDW_per_hr")

    # getval = (val, unit)::Tuple -> val
    # lvals = broadcast(getval, lbs)
    # uvals = broadcast(getval, ubs)
    # @test isapprox(lvals[27], uvals[27])
    # @test isapprox(lvals[27], 7.6)
    # @test isapprox(lvals[12], -10)

    # @test count(isapprox.(lvals, -999999)) == 40
    # @test count(isapprox.(lvals, 0)) == 35
    # @test count(isapprox.(uvals, 999999)) == 76
end
