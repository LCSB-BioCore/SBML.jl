
sbmlfile = "e_coli_core.xml"

if !isfile(sbmlfile)
    download("http://bigg.ucsd.edu/static/models/e_coli_core.xml", sbmlfile)
end

cksum = bytes2hex(sha256(open(sbmlfile)))
if cksum != "b4db506aeed0e434c1f5f1fdd35feda0dfe5d82badcfda0e9d1342335ab31116"
    @warn "The downloaded E Coli core model seems to be different from the expected one. Tests will likely fail." cksum
end

@testset "SBML model-only file loading" begin
    mdl = readSBML(sbmlfile)

    @test typeof(mdl) == Model

    mets, rxns, _ = getS(mdl)

    @test length(mets) == 72
    @test length(rxns) == 95
end
