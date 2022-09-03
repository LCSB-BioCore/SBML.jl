# Level/Version for the document
const WRITESBML_DEFAULT_LEVEL = 3
const WRITESBML_DEFAULT_VERSION = 2
# Level/Version/Package version for the package
const WRITESBML_PKG_DEFAULT_LEVEL = 3
const WRITESBML_PKG_DEFAULT_VERSION = 1
const WRITESBML_PKG_DEFAULT_PKGVERSION = 2


function create_gene_product_association(
    gpr::GPARef,
    ptr::VPtr,
    ::Symbol,
    ::Symbol,
    add_ref::Symbol,
)
    ref_ptr = ccall(sbml(add_ref), VPtr, (VPtr,), ptr)
    set_string!(ref_ptr, :GeneProductRef_setGeneProduct, gpr.gene_product)
    return ref_ptr
end

function create_gene_product_association(
    gpr::GPAOr,
    ptr::VPtr,
    add_or::Symbol,
    ::Symbol,
    ::Symbol,
)
    or_ptr = ccall(sbml(add_or), VPtr, (VPtr,), ptr)
    for term in gpr.terms
        create_gene_product_association(
            term,
            or_ptr,
            :FbcOr_createOr,
            :FbcOr_createAnd,
            :FbcOr_createGeneProductRef,
        )
    end
    return or_ptr
end

function create_gene_product_association(
    gpr::GPAAnd,
    ptr::VPtr,
    ::Symbol,
    add_and::Symbol,
    ::Symbol,
)
    and_ptr = ccall(sbml(add_and), VPtr, (VPtr,), ptr)
    for term in gpr.terms
        create_gene_product_association(
            term,
            and_ptr,
            :FbcAnd_createOr,
            :FbcAnd_createAnd,
            :FbcAnd_createGeneProductRef,
        )
    end
    return and_ptr
end

function add_rule(model::VPtr, r::AlgebraicRule)
    algebraicrule_ptr = ccall(sbml(:Model_createAlgebraicRule), VPtr, (VPtr,), model)
    ccall(
        sbml(:AlgebraicRule_setMath),
        Cint,
        (VPtr, VPtr),
        algebraicrule_ptr,
        get_astnode_ptr(r.math),
    )
end

function add_rule(model::VPtr, r::Union{AssignmentRule,RateRule})
    rule_ptr = if r isa AssignmentRule
        ccall(sbml(:Model_createAssignmentRule), VPtr, (VPtr,), model)
    else
        ccall(sbml(:Model_createRateRule), VPtr, (VPtr,), model)
    end
    set_string!(rule_ptr, :Rule_setVariable, r.variable)
    ccall(sbml(:Rule_setMath), Cint, (VPtr, VPtr), rule_ptr, get_astnode_ptr(r.math))
end

function add_unit_definition(model::VPtr, id::String, units::UnitDefinition)
    unit_definition = ccall(sbml(:Model_createUnitDefinition), VPtr, (VPtr,), model)
    set_string!(unit_definition, :UnitDefinition_setId, id)
    set_string!(unit_definition, :UnitDefinition_setName, units.name)
    for unit in units.unit_parts
        unit_ptr = ccall(sbml(:UnitDefinition_createUnit), VPtr, (VPtr,), unit_definition)
        unit_kind = ccall(sbml(:UnitKind_forName), Cint, (Cstring,), unit.kind)
        set_int!(unit_ptr, :Unit_setKind, unit_kind)
        set_int!(unit_ptr, :Unit_setScale, unit.scale)
        set_int!(unit_ptr, :Unit_setExponent, unit.exponent)
        set_double!(unit_ptr, :Unit_setMultiplier, unit.multiplier)
    end
end

function set_parameter_ptr!(parameter_ptr::VPtr, id::String, parameter::Parameter)::VPtr
    set_string!(parameter_ptr, :Parameter_setId, id)
    set_string!(parameter_ptr, :Parameter_setName, parameter.name)
    set_double!(parameter_ptr, :Parameter_setValue, parameter.value)
    set_string!(parameter_ptr, :Parameter_setUnits, parameter.units)
    set_bool!(parameter_ptr, :Parameter_setConstant, parameter.constant)
    set_sbo_term!(parameter_ptr, parameter.sbo)
    return parameter_ptr
end

"""
$(TYPEDSIGNATURES)

Helper for setting string values.
"""
function set_string!(ptr::VPtr, fn_sym::Symbol, x::Maybe{String})
    isnothing(x) || ccall(sbml(fn_sym), Cint, (VPtr, Cstring), ptr, x)
end

"""
$(TYPEDSIGNATURES)

Helper for setting integer values.
"""
function set_int!(ptr::VPtr, fn_sym::Symbol, x::Maybe{I}) where {I<:Integer}
    isnothing(x) || ccall(sbml(fn_sym), Cint, (VPtr, Cint), ptr, x)
end

"""
$(TYPEDSIGNATURES)

Helper for setting unsigned integer values.
"""
function set_uint!(ptr::VPtr, fn_sym::Symbol, x::Maybe{I}) where {I<:Integer}
    isnothing(x) || ccall(sbml(fn_sym), Cint, (VPtr, Cuint), ptr, x)
end

"""
$(TYPEDSIGNATURES)

Helper for setting boolean values.
"""
function set_bool!(ptr::VPtr, fn_sym::Symbol, x::Maybe{Bool})
    isnothing(x) || ccall(sbml(fn_sym), Cint, (VPtr, Cint), ptr, x)
end

"""
$(TYPEDSIGNATURES)

Helper for setting double values.
"""
function set_double!(ptr::VPtr, fn_sym::Symbol, x::Maybe{Float64})
    isnothing(x) || ccall(sbml(fn_sym), Cint, (VPtr, Cdouble), ptr, x)
end

"""
$(TYPEDSIGNATURES)

Helper for writing SBO terms.
"""
set_sbo_term!(ptr, x) = set_string!(ptr, :SBase_setSBOTermID, x)

## Write the model

function model_to_sbml!(doc::VPtr, mdl::Model)::VPtr
    # Create the model pointer
    model = ccall(sbml(:SBMLDocument_createModel), VPtr, (VPtr,), doc)
    fbc_plugin = ccall(sbml(:SBase_getPlugin), VPtr, (VPtr, Cstring), model, "fbc")
    fbc_plugin == C_NULL ||
        isempty(mdl.gene_products) ||
        isempty(mdl.objectives) ||
        isempty(mdl.species) ||
        set_bool!(fbc_plugin, :FbcModelPlugin_setStrict, true)

    # Set ids and name
    set_string!(model, :Model_setId, mdl.id)
    set_string!(model, :SBase_setMetaId, mdl.metaid)
    set_string!(model, :Model_setName, mdl.name)

    # Add parameters
    for (id, parameter) in mdl.parameters
        parameter_ptr = ccall(sbml(:Model_createParameter), VPtr, (VPtr,), model)
        set_parameter_ptr!(parameter_ptr, id, parameter)
    end

    # Add units
    for (name, units) in mdl.units
        add_unit_definition(model, name, units)
    end

    # Add compartments
    for (id, compartment) in mdl.compartments
        compartment_ptr = ccall(sbml(:Model_createCompartment), VPtr, (VPtr,), model)
        set_string!(compartment_ptr, :Compartment_setId, id)
        set_string!(compartment_ptr, :Compartment_setName, compartment.name)
        set_bool!(compartment_ptr, :Compartment_setConstant, compartment.constant)
        set_uint!(
            compartment_ptr,
            :Compartment_setSpatialDimensions,
            UInt(compartment.spatial_dimensions),
        )
        set_double!(compartment_ptr, :Compartment_setSize, compartment.size)
        set_string!(compartment_ptr, :Compartment_setUnits, compartment.units)
        set_string!(compartment_ptr, :SBase_setNotesString, compartment.notes)
        set_string!(compartment_ptr, :SBase_setAnnotationString, compartment.annotation)
        set_sbo_term!(compartment_ptr, compartment.sbo)
    end

    # Add gene products
    fbc_plugin == C_NULL ||
        isempty(mdl.gene_products) ||
        set_bool!(fbc_plugin, :FbcModelPlugin_setStrict, true)
    for (id, gene_product) in mdl.gene_products
        geneproduct_ptr =
            ccall(sbml(:FbcModelPlugin_createGeneProduct), VPtr, (VPtr,), fbc_plugin)
        set_string!(geneproduct_ptr, :GeneProduct_setId, id)
        set_string!(geneproduct_ptr, :GeneProduct_setLabel, gene_product.label)
        set_string!(geneproduct_ptr, :GeneProduct_setName, gene_product.name)
        set_string!(geneproduct_ptr, :SBase_setMetaId, gene_product.metaid)
        set_string!(geneproduct_ptr, :SBase_setNotesString, gene_product.notes)
        set_string!(geneproduct_ptr, :SBase_setAnnotationString, gene_product.annotation)
        set_sbo_term!(geneproduct_ptr, gene_product.sbo)
    end

    # Add initial assignments
    for (symbol, math) in mdl.initial_assignments
        initialassignment_ptr =
            ccall(sbml(:Model_createInitialAssignment), VPtr, (VPtr,), model)
        set_string!(initialassignment_ptr, :InitialAssignment_setSymbol, symbol)
        ccall(
            sbml(:InitialAssignment_setMath),
            Cint,
            (VPtr, VPtr),
            initialassignment_ptr,
            get_astnode_ptr(math),
        )
    end

    # Add constraints
    for constraint in mdl.constraints
        constraint_ptr = ccall(sbml(:Model_createConstraint), VPtr, (VPtr,), model)
        # Note: this probably incorrect because our `Constraint` lost the XML namespace of the
        # message, also we don't have an easy way to test this because no test file uses constraints.
        message = ccall(sbml(:XMLNode_createTextNode), VPtr, (Cstring,), constraint.message)
        set_string!(constraint_ptr, :Constraint_setMessage, message)
        ccall(
            sbml(:Constraint_setMath),
            Cint,
            (VPtr, VPtr),
            constraint_ptr,
            get_astnode_ptr(constraint.math),
        )
    end

    # Add reactions
    for (id, reaction) in mdl.reactions
        reaction_ptr = ccall(sbml(:Model_createReaction), VPtr, (VPtr,), model)
        reaction_fbc_ptr =
            ccall(sbml(:SBase_getPlugin), VPtr, (VPtr, Cstring), reaction_ptr, "fbc")
        set_string!(reaction_ptr, :Reaction_setId, id)
        set_bool!(reaction_ptr, :Reaction_setReversible, reaction.reversible)
        set_string!(reaction_ptr, :Reaction_setName, reaction.name)
        for (sr_create, srs) in [
            :Reaction_createReactant => reaction.reactants,
            :Reaction_createProduct => reaction.products,
        ]
            for sr in srs
                reactant_ptr = ccall(sbml(sr_create), VPtr, (VPtr,), reaction_ptr)
                set_string!(reactant_ptr, :SpeciesReference_setSpecies, sr.species)
                set_string!(reactant_ptr, :SpeciesReference_setId, sr.id)
                set_double!(
                    reactant_ptr,
                    :SpeciesReference_setStoichiometry,
                    sr.stoichiometry,
                )
                set_bool!(reactant_ptr, :SpeciesReference_setConstant, sr.constant)
            end
        end
        if !isempty(reaction.kinetic_parameters) || !isnothing(reaction.kinetic_math)
            kinetic_law_ptr =
                ccall(sbml(:Reaction_createKineticLaw), VPtr, (VPtr,), reaction_ptr)
            for (id, parameter) in reaction.kinetic_parameters
                parameter_ptr =
                    ccall(sbml(:KineticLaw_createParameter), VPtr, (VPtr,), kinetic_law_ptr)
                set_parameter_ptr!(parameter_ptr, id, parameter)
            end
            isnothing(reaction.kinetic_math) || ccall(
                sbml(:KineticLaw_setMath),
                Cint,
                (VPtr, VPtr),
                kinetic_law_ptr,
                get_astnode_ptr(reaction.kinetic_math),
            )
        end
        if !isnothing(reaction.lower_bound) || !isnothing(reaction.upper_bound)
            set_string!(
                reaction_fbc_ptr,
                :FbcReactionPlugin_setLowerFluxBound,
                reaction.lower_bound,
            )
            set_string!(
                reaction_fbc_ptr,
                :FbcReactionPlugin_setUpperFluxBound,
                reaction.upper_bound,
            )
        end
        if !isnothing(reaction.gene_product_association)
            reaction_gpa_ptr = ccall(
                sbml(:FbcReactionPlugin_createGeneProductAssociation),
                VPtr,
                (VPtr,),
                reaction_fbc_ptr,
            )

            # the dispatch is a bit complicated in this case, we need to
            # remember the type of the structure that we're working on (that
            # sets the part of the symbol before `_`), and the type of the
            # association we're creating sets the part behind `_`. So let's
            # just tabulate and lag it through the recursion.

            create_gene_product_association(
                reaction.gene_product_association,
                reaction_gpa_ptr,
                :GeneProductAssociation_createOr,
                :GeneProductAssociation_createAnd,
                :GeneProductAssociation_createGeneProductRef,
            )
        end
        set_string!(reaction_ptr, :SBase_setMetaId, reaction.metaid)
        set_string!(reaction_ptr, :SBase_setNotesString, reaction.notes)
        set_string!(reaction_ptr, :SBase_setAnnotationString, reaction.annotation)
        set_sbo_term!(reaction_ptr, reaction.sbo)
    end

    # Add objectives
    fbc_plugin == C_NULL ||
        isempty(mdl.objectives) ||
        set_bool!(fbc_plugin, :FbcModelPlugin_setStrict, true)
    for (id, objective) in mdl.objectives
        objective_ptr =
            ccall(sbml(:FbcModelPlugin_createObjective), VPtr, (VPtr,), fbc_plugin)
        set_string!(objective_ptr, :Objective_setId, id)
        set_string!(objective_ptr, :Objective_setType, objective.type)
        for (reaction, coefficient) in objective.flux_objectives
            fluxobjective_ptr =
                ccall(sbml(:Objective_createFluxObjective), VPtr, (VPtr,), objective_ptr)
            set_string!(fluxobjective_ptr, :FluxObjective_setReaction, reaction)
            set_string!(fluxobjective_ptr, :FluxObjective_setCoefficient, coefficient)
        end
    end

    fbc_plugin == C_NULL ||
        set_string!(fbc_plugin, :FbcModelPlugin_setActiveObjectiveId, mdl.active_objective)

    # Add species
    fbc_plugin == C_NULL ||
        isempty(mdl.species) ||
        set_bool!(fbc_plugin, :FbcModelPlugin_setStrict, true)
    for (id, species) in mdl.species
        species_ptr = ccall(sbml(:Model_createSpecies), VPtr, (VPtr,), model)
        set_string!(species_ptr, :Species_setId, id)
        set_string!(species_ptr, :SBase_setMetaId, species.metaid)
        set_string!(species_ptr, :Species_setName, species.name)
        set_string!(species_ptr, :Species_setCompartment, species.compartment)
        set_bool!(species_ptr, :Species_setBoundaryCondition, species.boundary_condition)
        species_fbc_ptr =
            ccall(sbml(:SBase_getPlugin), VPtr, (VPtr, Cstring), species_ptr, "fbc")
        if species_fbc_ptr != C_NULL
            set_string!(species_ptr, :FbcSpeciesPlugin_setChemicalFormula, species.formula)
            set_int!(species_ptr, :FbcSpeciesPlugin_setCharge, species.charge)
        end
        set_double!(species_ptr, :Species_setInitialAmount, species.initial_amount)
        set_double!(
            species_ptr,
            :Species_setInitialConcentration,
            species.initial_concentration,
        )
        set_string!(species_ptr, :Species_setSubstanceUnits, species.substance_units)
        set_bool!(
            species_ptr,
            :Species_setHasOnlySubstanceUnits,
            species.only_substance_units,
        )
        set_bool!(species_ptr, :Species_setConstant, species.constant)
        set_string!(species_ptr, :SBase_setNotesString, species.notes)
        set_string!(species_ptr, :SBase_setAnnotationString, species.annotation)
        set_sbo_term!(species_ptr, species.sbo)
    end

    # Add function definitions
    for (id, func_def) in mdl.function_definitions
        functiondefinition_ptr =
            ccall(sbml(:Model_createFunctionDefinition), VPtr, (VPtr,), model)
        set_string!(functiondefinition_ptr, :FunctionDefinition_setId, id)
        set_string!(functiondefinition_ptr, :FunctionDefinition_setName, func_def.name)
        isnothing(func_def.body) || ccall(
            sbml(:FunctionDefinition_setMath),
            Cint,
            (VPtr, VPtr),
            functiondefinition_ptr,
            get_astnode_ptr(func_def.body),
        )
        set_string!(functiondefinition_ptr, :SBase_setNotesString, func_def.notes)
        set_string!(functiondefinition_ptr, :SBase_setAnnotationString, func_def.annotation)
    end

    # Add rules
    for rule in mdl.rules
        add_rule(model, rule)
    end

    # Add events
    for (id, event) in mdl.events
        event_ptr = ccall(sbml(:Model_createEvent), VPtr, (VPtr,), model)
        set_string!(event_ptr, :Event_setId, id)
        set_int!(
            event_ptr,
            :Event_setUseValuesFromTriggerTime,
            event.use_values_from_trigger_time,
        )
        set_string!(event_ptr, :Event_setName, event.name)
        if !isnothing(event.trigger)
            trigger_ptr = ccall(sbml(:Event_createTrigger), VPtr, (VPtr,), event_ptr)
            set_bool!(trigger_ptr, :Trigger_setPersistent, event.trigger.persistent)
            set_bool!(trigger_ptr, :Trigger_setInitialValue, event.trigger.initial_value)
            isnothing(event.trigger.math) || ccall(
                sbml(:Trigger_setMath),
                Cint,
                (VPtr, VPtr),
                trigger_ptr,
                get_astnode_ptr(event.trigger.math),
            )
        end
        if !isnothing(event.event_assignments)
            for event_assignment in event.event_assignments
                event_assignment_ptr =
                    ccall(sbml(:Event_createEventAssignment), VPtr, (VPtr,), event_ptr)
                set_string!(
                    event_assignment_ptr,
                    :EventAssignment_setVariable,
                    event_assignment.variable,
                )
                isnothing(event_assignment.math) || ccall(
                    sbml(:EventAssignment_setMath),
                    Cint,
                    (VPtr, VPtr),
                    event_assignment_ptr,
                    get_astnode_ptr(event_assignment.math),
                )
            end
        end
    end

    # Add conversion factor
    set_string!(model, :Model_setConversionFactor, mdl.conversion_factor)

    # Add other units attributes
    set_string!(model, :Model_setAreaUnits, mdl.area_units)
    set_string!(model, :Model_setExtentUnits, mdl.extent_units)
    set_string!(model, :Model_setLengthUnits, mdl.length_units)
    set_string!(model, :Model_setSubstanceUnits, mdl.substance_units)
    set_string!(model, :Model_setTimeUnits, mdl.time_units)
    set_string!(model, :Model_setVolumeUnits, mdl.volume_units)

    # Notes and annotations
    set_string!(model, :SBase_setNotesString, mdl.notes)
    set_string!(model, :SBase_setAnnotationString, mdl.annotation)

    # We can finally return the model
    return model
end

function _create_doc(mdl::Model)::VPtr
    doc = if isempty(mdl.gene_products) && isempty(mdl.objectives) && isempty(mdl.species)
        ccall(
            sbml(:SBMLDocument_createWithLevelAndVersion),
            VPtr,
            (Cuint, Cuint),
            WRITESBML_DEFAULT_LEVEL,
            WRITESBML_DEFAULT_VERSION,
        )
    else
        # Get fbc registry entry
        sbmlext = ccall(sbml(:SBMLExtensionRegistry_getExtension), VPtr, (Cstring,), "fbc")
        # create the sbml namespaces object with fbc
        fbc = ccall(sbml(:XMLNamespaces_create), VPtr, ())
        # create the sbml namespaces object with fbc
        uri = ccall(
            sbml(:SBMLExtension_getURI),
            Cstring,
            (VPtr, Cuint, Cuint, Cuint),
            sbmlext,
            WRITESBML_PKG_DEFAULT_LEVEL,
            WRITESBML_PKG_DEFAULT_VERSION,
            WRITESBML_PKG_DEFAULT_PKGVERSION,
        )
        ccall(sbml(:XMLNamespaces_add), Cint, (VPtr, Cstring, Cstring), fbc, uri, "fbc")
        # Create SBML namespace with fbc package
        sbmlns = ccall(
            sbml(:SBMLNamespaces_create),
            VPtr,
            (Cuint, Cuint),
            WRITESBML_DEFAULT_LEVEL,
            WRITESBML_DEFAULT_VERSION,
        )
        ccall(sbml(:SBMLNamespaces_addPackageNamespaces), Cint, (VPtr, VPtr), sbmlns, fbc)
        # Create document from SBML namespace
        d = ccall(sbml(:SBMLDocument_createWithSBMLNamespaces), VPtr, (VPtr,), sbmlns)
        # Do not require fbc package
        ccall(
            sbml(:SBMLDocument_setPackageRequired),
            Cint,
            (VPtr, Cstring, Cint),
            d,
            "fbc",
            false,
        )
        d
    end
    return doc
end

function writeSBML(mdl::Model, fn::String)
    doc = _create_doc(mdl)
    model = try
        model_to_sbml!(doc, mdl)
        res = ccall(sbml(:writeSBML), Cint, (VPtr, Cstring), doc, fn)
        res == 1 || error("Writing the SBML file \"$(fn)\" failed")
    finally
        ccall(sbml(:SBMLDocument_free), Cvoid, (VPtr,), doc)
    end
    return nothing
end

function writeSBML(mdl::Model)::String
    doc = _create_doc(mdl)
    str = try
        model_to_sbml!(doc, mdl)
        unsafe_string(ccall(sbml(:writeSBMLToString), Cstring, (VPtr,), doc))
    finally
        ccall(sbml(:SBMLDocument_free), Cvoid, (VPtr,), doc)
    end
    return str
end
