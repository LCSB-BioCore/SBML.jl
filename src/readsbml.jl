"""
    get_string(x::VPtr, fn_sym)::Maybe{String}

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
    get_optional_string(x::VPtr, fn_sym)::Maybe{String}

Like [`get_string`](@ref), but returns `nothing` instead of throwing an
exception.

This is used to get notes and annotations and several other things (see
`get_notes`, `get_annotations`)
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
    get_optional_bool(x::VPtr, is_sym, get_sym)::Maybe{Bool}

Helper for getting out boolean flags.
"""
function get_optional_bool(x::VPtr, is_sym, get_sym)::Maybe{Bool}
    if ccall(sbml(is_sym), Cint, (VPtr,), x) != 0
        return ccall(sbml(get_sym), Cint, (VPtr,), x) != 0
    else
        return nothing
    end
end

"""
    get_optional_int(x::VPtr, is_sym, get_sym)::Maybe{UInt}

Helper for getting out unsigned integers.
"""
function get_optional_int(x::VPtr, is_sym, get_sym)::Maybe{Int}
    if ccall(sbml(is_sym), Cint, (VPtr,), x) != 0
        return ccall(sbml(get_sym), Cint, (VPtr,), x)
    else
        return nothing
    end
end

"""
    get_optional_double(x::VPtr, is_sym, get_sym)::Maybe{Float64}

Helper for getting out C doubles aka Float64s.
"""
function get_optional_double(x::VPtr, is_sym, get_sym)::Maybe{Float64}
    if ccall(sbml(is_sym), Cint, (VPtr,), x) != 0
        return ccall(sbml(get_sym), Cdouble, (VPtr,), x)
    else
        return nothing
    end
end

function _readSBML(
    symbol::Symbol,
    fn::String,
    sbml_conversion,
    report_severities,
)::SBML.Model
    doc = ccall(sbml(symbol), VPtr, (Cstring,), fn)
    try
        get_error_messages(
            doc,
            AssertionError("Opening SBML document has reported errors"),
            report_severities,
        )

        sbml_conversion(doc)

        if 0 == ccall(sbml(:SBMLDocument_isSetModel), Cint, (VPtr,), doc)
            throw(AssertionError("SBML document contains no model"))
        end

        model = ccall(sbml(:SBMLDocument_getModel), VPtr, (VPtr,), doc)

        return extract_model(model)
    finally
        ccall(sbml(:SBMLDocument_free), Nothing, (VPtr,), doc)
    end
end

"""
    readSBML(
        fn::String,
        sbml_conversion = document -> nothing;
        report_severities = ["Fatal", "Error"],
    )::SBML.Model

Read the SBML from a XML file in `fn` and return the contained `SBML.Model`.

The `sbml_conversion` is a function that does an in-place modification of the
single parameter, which is the C pointer to the loaded SBML document (C type
`SBMLDocument*`). Several functions for doing that are prepared, including
[`set_level_and_version`](@ref), [`libsbml_convert`](@ref), and
[`convert_simplify_math`](@ref).

`report_severities` switches on and off reporting of certain errors; see the
documentation of [`get_error_messages`](@ref) for details.

To read from a string instead of a file, use [`readSBMLFromString`](@ref).

# Example
```
m = readSBML("my_model.xml", doc -> begin
    set_level_and_version(3, 1)(doc)
    convert_simplify_math(doc)
end)
```
"""
readSBML(
    fn::String,
    sbml_conversion = document -> nothing;
    report_severities = ["Fatal", "Error"],
)::SBML.Model = _readSBML(:readSBML, fn, sbml_conversion, report_severities)

"""
    readSBML(
        str::String,
        sbml_conversion = document -> nothing;
        report_severities = ["Fatal", "Error"],
    )::SBML.Model

Read the SBML from the string `str` and return the contained `SBML.Model`.

For the other arguments see the docstring of [`readSBML`](@ref), which can be
used to read from a file instead of a string.
"""
readSBMLFromString(
    str::AbstractString,
    sbml_conversion = document -> nothing;
    report_severities = ["Fatal", "Error"],
)::SBML.Model =
    _readSBML(:readSBMLFromString, String(str), sbml_conversion, report_severities)

get_notes(x::VPtr)::Maybe{String} = get_optional_string(x, :SBase_getNotesString)
get_annotation(x::VPtr)::Maybe{String} = get_optional_string(x, :SBase_getAnnotationString)

"""
    function get_association(x::VPtr)::GeneProductAssociation

Convert a pointer to SBML `FbcAssociation_t` to the `GeneProductAssociation`
tree structure.
"""
function get_association(x::VPtr)::GeneProductAssociation
    # libsbml C API is currently missing functions to check this in a normal
    # way, so we use a bit of a hack.
    typecode = ccall(sbml(:SBase_getTypeCode), Cint, (VPtr,), x)
    if typecode == 808 # SBML_FBC_GENEPRODUCTREF
        return GPARef(get_string(x, :GeneProductRef_getGeneProduct))
    elseif typecode == 809 # SBML_FBC_AND
        return GPAAnd([
            get_association(
                ccall(sbml(:FbcAnd_getAssociation), VPtr, (VPtr, Cuint), x, i - 1),
            ) for i = 1:ccall(sbml(:FbcAnd_getNumAssociations), Cuint, (VPtr,), x)
        ])
    elseif typecode == 810 # SBML_FBC_OR
        return GPAOr([
            get_association(
                ccall(sbml(:FbcOr_getAssociation), VPtr, (VPtr, Cuint), x, i - 1),
            ) for i = 1:ccall(sbml(:FbcOr_getNumAssociations), Cuint, (VPtr,), x)
        ])
    else
        throw(ErrorException("Unsupported FbcAssociation type"))
    end
end

extract_parameter(p::VPtr)::Pair{String,Tuple{Float64,String}} =
    get_string(p, :Parameter_getId) => (
        ccall(sbml(:Parameter_getValue), Cdouble, (VPtr,), p),
        mayfirst(get_optional_string(p, :Parameter_getUnits), ""),
    )

""""
    function extract_model(mdl::VPtr)::SBML.Model

Take the `SBMLModel_t` pointer and extract all information required to make a
valid [`SBML.Model`](@ref) structure.
"""
function extract_model(mdl::VPtr)::SBML.Model
    # get the FBC plugin pointer (FbcModelPlugin_t)
    mdl_fbc = ccall(sbml(:SBase_getPlugin), VPtr, (VPtr, Cstring), mdl, "fbc")

    # get the parameters
    parameters = Dict{String,Tuple{Float64,String}}()
    for i = 1:ccall(sbml(:Model_getNumParameters), Cuint, (VPtr,), mdl)
        p = ccall(sbml(:Model_getParameter), VPtr, (VPtr, Cuint), mdl, i - 1)
        id, v = extract_parameter(p)
        parameters[id] = v
    end

    # parse out the unit definitions
    units = Dict{String,Vector{SBML.UnitPart}}()
    for i = 1:ccall(sbml(:Model_getNumUnitDefinitions), Cuint, (VPtr,), mdl)
        ud = ccall(sbml(:Model_getUnitDefinition), VPtr, (VPtr, Cuint), mdl, i - 1)
        id = get_string(ud, :UnitDefinition_getId)
        units[id] = [
            begin
                u = ccall(sbml(:UnitDefinition_getUnit), VPtr, (VPtr, Cuint), ud, j - 1)
                SBML.UnitPart(
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
    compartments = Dict{String,Compartment}()
    for i = 1:ccall(sbml(:Model_getNumCompartments), Cuint, (VPtr,), mdl)
        co = ccall(sbml(:Model_getCompartment), VPtr, (VPtr, Cuint), mdl, i - 1)

        compartments[get_string(co, :Compartment_getId)] = Compartment(
            get_optional_string(co, :Compartment_getName),
            get_optional_bool(co, :Compartment_isSetConstant, :Compartment_getConstant),
            get_optional_int(
                co,
                :Compartment_isSetSpatialDimensions,
                :Compartment_getSpatialDimensions,
            ),
            get_optional_double(co, :Compartment_isSetSize, :Compartment_getSize),
            get_optional_string(co, :Compartment_getUnits),
            get_notes(co),
            get_annotation(co),
        )
    end

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
                get_optional_string(sp, :Species_getSubstanceUnits),
            )
        end

        ic = nothing
        if ccall(sbml(:Species_isSetInitialConcentration), Cint, (VPtr,), sp) != 0
            ic = (
                ccall(sbml(:Species_getInitialConcentration), Cdouble, (VPtr,), sp),
                get_optional_string(sp, :Species_getSubstanceUnits),
            )
        end

        species[get_string(sp, :Species_getId)] = Species(
            get_optional_string(sp, :Species_getName),
            get_string(sp, :Species_getCompartment),
            get_optional_bool(
                sp,
                :Species_isSetBoundaryCondition,
                :Species_getBoundaryCondition,
            ),
            formula,
            charge,
            ia,
            ic,
            get_optional_bool(
                sp,
                :Species_isSetHasOnlySubstanceUnits,
                :Species_getHasOnlySubstanceUnits,
            ),
            get_notes(sp),
            get_annotation(sp),
        )
    end

    # parse out the flux objectives (these are complementary to the objectives
    # that appear in the reactions, see comments lower)
    objective = Dict{String,Float64}()
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
                objective[get_string(fo, :FluxObjective_getReaction)] =
                    ccall(sbml(:FluxObjective_getCoefficient), Cdouble, (VPtr,), fo)
            end
        end
    end

    # reactions!
    reactions = Dict{String,Reaction}()
    for i = 1:ccall(sbml(:Model_getNumReactions), Cuint, (VPtr,), mdl)
        re = ccall(sbml(:Model_getReaction), VPtr, (VPtr, Cuint), mdl, i - 1)
        kinetic_parameters = Dict{String,Tuple{Float64,String}}()
        lower_bound = nothing
        upper_bound = nothing
        math = nothing

        # kinetic laws store a second version of the bounds and objectives
        kl = ccall(sbml(:Reaction_getKineticLaw), VPtr, (VPtr,), re)
        if kl != C_NULL
            for j = 1:ccall(sbml(:KineticLaw_getNumParameters), Cuint, (VPtr,), kl)
                p = ccall(sbml(:KineticLaw_getParameter), VPtr, (VPtr, Cuint), kl, j - 1)
                id, v = extract_parameter(p)
                parameters[id] = v
                kinetic_parameters[id] = v
            end

            if ccall(sbml(:KineticLaw_isSetMath), Cint, (VPtr,), kl) != 0
                math = parse_math(ccall(sbml(:KineticLaw_getMath), VPtr, (VPtr,), kl))
            end
        end

        re_fbc = ccall(sbml(:SBase_getPlugin), VPtr, (VPtr, Cstring), re, "fbc")
        if re_fbc != C_NULL
            lower_bound = get_optional_string(re_fbc, :FbcReactionPlugin_getLowerFluxBound)
            upper_bound = get_optional_string(re_fbc, :FbcReactionPlugin_getUpperFluxBound)
        end

        # extract stoichiometry
        reactants = Dict{String,Float64}()
        products = Dict{String,Float64}()

        add_stoi(sr, coll) = begin
            s = get_string(sr, :SpeciesReference_getSpecies)
            coll[s] =
                ccall(sbml(:SpeciesReference_getStoichiometry), Cdouble, (VPtr,), sr)
        end

        for j = 1:ccall(sbml(:Reaction_getNumReactants), Cuint, (VPtr,), re)
            sr = ccall(sbml(:Reaction_getReactant), VPtr, (VPtr, Cuint), re, j - 1)
            add_stoi(sr, reactants)
        end

        for j = 1:ccall(sbml(:Reaction_getNumProducts), Cuint, (VPtr,), re)
            sr = ccall(sbml(:Reaction_getProduct), VPtr, (VPtr, Cuint), re, j - 1)
            add_stoi(sr, products)
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
                association = get_association(a)
            end
        end

        # explicit reversible flag (defaults to true in SBML)
        reversible = Bool(ccall(sbml(:Reaction_getReversible), Cint, (VPtr,), re))

        reid = get_string(re, :Reaction_getId)
        reactions[reid] = Reaction(
            reactants,
            products,
            kinetic_parameters,
            lower_bound,
            upper_bound,
            association,
            math,
            reversible,
            get_notes(re),
            get_annotation(re),
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
                    get_notes(gp),
                    get_annotation(gp),
                )
            end
        end
    end

    function_definitions = Dict{String,FunctionDefinition}()
    for i = 1:ccall(sbml(:Model_getNumFunctionDefinitions), Cuint, (VPtr,), mdl)
        fd = ccall(sbml(:Model_getFunctionDefinition), VPtr, (VPtr, Cuint), mdl, i - 1)
        def = nothing
        if ccall(sbml(:FunctionDefinition_isSetMath), Cint, (VPtr,), fd) != 0
            def = parse_math(ccall(sbml(:FunctionDefinition_getMath), VPtr, (VPtr,), fd))
        end

        function_definitions[get_string(fd, :FunctionDefinition_getId)] =
            FunctionDefinition(
                get_optional_string(fd, :FunctionDefinition_getName),
                def,
                get_notes(fd),
                get_annotation(fd),
            )
    end

    initial_assignments = Dict{String,Math}()
    num_ias = ccall(sbml(:Model_getNumInitialAssignments), Cuint, (VPtr,), mdl)
    for n in 0:(num_ias - 1)
        ia = ccall(sbml(:Model_getInitialAssignment), VPtr, (VPtr, Cuint), mdl, n)
        sym = ccall(sbml(:InitialAssignment_getSymbol), Cstring, (VPtr,), ia)
        math_ptr = ccall(sbml(:InitialAssignment_getMath), VPtr, (VPtr,), ia)
        if math_ptr != C_NULL
            initial_assignments[unsafe_string(sym)] = parse_math(math_ptr)
        end
    end

    # events
    events = Dict{String,Event}()
    num_events = ccall(sbml(:Model_getNumEvents), Cuint, (VPtr,), mdl)
    for n = 0:(num_events-1)
        ev = ccall(sbml(:Model_getEvent), VPtr, (VPtr, Cuint), mdl, n)
        sym = ccall(sbml(:Event_getId), Cstring, (VPtr,), ev)
        trig = ccall(sbml(:Event_getTrigger), VPtr, (VPtr,), ev)
        trig_math_ptr = ccall(sbml(:Trigger_getMath), VPtr, (VPtr,), trig)
        if trig_math_ptr != C_NULL
            trig_math = parse_math(trig_math_ptr)
        end
    
        event_assignments = []
        num_event_assignments = ccall(sbml(:Event_getNumEventAssignments), Cuint, (VPtr,), ev)
        for j = 0:(num_event_assignments-1)
            eva = ccall(sbml(:Event_getEventAssignment), VPtr, (VPtr, Cuint), ev, j)
            eva_var = ccall(sbml(:EventAssignment_getVariable), Cstring, (VPtr,), eva)
            eva_math_ptr = ccall(sbml(:EventAssignment_getMath), VPtr, (VPtr,), eva)
            if eva_math_ptr != C_NULL
                eva_trig_math = parse_math(eva_math_ptr)
            end
            event_assignment = EventAssignment(unsafe_string(eva_var), eva_trig_math)
            push!(event_assignments, event_assignment)
        end
        evname = unsafe_string(sym)
        events[evname] = SBML.Event(evname, trig_math, event_assignments)
    end


    return Model(
        parameters,
        units,
        compartments,
        species,
        initial_assignments,
        reactions,
        objective,
        gene_products,
        function_definitions,
        events,
        get_notes(mdl),
        get_annotation(mdl),
    )
end
