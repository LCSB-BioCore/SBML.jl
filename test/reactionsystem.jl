using ModelingToolkit

# sbmlfile = "reactionsystem_01.xml"

@parameters t, k1, c1
@variables s1, s2

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
    subs = SBML._get_substitutions(model)
    @test isequal(subs, truesubs)

    # Test get_u0
    true_u0map = [s1 => 1.]
    u0map = SBML.get_u0(model)
    @test isequal(true_u0map, u0map)



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
