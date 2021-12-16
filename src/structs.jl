
"""
Part of a measurement unit definition that corresponds to the SBML definition
of `Unit`. For example, the unit "per square megahour", Mh^(-2), is written as:

    SBML.UnitPart("second",  # base SI unit, this says we are measuring time
             -2,        # exponent, says "per square"
             6,         # log-10 scale of the unit, says "mega"
             1/3600)    # second-to-hour multiplier

Compound units (such as "volt-amperes" and "dozens of yards per ounce") are
built from multiple `UnitPart`s; see the definition of field `units` in
[`SBML.Model`](@ref).
"""
struct UnitPart
    kind::String
    exponent::Int
    scale::Int
    multiplier::Float64
    UnitPart(args...) = new(args...)
    UnitPart(; kind, exponent = 1, scale = 1, multiplier = 1.0) =
        new(kind, exponent, scale, multiplier)
end


"""
Abstract type for all kinds of gene product associations
"""
abstract type GeneProductAssociation end

"""
Gene product reference in the association expression
"""
struct GPARef <: GeneProductAssociation
    gene_product::String
end

"""
Boolean binary "and" in the association expression
"""
struct GPAAnd <: GeneProductAssociation
    terms::Vector{GeneProductAssociation}
end

"""
Boolean binary "or" in the association expression
"""
struct GPAOr <: GeneProductAssociation
    terms::Vector{GeneProductAssociation}
end

"""
A simplified representation of MathML-specified math AST
"""
abstract type Math end

"""
A literal value (usually a numeric constant) in mathematical expression
"""
struct MathVal{T} <: Math where {T}
    val::T
end

"""
An identifier (usually a variable name) in mathematical expression
"""
struct MathIdent <: Math
    id::String
end

"""
A constant identified by name (usually something like `pi`, `e` or `true`) in
mathematical expression
"""
struct MathConst <: Math
    id::String
end

"""
A special value representing the current time of the simulation, with a special
name.
"""
struct MathTime <: Math
    id::String
end

"""
Function application ("call by name", no tricks allowed) in mathematical expression
"""
struct MathApply <: Math
    fn::String
    args::Vector{Math}
end

"""
Function definition (aka "lambda") in mathematical expression
"""
struct MathLambda <: Math
    args::Vector{String}
    body::Math
end

"""
$(TYPEDEF)

SBML Compartment with sizing information.

# Fields
$(TYPEDFIELDS)
"""
struct Compartment
    name::Maybe{String}
    constant::Maybe{Bool}
    spatial_dimensions::Maybe{Int}
    size::Maybe{Float64}
    units::Maybe{String}
    notes::Maybe{String}
    annotation::Maybe{String}
    Compartment(args...) = new(args...)
    Compartment(;
        name = nothing,
        constant = nothing,
        spatial_dimensions = nothing,
        size = nothing,
        units = nothing,
        notes = nothing,
        annotations = nothing,
    ) = new(name, constant, spatial_dimensions, size, units, notes, annotation)
end

"""
$(TYPEDEF)

Reaction with stoichiometry that assigns reactants and products their relative
consumption/production rates, lower/upper bounds (in tuples `lb` and `ub`, with
unit names), and objective coefficient (`oc`). Also may contains `notes` and
`annotation`.

# Fields
$(TYPEDFIELDS)
"""
struct Reaction
    reactants::Dict{String,Float64}
    products::Dict{String,Float64}
    kinetic_parameters::Dict{String,Tuple{Float64,String}}
    lower_bound::Maybe{String}
    upper_bound::Maybe{String}
    gene_product_association::Maybe{GeneProductAssociation}
    kinetic_math::Maybe{Math}
    reversible::Bool
    notes::Maybe{String}
    annotation::Maybe{String}

    Reaction(args...) = new(args...)
    Reaction(;
        reactants = Dict{String,Float64}(),
        products = Dict{String,Float64}(),
        kinetic_parameters = Dict{String,Tuple{Float64,String}}(),
        lower_bound = nothing,
        upper_bound = nothing,
        gene_product_association = nothing,
        kinetic_math = nothing,
        reversible = false,
        notes = nothing,
        annotation = nothing,
    ) = new(
        reactants,
        products,
        kinetic_parameters,
        lower_bound,
        upper_bound,
        gene_product_association,
        kinetic_math,
        reversible,
        notes,
        annotation,
    )
end

"""
$(TYPEDEF)

Abstract type representing SBML rules.
"""
abstract type Rule end

"""
$(TYPEDEF)

SBML algebraic rule.

# Fields
$(TYPEDFIELDS)
"""
struct AlgebraicRule <: Rule
    math::Math
end

"""
$(TYPEDEF)

SBML assignment rule.

# Fields
$(TYPEDFIELDS)
"""
struct AssignmentRule <: Rule
    id::String
    math::Math
end

"""
$(TYPEDEF)

SBML rate rule.

# Fields
$(TYPEDFIELDS)
"""
struct RateRule <: Rule
    id::String
    math::Math
end

"""
$(TYPEDEF)

Species metadata -- contains a human-readable `name`, a `compartment`
identifier, `formula`, `charge`, and additional `notes` and `annotation`.

# Fields
$(TYPEDFIELDS)
"""
struct Species
    name::Maybe{String}
    compartment::String
    boundary_condition::Maybe{Bool}
    formula::Maybe{String}
    charge::Maybe{Int}
    initial_amount::Maybe{Tuple{Float64,Maybe{String}}}
    initial_concentration::Maybe{Tuple{Float64,Maybe{String}}}
    only_substance_units::Maybe{Bool}
    notes::Maybe{String}
    annotation::Maybe{String}
    Species(args...) = new(args...)
    Species(;
        name = nothing,
        compartment,
        boundary_condition = nothing,
        formula = nothing,
        charge = nothing,
        initial_amount = nothing,
        initial_concentration = nothing,
        only_substance_units = nothing,
        notes = nothing,
        annotation = nothing,
    ) = new(
        name,
        compartment,
        boundary_condition,
        formula,
        charge,
        initial_amount,
        initial_concentration,
        only_substance_units,
        notes,
        annotation,
    )
end

"""
$(TYPEDEF)

Gene product metadata.

# Fields
$(TYPEDFIELDS)
"""
struct GeneProduct
    name::Maybe{String}
    label::Maybe{String}
    notes::Maybe{String}
    annotation::Maybe{String}
    GeneProduct(args...) = new(args...)
    GeneProduct(; name = nothing, label = nothing, notes = nothing, annotation = nothing) =
        new(name, label, notes, annotation)
end

"""
Custom function definition.
"""
struct FunctionDefinition
    name::Maybe{String}
    body::Maybe{Math}
    notes::Maybe{String}
    annotation::Maybe{String}
    FunctionDefinition(args...) = new(args...)
    FunctionDefinition(;
        name = nothing,
        body = nothing,
        notes = nothing,
        annotation = nothing,
    ) = new(name, body, notes, annotation)
end

"""
$(TYPEDEF)

# Fields
$(TYPEDFIELDS)
"""
struct EventAssignment
    variable::String
    math::Maybe{Math}
    EventAssignment(args...) = new(args...)
    EventAssignment(; variable::String, math = nothing) = new(variable, math)
end

"""
$(TYPEDEF)

# Fields
$(TYPEDFIELDS)
"""
struct Event
    name::String
    trigger::Maybe{Math}
    event_assignments::Maybe{Vector{EventAssignment}}
    Event(args...) = new(args...)
    Event(;
        name::String,
        trigger::Maybe{Math} = nothing,
        event_assignments::Maybe{Vector{EventAssignment}} = nothing,
    ) = new(name, trigger, event_assignments)
end

"""
$(TYPEDEF)

Structure that collects the model-related data. Contains `parameters`, `units`,
`compartments`, `species` and `reactions` and `gene_products`, and additional
`notes` and `annotation` (also present internally in some of the data fields).
The contained dictionaries are indexed by identifiers of the corresponding
objects.

# Fields
$(TYPEDFIELDS)
"""
struct Model
    parameters::Dict{String,Tuple{Float64,String}}
    units::Dict{String,Vector{UnitPart}}
    compartments::Dict{String,Compartment}
    species::Dict{String,Species}
    initial_assignments::Dict{String,Math}
    rules::Vector{Rule}
    reactions::Dict{String,Reaction}
    objective::Dict{String,Float64}
    gene_products::Dict{String,GeneProduct}
    function_definitions::Dict{String,FunctionDefinition}
    events::Dict{String,Event}
    notes::Maybe{String}
    annotation::Maybe{String}

    Model(args...) = new(args...)
    Model(;
        parameters = Dict{String,Tuple{Float64,String}}(),
        units = Dict{String,Vector{UnitPart}}(),
        compartments = Dict{String,Compartment}(),
        species = Dict{String,Species}(),
        initial_assignments = Dict{String,Math}(),
        rules = Vector{Rule}(),
        reactions = Dict{String,Reaction}(),
        objective = Dict{String,Float64}(),
        gene_products = Dict{String,GeneProduct}(),
        function_definitions = Dict{String,FunctionDefinition}(),
        events = Dict{String,Event}(),
        notes = nothing,
        annotation = nothing,
    ) = new(
        parameters,
        units,
        compartments,
        species,
        initial_assignments,
        rules,
        reactions,
        objective,
        gene_products,
        function_definitions,
        events,
        notes,
        annotation,
    )
end
