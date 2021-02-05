
sbmlfile = "EColi.xml"

if !isfile(sbmlfile)
    download("https://systemsbiology.ucsd.edu/sites/systemsbiology.ucsd.edu/files/Attachments/Images/InSilicoOrganisms/Ecoli/Ecoli_SBML/Ec_core_flux1.xml", sbmlfile)
end

@testset "SBML model loading" begin
    m = readSBML(sbmlfile)

    @test typeof(mdl) == Model
    
    @test_throws :IOError readSBML(sbmlfile * ".does.not.really.exist")

    @test length(mdl.compartments) == 2
    
    mets, rxns, S = getS(mdl)

end
