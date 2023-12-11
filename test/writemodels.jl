
function fix_constant!(model::SBML.Model)
    # We only write SBML L3v2. If a model is L2 or less, the `constant`
    # attributes may be missing (which is true for some models). We add the
    # main problematic ones (in speciesReferences) here, to make sure the
    # round trip has a chance to finish.
    _clean(sr::SBML.SpeciesReference) = SBML.SpeciesReference(
        species = sr.species,
        stoichiometry = sr.stoichiometry,
        constant = isnothing(sr.constant) ? true : sr.constant,
    )
    for (_, r) in model.reactions
        r.reactants .= map(_clean, r.reactants)
        r.products .= map(_clean, r.products)
    end
end

function remove_some_annotation_strings!(model::SBML.Model)
    gps = collect(keys(model.gene_products))
    for gp in gps
        g = model.gene_products[gp]
        if isempty(g.cv_terms)
            # prevent comparison trouble (empty cvterms create empty annotation
            # instead of "empty XML" annotation frame)
            continue
        end
        model.gene_products[gp] = SBML.GeneProduct(
            label = g.label,
            name = g.name,
            metaid = g.metaid,
            notes = g.notes,
            #no annotation here
            sbo = g.sbo,
            cv_terms = g.cv_terms,
        )
    end
end

@testset "writeSBML" begin
    @testset "Model Dasgupta2020.xml writes out as expected" begin
        model = readSBML(joinpath(@__DIR__, "data", "Dasgupta2020.xml"))
        fix_constant!(model)
        # uncomment the following line to re-create reference XML
        #writeSBML(model, joinpath(@__DIR__, "data", "Dasgupta2020-debug.xml"))
        expected = read(joinpath(@__DIR__, "data", "Dasgupta2020-written.xml"), String)
        # Remove carriage returns, if any
        expected = replace(expected, '\r' => "")
        @test @test_logs(writeSBML(model)) == expected
        mktemp() do filename, _
            @test_logs(writeSBML(model, filename))
            content = read(filename, String)
            # Remove carriage returns, if any
            content = replace(content, '\r' => "")
            @test content == expected
        end
    end

    # Make sure that the model we read from the written out file is consistent
    # with the original model.
    @testset "Round-trip: $(basename(file))" for file in first.(sbmlfiles)
        model = readSBML(file)
        fix_constant!(model)
        remove_some_annotation_strings!(model)
        # This is useful for debugging:
        # writeSBML(model, file*"-debug.xml")
        round_trip_model = readSBMLFromString(@test_logs(writeSBML(model)))

        # re-read the unmodified model, fix constantness and compare again
        model = readSBML(file)
        fix_constant!(model)
        @test model == round_trip_model
    end
end
