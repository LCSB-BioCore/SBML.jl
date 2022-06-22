"""
$(TYPEDSIGNATURES)

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
$(TYPEDSIGNATURES)

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
$(TYPEDSIGNATURES)

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
$(TYPEDSIGNATURES)

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
$(TYPEDSIGNATURES)

Helper for getting out C doubles aka Float64s.
"""
function get_optional_double(x::VPtr, is_sym, get_sym)::Maybe{Float64}
    if ccall(sbml(is_sym), Cint, (VPtr,), x) != 0
        return ccall(sbml(get_sym), Cdouble, (VPtr,), x)
    else
        return nothing
    end
end

function get_string_from_xmlnode(xmlnode::VPtr)::String
    if ccall(sbml(:XMLNode_isText), Bool, (VPtr,), xmlnode)
        str_ptr = ccall(sbml(:XMLNode_getCharacters), Cstring, (VPtr,), xmlnode)
        str_ptr == C_NULL ? "" : unsafe_string(str_ptr)
    else
        children_num = ccall(sbml(:XMLNode_getNumChildren), Cuint, (VPtr,), xmlnode)
        join(
            (
                get_string_from_xmlnode(
                    ccall(sbml(:XMLNode_getChild), VPtr, (VPtr, Cint), xmlnode, n),
                ) for n = 0:(children_num-1)
            ),
            "\n",
        )
    end
end

"""
$(TYPEDSIGNATURES)

Internal helper for [`readSBML`](@ref).
"""
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

        return get_model(model)
    finally
        ccall(sbml(:SBMLDocument_free), Nothing, (VPtr,), doc)
    end
end

"""
$(TYPEDSIGNATURES)

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
function readSBML(
    fn::String,
    sbml_conversion = document -> nothing;
    report_severities = ["Fatal", "Error"],
)::SBML.Model
    isfile(fn) || throw(AssertionError("$(fn) is not a file"))
    _readSBML(:readSBML, fn, sbml_conversion, report_severities)
end

"""
$(TYPEDSIGNATURES)

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
$(TYPEDSIGNATURES)

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

"""
$(TYPEDSIGNATURES)

Extract the value of SBML `Parameter_t`.
"""
get_parameter(p::VPtr)::Pair{String,Parameter} =
    get_string(p, :Parameter_getId) => Parameter(
        name = get_optional_string(p, :Parameter_getName),
        value = ccall(sbml(:Parameter_getValue), Cdouble, (VPtr,), p),
        units = get_optional_string(p, :Parameter_getUnits),
        constant = get_optional_bool(p, :Parameter_isSetConstant, :Parameter_getConstant),
    )

"""
$(TYPEDSIGNATURES)

Take the `SBMLModel_t` pointer and extract all information required to make a
valid [`SBML.Model`](@ref) structure.
"""
function get_model(mdl::VPtr)::SBML.Model
    # get the FBC plugin pointer (FbcModelPlugin_t)
    mdl_fbc = ccall(sbml(:SBase_getPlugin), VPtr, (VPtr, Cstring), mdl, "fbc")

    # get the parameters
    parameters = Dict{String,Parameter}()
    for i = 1:ccall(sbml(:Model_getNumParameters), Cuint, (VPtr,), mdl)
        p = ccall(sbml(:Model_getParameter), VPtr, (VPtr, Cuint), mdl, i - 1)
        id, v = get_parameter(p)
        parameters[id] = v
    end

    # parse out the unit definitions
    units = Dict{String,UnitDefinition}()
    for i = 1:ccall(sbml(:Model_getNumUnitDefinitions), Cuint, (VPtr,), mdl)
        ud = ccall(sbml(:Model_getUnitDefinition), VPtr, (VPtr, Cuint), mdl, i - 1)
        id = get_string(ud, :UnitDefinition_getId)
        name = get_optional_string(ud, :UnitDefinition_getName)
        unit_parts = [
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
        units[id] = UnitDefinition(; name, unit_parts)
    end

    # parse out compartment names
    compartments = Dict{String,Compartment}()
    for i = 1:ccall(sbml(:Model_getNumCompartments), Cuint, (VPtr,), mdl)
        co = ccall(sbml(:Model_getCompartment), VPtr, (VPtr, Cuint), mdl, i - 1)

        compartments[get_string(co, :Compartment_getId)] = Compartment(
            name = get_optional_string(co, :Compartment_getName),
            constant = get_optional_bool(
                co,
                :Compartment_isSetConstant,
                :Compartment_getConstant,
            ),
            spatial_dimensions = get_optional_int(
                co,
                :Compartment_isSetSpatialDimensions,
                :Compartment_getSpatialDimensions,
            ),
            size = get_optional_double(co, :Compartment_isSetSize, :Compartment_getSize),
            units = get_optional_string(co, :Compartment_getUnits),
            notes = get_notes(co),
            annotation = get_annotation(co),
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

        species[get_string(sp, :Species_getId)] = Species(;
            name = get_optional_string(sp, :Species_getName),
            compartment = get_string(sp, :Species_getCompartment),
            boundary_condition = get_optional_bool(
                sp,
                :Species_isSetBoundaryCondition,
                :Species_getBoundaryCondition,
            ),
            formula,
            charge,
            initial_amount = if (
                ccall(sbml(:Species_isSetInitialAmount), Cint, (VPtr,), sp) != 0
            )
                ccall(sbml(:Species_getInitialAmount), Cdouble, (VPtr,), sp)
            end,
            initial_concentration = if (
                ccall(sbml(:Species_isSetInitialConcentration), Cint, (VPtr,), sp) != 0
            )
                ccall(sbml(:Species_getInitialConcentration), Cdouble, (VPtr,), sp)
            end,
            substance_units = get_optional_string(sp, :Species_getSubstanceUnits),
            only_substance_units = get_optional_bool(
                sp,
                :Species_isSetHasOnlySubstanceUnits,
                :Species_getHasOnlySubstanceUnits,
            ),
            constant = get_optional_bool(sp, :Species_isSetConstant, :Species_getConstant),
            metaid = get_optional_string(sp, :SBase_getMetaId),
            notes = get_notes(sp),
            annotation = get_annotation(sp),
        )
    end

    # parse out the flux objectives (these are complementary to the objectives
    # that appear in the reactions, see comments lower)
    objectives = Dict{String,Objective}()
    active_objective = ""
    if mdl_fbc != C_NULL
        for i = 1:ccall(sbml(:FbcModelPlugin_getNumObjectives), Cuint, (VPtr,), mdl_fbc)
            flux_objectives = Dict{String,Float64}()
            o = ccall(
                sbml(:FbcModelPlugin_getObjective),
                VPtr,
                (VPtr, Cuint),
                mdl_fbc,
                i - 1,
            )
            type = get_string(o, :Objective_getType)
            for j = 1:ccall(sbml(:Objective_getNumFluxObjectives), Cuint, (VPtr,), o)
                fo = ccall(sbml(:Objective_getFluxObjective), VPtr, (VPtr, Cuint), o, j - 1)
                flux_objectives[get_string(fo, :FluxObjective_getReaction)] =
                    ccall(sbml(:FluxObjective_getCoefficient), Cdouble, (VPtr,), fo)
            end
            objectives[get_string(o, :Objective_getId)] = Objective(type, flux_objectives)
        end
        active_objective = get_string(mdl_fbc, :FbcModelPlugin_getActiveObjectiveId)
    end

    # reactions!
    reactions = Dict{String,Reaction}()
    for i = 1:ccall(sbml(:Model_getNumReactions), Cuint, (VPtr,), mdl)
        re = ccall(sbml(:Model_getReaction), VPtr, (VPtr, Cuint), mdl, i - 1)
        kinetic_parameters = Dict{String,Parameter}()
        lower_bound = nothing
        upper_bound = nothing
        math = nothing

        # kinetic laws store a second version of the bounds and objectives
        kl = ccall(sbml(:Reaction_getKineticLaw), VPtr, (VPtr,), re)
        if kl != C_NULL
            for j = 1:ccall(sbml(:KineticLaw_getNumParameters), Cuint, (VPtr,), kl)
                p = ccall(sbml(:KineticLaw_getParameter), VPtr, (VPtr, Cuint), kl, j - 1)
                id, v = get_parameter(p)
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
        reactions[reid] = Reaction(;
            name = get_optional_string(re, :Reaction_getName),
            reactants,
            products,
            kinetic_parameters,
            lower_bound,
            upper_bound,
            gene_product_association = association,
            kinetic_math = math,
            reversible,
            notes = get_notes(re),
            annotation = get_annotation(re),
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
                    label = get_string(gp, :GeneProduct_getLabel),
                    name = get_optional_string(gp, :GeneProduct_getName),
                    metaid = get_optional_string(gp, :SBase_getMetaId),
                    notes = get_notes(gp),
                    annotation = get_annotation(gp),
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
                name = get_optional_string(fd, :FunctionDefinition_getName),
                body = def,
                notes = get_notes(fd),
                annotation = get_annotation(fd),
            )
    end

    initial_assignments = Dict{String,Math}()
    num_ias = ccall(sbml(:Model_getNumInitialAssignments), Cuint, (VPtr,), mdl)
    for n = 0:(num_ias-1)
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

        event_assignments = EventAssignment[]
        for j = 0:(ccall(sbml(:Event_getNumEventAssignments), Cuint, (VPtr,), ev)-1)
            eva = ccall(sbml(:Event_getEventAssignment), VPtr, (VPtr, Cuint), ev, j)
            eva_math_ptr = ccall(sbml(:EventAssignment_getMath), VPtr, (VPtr,), eva)
            push!(
                event_assignments,
                EventAssignment(
                    variable = unsafe_string(
                        ccall(sbml(:EventAssignment_getVariable), Cstring, (VPtr,), eva),
                    ),
                    math = eva_math_ptr == C_NULL ? nothing : parse_math(eva_math_ptr),
                ),
            )
        end

        trigger_ptr = ccall(sbml(:Event_getTrigger), VPtr, (VPtr,), ev)
        trig_math_ptr = ccall(sbml(:Trigger_getMath), VPtr, (VPtr,), trigger_ptr)
        trigger = Trigger(;
            persistent = ccall(sbml(:Trigger_getPersistent), Bool, (VPtr,), trigger_ptr),
            initial_value = ccall(
                sbml(:Trigger_getInitialValue),
                Bool,
                (VPtr,),
                trigger_ptr,
            ),
            math = trig_math_ptr == C_NULL ? nothing : parse_math(trig_math_ptr),
        )

        events[unsafe_string(ccall(sbml(:Event_getId), Cstring, (VPtr,), ev))] =
            SBML.Event(;
                use_values_from_trigger_time = ccall(
                    sbml(:Event_getUseValuesFromTriggerTime),
                    Cint,
                    (VPtr,),
                    ev,
                ),
                name = get_optional_string(ev, :Event_getName),
                trigger,
                event_assignments,
            )
    end

    # Rules
    rules = Rule[]
    num_rules = ccall(sbml(:Model_getNumRules), Cuint, (VPtr,), mdl)
    for n = 0:(num_rules-1)
        rule_ptr = ccall(sbml(:Model_getRule), VPtr, (VPtr, Cuint), mdl, n)
        type = if ccall(sbml(:Rule_isAlgebraic), Bool, (VPtr,), rule_ptr)
            AlgebraicRule
        elseif ccall(sbml(:Rule_isAssignment), Bool, (VPtr,), rule_ptr)
            AssignmentRule
        elseif ccall(sbml(:Rule_isRate), Bool, (VPtr,), rule_ptr)
            RateRule
        end
        if type in (AssignmentRule, RateRule)
            var = ccall(sbml(:Rule_getVariable), Cstring, (VPtr,), rule_ptr)
        end
        math_ptr = ccall(sbml(:Rule_getMath), VPtr, (VPtr,), rule_ptr)
        if math_ptr != C_NULL
            math = parse_math(math_ptr)
            rule = if type in (AssignmentRule, RateRule)
                type(unsafe_string(var), math)
            else
                type(math)
            end
            push!(rules, rule)
        end
    end

    # Constraints
    constraints = Constraint[]
    num_constraints = ccall(sbml(:Model_getNumConstraints), Cuint, (VPtr,), mdl)
    for n = 0:(num_constraints-1)
        constraint_ptr = ccall(sbml(:Model_getConstraint), VPtr, (VPtr, Cuint), mdl, n)
        xml_ptr = ccall(sbml(:Constraint_getMessage), VPtr, (VPtr,), constraint_ptr)
        message = get_string_from_xmlnode(xml_ptr)
        math_ptr = ccall(sbml(:Constraint_getMath), VPtr, (VPtr,), constraint_ptr)
        if math_ptr != C_NULL
            math = parse_math(math_ptr)
            constraint = Constraint(math, message)
            push!(constraints, constraint)
        end
    end

    return Model(;
        parameters,
        units,
        compartments,
        species,
        initial_assignments,
        rules,
        constraints,
        reactions,
        objectives,
        active_objective,
        gene_products,
        function_definitions,
        events,
        name = get_optional_string(mdl, :Model_getName),
        id = get_optional_string(mdl, :Model_getId),
        metaid = get_optional_string(mdl, :SBase_getMetaId),
        conversion_factor = get_optional_string(mdl, :Model_getConversionFactor),
        area_units = get_optional_string(mdl, :Model_getAreaUnits),
        extent_units = get_optional_string(mdl, :Model_getExtentUnits),
        length_units = get_optional_string(mdl, :Model_getLengthUnits),
        substance_units = get_optional_string(mdl, :Model_getSubstanceUnits),
        time_units = get_optional_string(mdl, :Model_getTimeUnits),
        volume_units = get_optional_string(mdl, :Model_getVolumeUnits),
        notes = get_notes(mdl),
        annotation = get_annotation(mdl),
    )
end
