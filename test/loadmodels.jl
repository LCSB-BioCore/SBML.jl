
sbmlfiles = [
    # a test model from BIGG
    (
        "e_coli_core.xml",
        "http://bigg.ucsd.edu/static/models/e_coli_core.xml",
        "b4db506aeed0e434c1f5f1fdd35feda0dfe5d82badcfda0e9d1342335ab31116",
        72,
        95,
    ),
    # a relatively new non-curated model from biomodels
    (
        "T1M1133.xml",
        "https://www.ebi.ac.uk/biomodels/model/download/MODEL1909260004.4?filename=T1M1133.xml",
        "2b1e615558b6190c649d71052ac9e0dc1635e3ad281e541bc7d4fdf2892a5967",
        2517,
        3956,
    ),
    # a curated model from biomodels
    (
        "Dasgupta2020.xml",
        "https://www.ebi.ac.uk/biomodels/model/download/BIOMD0000000973.3?filename=Dasgupta2020.xml",
        "958b131d4df2f215dae68255433542f228601db0326d26a54efd08ddcf823489",
        2,
        6,
    ),
]

@testset "Loading of models from various sources" begin
    for (sbmlfile, url, hash, expected_mets, expected_rxns) in sbmlfiles
        if !isfile(sbmlfile)
            Downloads.download(url, sbmlfile)
        end

        cksum = bytes2hex(sha256(open(sbmlfile)))
        if cksum != hash
            @warn "The downloaded model `$sbmlfile' seems to be different from the expected one. Tests will likely fail." cksum
        end

        @testset "Loading of $sbmlfile" begin
            mdl = readSBML(sbmlfile)

            @test typeof(mdl) == Model

            mets, rxns, _ = getS(mdl)

            @test length(mets) == expected_mets
            @test length(rxns) == expected_rxns
        end
    end
end
