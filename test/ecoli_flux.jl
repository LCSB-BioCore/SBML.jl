
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

    @test_logs (:error, "SBML reported error: File unreadable.") @test_throws AssertionError readSBML(
        sbmlfile * ".does.not.really.exist",
    )

    @test length(mdl.compartments) == 2

    mets, rxns, S = getS(mdl)

    @test typeof(S) <: AbstractMatrix{Float64}
    @test typeof(getS(mdl; zeros = spzeros)[3]) <: SparseMatrixCSC{Float64}
    @test typeof(getS(mdl; zeros = zeros)[3]) == Matrix{Float64}

    @test length(mets) == 77
    @test length(rxns) == 77
    @test size(S) == (length(mets), length(rxns))

    # totally arbitrary value tests
    @test isapprox(sum(S), 42.1479)
    @test mets[10:12] == ["M_akg_e", "M_fum_c", "M_pyr_c"]
    @test rxns[10:12] == ["R_H2Ot", "R_PGL", "R_EX_glc_e_"]

    lbs = getLBs(mdl)
    ubs = getUBs(mdl)
    ocs = getOCs(mdl)

    @test length(ocs) == length(mets)
    @test ocs[40] == 1.0
    deleteat!(ocs, 40)
    @test all(ocs .== 0.0)

    @test length(getLBs(mdl)) == length(rxns)
    @test length(getUBs(mdl)) == length(rxns)

    getunit = (val, unit)::Tuple -> unit
    @test all([broadcast(getunit, lbs) broadcast(getunit, ubs)] .== "mmol_per_gDW_per_hr")

    getval = (val, unit)::Tuple -> val
    lvals = broadcast(getval, lbs)
    uvals = broadcast(getval, ubs)
    @test isapprox(lvals[27], uvals[27])
    @test isapprox(lvals[27], 7.6)
    @test isapprox(lvals[12], -10)

    @test count(isapprox.(lvals, -999999)) == 40
    @test count(isapprox.(lvals, 0)) == 35
    @test count(isapprox.(uvals, 999999)) == 76
end
