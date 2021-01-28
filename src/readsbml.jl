
const VPtr = Ptr{Cvoid}

"""
    function readSBML(fn::String)::Model

Read the SBML from a XML file in `fn` and return the contained `Model`.
"""
function readSBML(fn::String)::Model
    doc = ccall(sbml(:readSBML), VPtr, (Cstring,), fn)
    try
        n_errs = ccall(sbml(:SBMLDocument_getNumErrors), Cuint, (VPtr,), doc)
        if n_errs > 0
            @error "SBML loading failed"
            throw(:IOError)
        end

        if 0 == ccall(sbml(:SBMLDocument_isSetModel), Cint, (VPtr,), doc)
            @error "SBML document does not contain a model"
            throw(:ValueError)
        end

        model = ccall(sbml(:SBMLDocument_getModel), VPtr, (VPtr,), doc)

        return extractModel(model)
    finally
        ccall(sbml(:SBMLDocument_free), Nothing, (VPtr,), doc)
    end
end

function extractModel(mdl::VPtr)::Model
    units = Dict{String,Vector{UnitPart}}()
    for i = 0:ccall(sbml(:Model_getNumUnitDefinitions), Cuint, (VPtr,), mdl)-1
        ud = ccall(sbml(:Model_getUnitDefinition), VPtr, (VPtr, Cuint), mdl, i)
        id = unsafe_string(ccall(sbml(:UnitDefinition_getId), Cstring, (VPtr,), ud))
        units[id] = [
            begin
                u = ccall(sbml(:UnitDefinition_getUnit), VPtr, (VPtr, Cuint), ud, j)
                UnitPart(
                    unsafe_string(
                        ccall(
                            sbml(:UnitKind_toString),
                            Cstring,
                            (Cint,),
                            ccall(sbml(:Unit_getKind), Cint, (VPtr,), u),
                        ),
                    ),
                    ccall(sbml(:Unit_getExponent), Cint, (VPtr,), u),
                    ccall(sbml(:Unit_getScale), Cint, (VPtr,), u),
                    ccall(sbml(:Unit_getMultiplier), Cdouble, (VPtr,), u),
                )
            end for j = 0:ccall(sbml(:UnitDefinition_getNumUnits), Cuint, (VPtr,), ud)-1
        ]
    end

    compartments = [
        unsafe_string(
            ccall(
                sbml(:Compartment_getId),
                Cstring,
                (VPtr,),
                ccall(sbml(:Model_getCompartment), VPtr, (VPtr, Cuint), mdl, i),
            ),
        ) for i = 0:ccall(sbml(:Model_getNumCompartments), Cuint, (VPtr,), mdl)-1
    ]

    species = Dict{String,Species}()
    for i = 0:ccall(sbml(:Model_getNumSpecies), Cuint, (VPtr,), mdl)-1
        sp = ccall(sbml(:Model_getSpecies), VPtr, (VPtr, Cuint), mdl, i)
        species[unsafe_string(ccall(sbml(:Species_getId), Cstring, (VPtr,), sp))] = Species(
            unsafe_string(ccall(sbml(:Species_getName), Cstring, (VPtr,), sp)),
            unsafe_string(ccall(sbml(:Species_getCompartment), Cstring, (VPtr,), sp)),
        )
    end

    reactions = Dict{String,Reaction}()
    for i = 0:ccall(sbml(:Model_getNumReactions), Cuint, (VPtr,), mdl)-1
        re = ccall(sbml(:Model_getReaction), VPtr, (VPtr, Cuint), mdl, i)
        kl = ccall(sbml(:Reaction_getKineticLaw), VPtr, (VPtr,), re)
        lb = (-Inf, "")
        ub = (Inf, "")
        oc = 0.0
        for j = 0:ccall(sbml(:KineticLaw_getNumParameters), Cuint, (VPtr,), kl)-1
            p = ccall(sbml(:KineticLaw_getParameter), VPtr, (VPtr, Cuint), kl, j)
            id = unsafe_string(ccall(sbml(:Parameter_getId), Cstring, (VPtr,), p))
            pval = () -> ccall(sbml(:Parameter_getValue), Cdouble, (VPtr,), p)
            punit =
                () -> unsafe_string(ccall(sbml(:Parameter_getUnits), Cstring, (VPtr,), p))
            if id == "LOWER_BOUND"
                lb = (pval(), punit())
            elseif id == "UPPER_BOUND"
                ub = (pval(), punit())
            elseif id == "OBJECTIVE_COEFFICIENT"
                oc = pval()
            end
        end

        stoi = Dict{String,Float64}()
        add_stoi =
            (sr, factor) ->
                stoi[unsafe_string(
                    ccall(sbml(:SpeciesReference_getSpecies), Cstring, (VPtr,), sr),
                )] =
                    ccall(sbml(:SpeciesReference_getStoichiometry), Cdouble, (VPtr,), sr) *
                    factor

        for j = 0:ccall(sbml(:Reaction_getNumReactants), Cuint, (VPtr,), re)-1
            sr = ccall(sbml(:Reaction_getReactant), VPtr, (VPtr, Cuint), re, j)
            add_stoi(sr, -1)
        end

        for j = 0:ccall(sbml(:Reaction_getNumProducts), Cuint, (VPtr,), re)-1
            sr = ccall(sbml(:Reaction_getProduct), VPtr, (VPtr, Cuint), re, j)
            add_stoi(sr, 1)
        end

        reactions[unsafe_string(ccall(sbml(:Reaction_getId), Cstring, (VPtr,), re))] =
            Reaction(stoi, lb, ub, oc)
    end

    return Model(units, compartments, species, reactions)
end
