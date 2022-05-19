function model_to_sbml!(doc::VPtr, mdl::Model)::VPtr
    # Create the model pinter
    model = ccall(sbml(:SBMLDocument_createModel), VPtr, (VPtr,), doc)

    # Add units
    for (name, units) in mdl.units
        res = ccall(sbml(:Model_addUnitDefinition), Cint, (VPtr, VPtr),
                    model, unit_definition(name, units))
        !iszero(res) && @warn "Failed to add unit \"$(name)\": $(OPERATION_RETURN_VALUES[res])"
    end

    # Add compartments
    for (id, compartment) in mdl.compartments
        compartment_t = ccall(sbml(:Compartment_create), VPtr, (Cuint, Cuint), 3, 2)
        ccall(sbml(:Compartment_setId), Cint, (VPtr, Cstring), compartment_t, id)
        isnothing(compartment.name) || ccall(sbml(:Compartment_setName), Cint, (VPtr, Cstring), compartment_t, compartment.name)
        isnothing(compartment.constant) || ccall(sbml(:Compartment_setConstant), Cint, (VPtr, Cint), compartment_t, Cint(compartment.constant))
        isnothing(compartment.spatial_dimensions) || ccall(sbml(:Compartment_setSpatialDimensions), Cint, (VPtr, Cuint), compartment_t, Cuint(compartment.spatial_dimensions))
        isnothing(compartment.size) || ccall(sbml(:Compartment_setSize), Cint, (VPtr, Cdouble), compartment_t, Cdouble(compartment.size))
        isnothing(compartment.units) || ccall(sbml(:Compartment_setUnits), Cint, (VPtr, Cstring), compartment_t, compartment.units)
        isnothing(compartment.notes) || ccall(sbml(:SBase_setNotesString), Cint, (VPtr, Cstring), compartment_t, compartment.notes)
        isnothing(compartment.annotation) || ccall(sbml(:SBase_setAnnotationString), Cint, (VPtr, Cstring), compartment_t, compartment.annotation)
        res = ccall(sbml(:Model_addCompartment), Cint, (VPtr, VPtr), model, compartment_t)
        !iszero(res) && @warn "Failed to add compartment \"$(id)\": $(OPERATION_RETURN_VALUES[res])"
    end

    # We can finally return the model
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
