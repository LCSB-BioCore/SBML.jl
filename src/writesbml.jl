function model_to_sbml!(doc::VPtr, mdl::Model)::VPtr
    model = ccall(sbml(:SBMLDocument_createModel), VPtr, (VPtr,), doc)
    for (name, units) in mdl.units
        res = ccall(sbml(:Model_addUnitDefinition), Cint, (VPtr, VPtr),
                    model, unit_definition(name, units))
        !iszero(res) && @warn "Failed to add unit \"$(name)\": $(OPERATION_RETURN_VALUES[res])"
    end
    return model
end

function writeSBML(mdl::Model, fn::String)
    doc = ccall(sbml(:SBMLDocument_createWithLevelAndVersion), VPtr, (Cuint, Cuint), 3, 2)
    model = try
        model_to_sbml!(doc, mdl)
        res = ccall(sbml(:writeSBML), Cint, (VPtr, Cstring), doc, fn)
        res == 1 || error("Writing the SBML failed")
    finally
        ccall(sbml(:SBMLDocument_free), Cvoid, (VPtr,), doc)
    end
    return nothing
end

function writeSBML(mdl::Model)::String
    doc = ccall(sbml(:SBMLDocument_createWithLevelAndVersion), VPtr, (Cuint, Cuint), 3, 2)
    str = try
        model_to_sbml!(doc, mdl)
        unsafe_string(ccall(sbml(:writeSBMLToString), Cstring, (VPtr,), doc))
    finally
        ccall(sbml(:SBMLDocument_free), Cvoid, (VPtr,), doc)
    end
    return str
end
