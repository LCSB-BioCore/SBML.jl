
sbmlfile = joinpath(@__DIR__, "data", "Ec_core_flux1.xml")

if !isfile(sbmlfile)
    Downloads.download(
        "http://systemsbiology.ucsd.edu/sites/systemsbiology.ucsd.edu/files/Attachments/Images/InSilicoOrganisms/Ecoli/Ecoli_SBML/Ec_core_flux1.xml",
        sbmlfile,
    )
end

cksum = bytes2hex(sha256(open(sbmlfile)))
if cksum != "01a883b364fa60582101ca1e270515e7fcb3fb2f60084d92e5ee45f9f72bbe50"
    @warn "The downloaded E Coli core flux model seems to be different from the expected one. Tests will likely fail." cksum
end

@testset "SBML flux model loading" begin
    mdl = readSBML(sbmlfile)

    @test typeof(mdl) == Model

    @test_throws AssertionError readSBML(sbmlfile * ".does.not.really.exist")

    @test SBML.unitful(mdl.units["mmol_per_gDW_per_hr"]) ≈
          3.6001008028224795 * u"mol * g^-1 * s^-1"

    @test SBML.unitful(mdl, (2.0, "mmol_per_gDW_per_hr")) ≈
          7.200201605644959 * u"mol * g^-1 * s^-1"

    @test SBML.unitful(mdl, (3.0, "whatevs"), 1 * u"g") ≈ 3.0 * u"g"

    @test SBML.unitful(mdl, (3.0, "the_flux_units"), "mmol_per_gDW_per_hr") ≈
          10.800302408467438 * u"mol * g^-1 * s^-1"

    @test length(mdl.compartments) == 2

    mets, rxns, S = stoichiometry_matrix(mdl)

    @test typeof(S) <: SparseMatrixCSC{Float64}

    @test length(mets) == 77
    @test length(rxns) == 77
    @test size(S) == (length(mets), length(rxns))

    # totally arbitrary value tests
    @test isapprox(sum(S), 42.1479)
    @test sort(mets)[10:12] == ["M_actp_c", "M_adp_c", "M_akg_b"]
    @test sort(rxns)[10:12] == ["R_Biomass_Ecoli_core_N__w_GAM_", "R_CO2t", "R_CS"]

    lbs, ubs = flux_bounds(mdl)
    ocs = flux_objective(mdl)

    @test length(ocs) == length(mets)
    idx = indexin(Ref("R_Biomass_Ecoli_core_N__w_GAM_"), rxns)[1]
    @test ocs[idx] == 1.0
    deleteat!(ocs, idx)
    @test all(ocs .== 0.0)

    @test length(flux_bounds(mdl)[1]) == length(rxns)
    @test length(flux_bounds(mdl)[2]) == length(rxns)

    getunit((val, unit)) = unit
    @test all([broadcast(getunit, lbs) broadcast(getunit, ubs)] .== "mmol_per_gDW_per_hr")

    getval((val, unit)) = val
    lvals = broadcast(getval, lbs)
    uvals = broadcast(getval, ubs)
    idx = indexin(Ref("R_ATPM"), rxns)[1]
    @test isapprox(lvals[idx], uvals[idx])
    @test isapprox(lvals[idx], 7.6)
    idx = indexin(Ref("R_EX_glc_e_"), rxns)[1]
    @test isapprox(lvals[idx], -10)

    @test count(isapprox.(lvals, -999999)) == 40
    @test count(isapprox.(lvals, 0)) == 35
    @test count(isapprox.(uvals, 999999)) == 76
end
