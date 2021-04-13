
const VPtr = Ptr{Cvoid}

"""
    function get_string(x::VPtr, fn_sym)::Maybe{String}

C-call the SBML function `fn_sym` with a single parameter `x`, interpret the
result as a string and return it, or throw exception in case the pointer is
NULL.
"""
function get_string(x::VPtr, fn_sym)::String
    str = ccall(sbml(fn_sym), Cstring, (VPtr,), x)
    if str != C_NULL
        return unsafe_string(str)
    else
        throw(DomainError(x, "Calling $fn_sym returned NULL, valid string expected."))
    end
end

"""
    function get_optional_string(x::VPtr, fn_sym)::Maybe{String}

Like [`get_string`](@Ref), but returns `nothing` instead of throwing an
exception.

This is used to get notes and annotations and several other things (see
`getNotes`, `getAnnotations`)
"""
function get_optional_string(x::VPtr, fn_sym)::Maybe{String}
    str = ccall(sbml(fn_sym), Cstring, (VPtr,), x)
    if str != C_NULL
        return unsafe_string(str)
    else
        return nothing
    end
end

"""
    function readSBML(fn::String)::Model

Read the SBML from a XML file in `fn` and return the contained `Model`.
"""
function readSBML(fn::String)::Model
    doc = ccall(sbml(:readSBML), VPtr, (Cstring,), fn)
    try
        n_errs = ccall(sbml(:SBMLDocument_getNumErrors), Cuint, (VPtr,), doc)
        for i = 0:n_errs-1
            err = ccall(sbml(:SBMLDocument_getError), VPtr, (VPtr, Cuint), doc, i)
            msg = get_string(err, :XMLError_getMessage)
            @warn "SBML reported error: $msg"
        end
        if n_errs > 0
            throw(AssertionError("Opening SBML document has reported errors"))
        end

        if 0 == ccall(sbml(:SBMLDocument_isSetModel), Cint, (VPtr,), doc)
            throw(AssertionError("SBML document contains no model"))
        end

        model = ccall(sbml(:SBMLDocument_getModel), VPtr, (VPtr,), doc)

        return extractModel(model)
    finally
        ccall(sbml(:SBMLDocument_free), Nothing, (VPtr,), doc)
    end
end

getNotes(x::VPtr)::Maybe{String} = get_optional_string(x, :SBase_getNotesString)
getAnnotation(x::VPtr)::Maybe{String} = get_optional_string(x, :SBase_getAnnotationString)

"""
    function getAssociation(x::VPtr)::GeneProductAssociation

Convert a pointer to SBML `FbcAssociation_t` to the `GeneProductAssociation`
tree structure.
"""
function getAssociation(x::VPtr)::GeneProductAssociation
    # libsbml C API is currently missing functions to check this in a normal
    # way, so we use a bit of a hack.
    typecode = ccall(sbml(:SBase_getTypeCode), Cint, (VPtr,), x)
    if typecode == 808 # SBML_FBC_GENEPRODUCTREF
        return GPARef(get_string(x, :GeneProductRef_getGeneProduct))
    elseif typecode == 809 # SBML_FBC_AND
        return GPAAnd([
            getAssociation(
                ccall(sbml(:FbcAnd_getAssociation), VPtr, (VPtr, Cuint), x, i - 1),
            ) for i = 1:ccall(sbml(:FbcAnd_getNumAssociations), Cuint, (VPtr,), x)
        ])
    elseif typecode == 810 # SBML_FBC_OR
        return GPAOr([
            getAssociation(
                ccall(sbml(:FbcOr_getAssociation), VPtr, (VPtr, Cuint), x, i - 1),
            ) for i = 1:ccall(sbml(:FbcOr_getNumAssociations), Cuint, (VPtr,), x)
        ])
    else
        throw(ErrorException("Unsupported FbcAssociation type"))
    end
end


""""
    function extractModel(mdl::VPtr)::Model

Take the `SBMLModel_t` pointer and extract all information required to make a
valid [`Model`](@ref) structure.
"""
function extractModel(mdl::VPtr)::Model
    # get the FBC plugin pointer (FbcModelPlugin_t)
    mdl_fbc = ccall(sbml(:SBase_getPlugin), VPtr, (VPtr, Cstring), mdl, "fbc")

    # get the parameters
    parameters = Dict{String,Float64}()
    for i = 1:ccall(sbml(:Model_getNumParameters), Cuint, (VPtr,), mdl)
        p = ccall(sbml(:Model_getParameter), VPtr, (VPtr, Cuint), mdl, i - 1)
        id = get_string(p, :Parameter_getId)
        v = ccall(sbml(:Parameter_getValue), Cdouble, (VPtr,), p)
        parameters[id] = v
    end

    # parse out the unit definitions
    units = Dict{String,Vector{UnitPart}}()
    for i = 1:ccall(sbml(:Model_getNumUnitDefinitions), Cuint, (VPtr,), mdl)
        ud = ccall(sbml(:Model_getUnitDefinition), VPtr, (VPtr, Cuint), mdl, i - 1)
        id = get_string(ud, :UnitDefinition_getId)
        units[id] = [
            begin
                u = ccall(sbml(:UnitDefinition_getUnit), VPtr, (VPtr, Cuint), ud, j - 1)
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
            end for j = 1:ccall(sbml(:UnitDefinition_getNumUnits), Cuint, (VPtr,), ud)
        ]
    end

    # parse out compartment names
    compartments = [
        get_string(
            ccall(sbml(:Model_getCompartment), VPtr, (VPtr, Cuint), mdl, i - 1),
            :Compartment_getId,
        ) for i = 1:ccall(sbml(:Model_getNumCompartments), Cuint, (VPtr,), mdl)
    ]

    # parse out species
    species = Dict{String,Species}()
    for i = 1:ccall(sbml(:Model_getNumSpecies), Cuint, (VPtr,), mdl)
        sp = ccall(sbml(:Model_getSpecies), VPtr, (VPtr, Cuint), mdl, i - 1)
        sp_fbc = ccall(sbml(:SBase_getPlugin), VPtr, (VPtr, Cstring), sp, "fbc") # FbcSpeciesPlugin_t

        formula = nothing
        charge = nothing
        if sp_fbc != C_NULL
            # if the FBC plugin is present, try to get the chemical formula and charge
            if 0 !=
               ccall(sbml(:FbcSpeciesPlugin_isSetChemicalFormula), Cint, (VPtr,), sp_fbc)
                formula = get_string(sp_fbc, :FbcSpeciesPlugin_getChemicalFormula)
            end
            if 0 != ccall(sbml(:FbcSpeciesPlugin_isSetCharge), Cint, (VPtr,), sp_fbc)
                charge = ccall(sbml(:FbcSpeciesPlugin_getCharge), Cint, (VPtr,), sp_fbc)
            end
        end

        ia = nothing
        if ccall(sbml(:Species_isSetInitialAmount), Cint, (VPtr,), sp) != 0
            ia = (
                ccall(sbml(:Species_getInitialAmount), Cdouble, (VPtr,), sp),
                get_string(sp, :Species_getSubstanceUnits),
            )
        end

        species[get_string(sp, :Species_getId)] = Species(
            get_optional_string(sp, :Species_getName),
            get_string(sp, :Species_getCompartment),
            formula,
            charge,
            ia,
            ccall(sbml(:Species_getHasOnlySubstanceUnits), Cint, (VPtr,), sp) != 0,
            getNotes(sp),
            getAnnotation(sp),
        )
    end

    # parse out the flux objectives (these are complementary to the objectives
    # that appear in the reactions, see comments lower)
    objectives_fbc = Dict{String,Float64}()
    if mdl_fbc != C_NULL
        for i = 1:ccall(sbml(:FbcModelPlugin_getNumObjectives), Cuint, (VPtr,), mdl_fbc)
            o = ccall(
                sbml(:FbcModelPlugin_getObjective),
                VPtr,
                (VPtr, Cuint),
                mdl_fbc,
                i - 1,
            )
            for j = 1:ccall(sbml(:Objective_getNumFluxObjectives), Cuint, (VPtr,), o)
                fo = ccall(sbml(:Objective_getFluxObjective), VPtr, (VPtr, Cuint), o, j - 1)
                objectives_fbc[get_string(fo, :FluxObjective_getReaction)] =
                    ccall(sbml(:FluxObjective_getCoefficient), Cdouble, (VPtr,), fo)
            end
        end
    end

    # reactions!
    reactions = Dict{String,Reaction}()
    for i = 1:ccall(sbml(:Model_getNumReactions), Cuint, (VPtr,), mdl)
        re = ccall(sbml(:Model_getReaction), VPtr, (VPtr, Cuint), mdl, i - 1)
        lb = (-Inf, "") # (bound value, unit id)
        ub = (Inf, "")
        oc = 0.0
        math = nothing

        # kinetic laws store a second version of the bounds and objectives
        kl = ccall(sbml(:Reaction_getKineticLaw), VPtr, (VPtr,), re)
        if kl != C_NULL
            for j = 1:ccall(sbml(:KineticLaw_getNumParameters), Cuint, (VPtr,), kl)
                p = ccall(sbml(:KineticLaw_getParameter), VPtr, (VPtr, Cuint), kl, j - 1)
                id = get_string(p, :Parameter_getId)
                pval = () -> ccall(sbml(:Parameter_getValue), Cdouble, (VPtr,), p)
                punit = () -> get_string(p, :Parameter_getUnits)
                if id == "LOWER_BOUND"
                    lb = (pval(), punit())
                elseif id == "UPPER_BOUND"
                    ub = (pval(), punit())
                elseif id == "OBJECTIVE_COEFFICIENT"
                    oc = pval()
                end
            end

            if ccall(sbml(:KineticLaw_isSetMath), Cint, (VPtr,), kl) != 0
                math = parseMath(ccall(sbml(:KineticLaw_getMath), VPtr, (VPtr,), kl))
            end
        end

        # TRICKY: SBML spec is completely silent about what should happen if
        # someone specifies both the above and below formats of the flux bounds
        # for one reaction. Notably, these do not really specify much
        # interaction with units. In this case, we'll just set a special
        # "[fbc]" unit that has no specification in `units`, and hope the users
        # can make something out of it.
        re_fbc = ccall(sbml(:SBase_getPlugin), VPtr, (VPtr, Cstring), re, "fbc")
        if re_fbc != C_NULL
            fbcb = get_optional_string(re_fbc, :FbcReactionPlugin_getLowerFluxBound)
            if !isnothing(fbcb) && haskey(parameters, fbcb)
                lb = (parameters[fbcb], "[fbc]")
            end
            fbcb = get_optional_string(re_fbc, :FbcReactionPlugin_getUpperFluxBound)
            if !isnothing(fbcb) && haskey(parameters, fbcb)
                ub = (parameters[fbcb], "[fbc]")
            end
        end

        # extract stoichiometry
        stoi = Dict{String,Float64}()
        add_stoi =
            (sr, factor) ->
                stoi[get_string(sr, :SpeciesReference_getSpecies)] =
                    ccall(sbml(:SpeciesReference_getStoichiometry), Cdouble, (VPtr,), sr) *
                    factor

        # reactants and products
        for j = 1:ccall(sbml(:Reaction_getNumReactants), Cuint, (VPtr,), re)
            sr = ccall(sbml(:Reaction_getReactant), VPtr, (VPtr, Cuint), re, j - 1)
            add_stoi(sr, -1)
        end

        for j = 1:ccall(sbml(:Reaction_getNumProducts), Cuint, (VPtr,), re)
            sr = ccall(sbml(:Reaction_getProduct), VPtr, (VPtr, Cuint), re, j - 1)
            add_stoi(sr, 1)
        end

        # gene product associations
        association = nothing
        if re_fbc != C_NULL
            gpa = ccall(
                sbml(:FbcReactionPlugin_getGeneProductAssociation),
                VPtr,
                (VPtr,),
                re_fbc,
            )
            if gpa != C_NULL
                a = ccall(sbml(:GeneProductAssociation_getAssociation), VPtr, (VPtr,), gpa)
                a != C_NULL
                association = getAssociation(a)
            end
        end

        reid = get_string(re, :Reaction_getId)
        reactions[reid] = Reaction(
            stoi,
            lb,
            ub,
            haskey(objectives_fbc, reid) ? objectives_fbc[reid] : oc,
            association,
            math,
            getNotes(re),
            getAnnotation(re),
        )
    end

    # extract gene products
    gene_products = Dict{String,GeneProduct}()
    if mdl_fbc != C_NULL
        for i = 1:ccall(sbml(:FbcModelPlugin_getNumGeneProducts), Cuint, (VPtr,), mdl_fbc)
            gp = ccall(
                sbml(:FbcModelPlugin_getGeneProduct),
                VPtr,
                (VPtr, Cuint),
                mdl_fbc,
                i - 1,
            )

            id = get_optional_string(gp, :GeneProduct_getId) # IDs don't need to be set

            if id != nothing
                gene_products[id] = GeneProduct(
                    get_optional_string(gp, :GeneProduct_getName),
                    get_optional_string(gp, :GeneProduct_getLabel),
                    getNotes(gp),
                    getAnnotation(gp),
                )
            end
        end
    end

    return Model(
        parameters,
        units,
        compartments,
        species,
        reactions,
        gene_products,
        getNotes(mdl),
        getAnnotation(mdl),
    )
end
