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
    ccall(
        sbml(:GeneProductRef_setGeneProduct),
        Cint,
        (VPtr, Cstring),
        ref_ptr,
        gpr.gene_product,
    )
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
    ccall(sbml(:Rule_setVariable), Cint, (VPtr, Cstring), rule_ptr, r.variable)
    ccall(sbml(:Rule_setMath), Cint, (VPtr, VPtr), rule_ptr, get_astnode_ptr(r.math))
end

function add_unit_definition(model::VPtr, id::String, units::UnitDefinition)
    unit_definition = ccall(sbml(:Model_createUnitDefinition), VPtr, (VPtr,), model)
    ccall(sbml(:UnitDefinition_setId), Cint, (VPtr, Cstring), unit_definition, id)
    isnothing(units.name) || ccall(
        sbml(:UnitDefinition_setName),
        Cint,
        (VPtr, Cstring),
        unit_definition,
        units.name,
    )
    for unit in units.unit_parts
        unit_ptr = ccall(sbml(:UnitDefinition_createUnit), VPtr, (VPtr,), unit_definition)
        unit_kind = ccall(sbml(:UnitKind_forName), Cint, (Cstring,), unit.kind)
        ccall(sbml(:Unit_setKind), Cint, (VPtr, Cint), unit_ptr, unit_kind)
        ccall(sbml(:Unit_setScale), Cint, (VPtr, Cint), unit_ptr, unit.scale)
        ccall(sbml(:Unit_setExponent), Cint, (VPtr, Cint), unit_ptr, unit.exponent)
        ccall(sbml(:Unit_setMultiplier), Cint, (VPtr, Cdouble), unit_ptr, unit.multiplier)
    end
end

function set_parameter_ptr!(parameter_ptr::VPtr, id::String, parameter::Parameter)::VPtr
    ccall(sbml(:Parameter_setId), Cint, (VPtr, Cstring), parameter_ptr, id)
    isnothing(parameter.name) || ccall(
        sbml(:Parameter_setName),
        Cint,
        (VPtr, Cstring),
        parameter_ptr,
        parameter.name,
    )
    isnothing(parameter.value) || ccall(
        sbml(:Parameter_setValue),
        Cint,
        (VPtr, Cdouble),
        parameter_ptr,
        parameter.value,
    )
    isnothing(parameter.units) || ccall(
        sbml(:Parameter_setUnits),
        Cint,
        (VPtr, Cstring),
        parameter_ptr,
        parameter.units,
    )
    isnothing(parameter.constant) || ccall(
        sbml(:Parameter_setConstant),
        Cint,
        (VPtr, Cint),
        parameter_ptr,
        Cint(parameter.constant),
    )
    set_sbo_term!(parameter_ptr, parameter.sbo)
    return parameter_ptr
end

"""
$(TYPEDSIGNATURES)

Helper for setting string values.
"""
function set_string!(ptr::VPtr, fn_sym::Symbol, s::Maybe{String})
    isnothing(s) || ccall(sbml(fn_sym), Cint, (VPtr, Cstring), ptr, s)
end

"""
$(TYPEDSIGNATURES)

Helper for writing SBO terms.
"""
set_sbo_term!(ptr, s) = set_string!(ptr, :SBase_setSBOTermID, s)

## Write the model

function model_to_sbml!(doc::VPtr, mdl::Model)::VPtr
    # Create the model pointer
    model = ccall(sbml(:SBMLDocument_createModel), VPtr, (VPtr,), doc)
    fbc_plugin = ccall(sbml(:SBase_getPlugin), VPtr, (VPtr, Cstring), model, "fbc")
    fbc_plugin == C_NULL ||
        isempty(mdl.gene_products) ||
        isempty(mdl.objectives) ||
        isempty(mdl.species) ||
        ccall(sbml(:FbcModelPlugin_setStrict), Cint, (VPtr, Cint), fbc_plugin, true)

    # Set ids and name
    isnothing(mdl.id) || ccall(sbml(:Model_setId), Cint, (VPtr, Cstring), model, mdl.id)
    isnothing(mdl.metaid) ||
        ccall(sbml(:SBase_setMetaId), Cint, (VPtr, Cstring), model, mdl.metaid)
    isnothing(mdl.name) ||
        ccall(sbml(:Model_setName), Cint, (VPtr, Cstring), model, mdl.name)

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
        ccall(sbml(:Compartment_setId), Cint, (VPtr, Cstring), compartment_ptr, id)
        isnothing(compartment.name) || ccall(
            sbml(:Compartment_setName),
            Cint,
            (VPtr, Cstring),
            compartment_ptr,
            compartment.name,
        )
        isnothing(compartment.constant) || ccall(
            sbml(:Compartment_setConstant),
            Cint,
            (VPtr, Cint),
            compartment_ptr,
            Cint(compartment.constant),
        )
        isnothing(compartment.spatial_dimensions) || ccall(
            sbml(:Compartment_setSpatialDimensions),
            Cint,
            (VPtr, Cuint),
            compartment_ptr,
            Cuint(compartment.spatial_dimensions),
        )
        isnothing(compartment.size) || ccall(
            sbml(:Compartment_setSize),
            Cint,
            (VPtr, Cdouble),
            compartment_ptr,
            Cdouble(compartment.size),
        )
        isnothing(compartment.units) || ccall(
            sbml(:Compartment_setUnits),
            Cint,
            (VPtr, Cstring),
            compartment_ptr,
            compartment.units,
        )
        isnothing(compartment.notes) || ccall(
            sbml(:SBase_setNotesString),
            Cint,
            (VPtr, Cstring),
            compartment_ptr,
            compartment.notes,
        )
        isnothing(compartment.annotation) || ccall(
            sbml(:SBase_setAnnotationString),
            Cint,
            (VPtr, Cstring),
            compartment_ptr,
            compartment.annotation,
        )
        set_sbo_term!(compartment_ptr, compartment.sbo)
    end

    # Add gene products
    fbc_plugin == C_NULL ||
        isempty(mdl.gene_products) ||
        ccall(sbml(:FbcModelPlugin_setStrict), Cint, (VPtr, Cint), fbc_plugin, true)
    for (id, gene_product) in mdl.gene_products
        geneproduct_ptr =
            ccall(sbml(:FbcModelPlugin_createGeneProduct), VPtr, (VPtr,), fbc_plugin)
        ccall(sbml(:GeneProduct_setId), Cint, (VPtr, Cstring), geneproduct_ptr, id)
        ccall(
            sbml(:GeneProduct_setLabel),
            Cint,
            (VPtr, Cstring),
            geneproduct_ptr,
            gene_product.label,
        )
        isnothing(gene_product.name) || ccall(
            sbml(:GeneProduct_setName),
            Cint,
            (VPtr, Cstring),
            geneproduct_ptr,
            gene_product.name,
        )
        isnothing(gene_product.metaid) || ccall(
            sbml(:SBase_setMetaId),
            Cint,
            (VPtr, Cstring),
            geneproduct_ptr,
            gene_product.metaid,
        )
        isnothing(gene_product.notes) || ccall(
            sbml(:SBase_setNotesString),
            Cint,
            (VPtr, Cstring),
            geneproduct_ptr,
            gene_product.notes,
        )
        isnothing(gene_product.annotation) || ccall(
            sbml(:SBase_setAnnotationString),
            Cint,
            (VPtr, Cstring),
            geneproduct_ptr,
            gene_product.annotation,
        )
        set_sbo_term!(geneproduct_ptr, gene_product.sbo)
    end

    # Add initial assignments
    for (symbol, math) in mdl.initial_assignments
        initialassignment_ptr =
            ccall(sbml(:Model_createInitialAssignment), VPtr, (VPtr,), model)
        ccall(
            sbml(:InitialAssignment_setSymbol),
            Cint,
            (VPtr, Cstring),
            initialassignment_ptr,
            symbol,
        )
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
        ccall(sbml(:Constraint_setMessage), Cint, (VPtr, VPtr), constraint_ptr, message)
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
        ccall(sbml(:Reaction_setId), Cint, (VPtr, Cstring), reaction_ptr, id)
        ccall(
            sbml(:Reaction_setReversible),
            Cint,
            (VPtr, Cint),
            reaction_ptr,
            reaction.reversible,
        )
        isnothing(reaction.name) || ccall(
            sbml(:Reaction_setName),
            Cint,
            (VPtr, Cstring),
            reaction_ptr,
            reaction.name,
        )
        for (sr_create, srs) in [
            :Reaction_createReactant => reaction.reactants,
            :Reaction_createProduct => reaction.products,
        ]
            for sr in srs
                reactant_ptr = ccall(sbml(sr_create), VPtr, (VPtr,), reaction_ptr)
                ccall(
                    sbml(:SpeciesReference_setSpecies),
                    Cint,
                    (VPtr, Cstring),
                    reactant_ptr,
                    sr.species,
                )
                isnothing(sr.id) || ccall(
                    sbml(:SpeciesReference_setId),
                    Cint,
                    (VPtr, Cstring),
                    reactant_ptr,
                    sr.id,
                )
                isnothing(sr.stoichiometry) || ccall(
                    sbml(:SpeciesReference_setStoichiometry),
                    Cint,
                    (VPtr, Cdouble),
                    reactant_ptr,
                    sr.stoichiometry,
                )
                isnothing(sr.constant) || ccall(
                    sbml(:SpeciesReference_setConstant),
                    Cint,
                    (VPtr, Cint),
                    reactant_ptr,
                    sr.constant,
                )
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
            isnothing(reaction.lower_bound) || ccall(
                sbml(:FbcReactionPlugin_setLowerFluxBound),
                Cint,
                (VPtr, Cstring),
                reaction_fbc_ptr,
                reaction.lower_bound,
            )
            isnothing(reaction.upper_bound) || ccall(
                sbml(:FbcReactionPlugin_setUpperFluxBound),
                Cint,
                (VPtr, Cstring),
                reaction_fbc_ptr,
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
        isnothing(reaction.metaid) || ccall(
            sbml(:SBase_setMetaId),
            Cint,
            (VPtr, Cstring),
            reaction_ptr,
            reaction.metaid,
        )
        isnothing(reaction.notes) || ccall(
            sbml(:SBase_setNotesString),
            Cint,
            (VPtr, Cstring),
            reaction_ptr,
            reaction.notes,
        )
        isnothing(reaction.annotation) || ccall(
            sbml(:SBase_setAnnotationString),
            Cint,
            (VPtr, Cstring),
            reaction_ptr,
            reaction.annotation,
        )
        set_sbo_term!(reaction_ptr, reaction.sbo)
    end

    # Add objectives
    fbc_plugin == C_NULL ||
        isempty(mdl.objectives) ||
        ccall(sbml(:FbcModelPlugin_setStrict), Cint, (VPtr, Cint), fbc_plugin, true)
    for (id, objective) in mdl.objectives
        objective_ptr =
            ccall(sbml(:FbcModelPlugin_createObjective), VPtr, (VPtr,), fbc_plugin)
        ccall(sbml(:Objective_setId), Cint, (VPtr, Cstring), objective_ptr, id)
        ccall(
            sbml(:Objective_setType),
            Cint,
            (VPtr, Cstring),
            objective_ptr,
            objective.type,
        )
        for (reaction, coefficient) in objective.flux_objectives
            fluxobjective_ptr =
                ccall(sbml(:Objective_createFluxObjective), VPtr, (VPtr,), objective_ptr)
            ccall(
                sbml(:FluxObjective_setReaction),
                Cint,
                (VPtr, Cstring),
                fluxobjective_ptr,
                reaction,
            )
            ccall(
                sbml(:FluxObjective_setCoefficient),
                Cint,
                (VPtr, Cdouble),
                fluxobjective_ptr,
                coefficient,
            )
        end
    end
    fbc_plugin == C_NULL || ccall(
        sbml(:FbcModelPlugin_setActiveObjectiveId),
        Cint,
        (VPtr, Cstring),
        fbc_plugin,
        mdl.active_objective,
    )

    # Add species
    fbc_plugin == C_NULL ||
        isempty(mdl.species) ||
        ccall(sbml(:FbcModelPlugin_setStrict), Cint, (VPtr, Cint), fbc_plugin, true)
    for (id, species) in mdl.species
        species_ptr = ccall(sbml(:Model_createSpecies), VPtr, (VPtr,), model)
        ccall(sbml(:Species_setId), Cint, (VPtr, Cstring), species_ptr, id)
        isnothing(species.name) ||
            ccall(sbml(:Species_setName), Cint, (VPtr, Cstring), species_ptr, species.name)
        isnothing(species.compartment) || ccall(
            sbml(:Species_setCompartment),
            Cint,
            (VPtr, Cstring),
            species_ptr,
            species.compartment,
        )
        isnothing(species.boundary_condition) || ccall(
            sbml(:Species_setBoundaryCondition),
            Cint,
            (VPtr, Cint),
            species_ptr,
            species.boundary_condition,
        )
        species_fbc_ptr =
            ccall(sbml(:SBase_getPlugin), VPtr, (VPtr, Cstring), species_ptr, "fbc")
        if species_fbc_ptr != C_NULL
            isnothing(species.formula) || ccall(
                sbml(:FbcSpeciesPlugin_setChemicalFormula),
                Cint,
                (VPtr, Cstring),
                species_fbc_ptr,
                species.formula,
            )
            isnothing(species.charge) || ccall(
                sbml(:FbcSpeciesPlugin_setCharge),
                Cint,
                (VPtr, Cint),
                species_fbc_ptr,
                species.charge,
            )
        end
        isnothing(species.initial_amount) || ccall(
            sbml(:Species_setInitialAmount),
            Cint,
            (VPtr, Cdouble),
            species_ptr,
            species.initial_amount,
        )
        isnothing(species.initial_concentration) || ccall(
            sbml(:Species_setInitialConcentration),
            Cint,
            (VPtr, Cdouble),
            species_ptr,
            species.initial_concentration,
        )
        isnothing(species.substance_units) || ccall(
            sbml(:Species_setSubstanceUnits),
            Cint,
            (VPtr, Cstring),
            species_ptr,
            species.substance_units,
        )
        isnothing(species.only_substance_units) || ccall(
            sbml(:Species_setHasOnlySubstanceUnits),
            Cint,
            (VPtr, Cint),
            species_ptr,
            species.only_substance_units,
        )
        isnothing(species.constant) || ccall(
            sbml(:Species_setConstant),
            Cint,
            (VPtr, Cint),
            species_ptr,
            species.constant,
        )
        isnothing(species.metaid) || ccall(
            sbml(:SBase_setMetaId),
            Cint,
            (VPtr, Cstring),
            species_ptr,
            species.metaid,
        )
        isnothing(species.notes) || ccall(
            sbml(:SBase_setNotesString),
            Cint,
            (VPtr, Cstring),
            species_ptr,
            species.notes,
        )
        isnothing(species.annotation) || ccall(
            sbml(:SBase_setAnnotationString),
            Cint,
            (VPtr, Cstring),
            species_ptr,
            species.annotation,
        )
        set_sbo_term!(species_ptr, species.sbo)
    end

    # Add function definitions
    for (id, func_def) in mdl.function_definitions
        functiondefinition_ptr =
            ccall(sbml(:Model_createFunctionDefinition), VPtr, (VPtr,), model)
        ccall(
            sbml(:FunctionDefinition_setId),
            Cint,
            (VPtr, Cstring),
            functiondefinition_ptr,
            id,
        )
        isnothing(func_def.name) || ccall(
            sbml(:FunctionDefinition_setName),
            Cint,
            (VPtr, Cstring),
            functiondefinition_ptr,
            func_def.name,
        )
        isnothing(func_def.body) || ccall(
            sbml(:FunctionDefinition_setMath),
            Cint,
            (VPtr, VPtr),
            functiondefinition_ptr,
            get_astnode_ptr(func_def.body),
        )
        isnothing(func_def.notes) || ccall(
            sbml(:SBase_setNotesString),
            Cint,
            (VPtr, Cstring),
            functiondefinition_ptr,
            func_def.notes,
        )
        isnothing(func_def.annotation) || ccall(
            sbml(:SBase_setAnnotationString),
            Cint,
            (VPtr, Cstring),
            functiondefinition_ptr,
            func_def.annotation,
        )
    end

    # Add rules
    for rule in mdl.rules
        add_rule(model, rule)
    end

    # Add events
    for (id, event) in mdl.events
        event_ptr = ccall(sbml(:Model_createEvent), VPtr, (VPtr,), model)
        ccall(sbml(:Event_setId), Cint, (VPtr, Cstring), event_ptr, id)
        ccall(
            sbml(:Event_setUseValuesFromTriggerTime),
            Cint,
            (VPtr, Cint),
            event_ptr,
            event.use_values_from_trigger_time,
        )
        isnothing(event.name) ||
            ccall(sbml(:Event_setName), Cint, (VPtr, Cstring), event_ptr, event.name)
        if !isnothing(event.trigger)
            trigger_ptr = ccall(sbml(:Event_createTrigger), VPtr, (VPtr,), event_ptr)
            ccall(
                sbml(:Trigger_setPersistent),
                Cint,
                (VPtr, Cint),
                trigger_ptr,
                event.trigger.persistent,
            )
            ccall(
                sbml(:Trigger_setInitialValue),
                Cint,
                (VPtr, Cint),
                trigger_ptr,
                event.trigger.initial_value,
            )
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
                ccall(
                    sbml(:EventAssignment_setVariable),
                    Cint,
                    (VPtr, Cstring),
                    event_assignment_ptr,
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
    isnothing(mdl.conversion_factor) || ccall(
        sbml(:Model_setConversionFactor),
        Cint,
        (VPtr, Cstring),
        model,
        mdl.conversion_factor,
    )

    # Add other units attributes
    isnothing(mdl.area_units) ||
        ccall(sbml(:Model_setAreaUnits), Cint, (VPtr, Cstring), model, mdl.area_units)
    isnothing(mdl.extent_units) ||
        ccall(sbml(:Model_setExtentUnits), Cint, (VPtr, Cstring), model, mdl.extent_units)
    isnothing(mdl.length_units) ||
        ccall(sbml(:Model_setLengthUnits), Cint, (VPtr, Cstring), model, mdl.length_units)
    isnothing(mdl.substance_units) || ccall(
        sbml(:Model_setSubstanceUnits),
        Cint,
        (VPtr, Cstring),
        model,
        mdl.substance_units,
    )
    isnothing(mdl.time_units) ||
        ccall(sbml(:Model_setTimeUnits), Cint, (VPtr, Cstring), model, mdl.time_units)
    isnothing(mdl.volume_units) ||
        ccall(sbml(:Model_setVolumeUnits), Cint, (VPtr, Cstring), model, mdl.volume_units)

    # Notes and annotations
    isnothing(mdl.notes) ||
        ccall(sbml(:SBase_setNotesString), Cint, (VPtr, Cstring), model, mdl.notes)
    isnothing(mdl.annotation) || ccall(
        sbml(:SBase_setAnnotationString),
        Cint,
        (VPtr, Cstring),
        model,
        mdl.annotation,
    )

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
