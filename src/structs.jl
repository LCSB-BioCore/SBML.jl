
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
Base.@kwdef struct UnitPart
    kind::String
    exponent::Int
    scale::Int
    multiplier::Float64
end

Base.@kwdef struct UnitDefinition
    name::Maybe{String} = nothing
    list_of_units::Vector{UnitPart}
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

Representation of SBML Parameter structure, holding a value annotated with
units and constantness information.

# Fields
$(TYPEDFIELDS)
"""
Base.@kwdef struct Parameter
    name::Maybe{String} = nothing
    value::Maybe{Float64} = nothing
    units::Maybe{String} = nothing
    constant::Maybe{Bool} = nothing
end

"""
$(TYPEDEF)

SBML Compartment with sizing information.

# Fields
$(TYPEDFIELDS)
"""
Base.@kwdef struct Compartment
    name::Maybe{String} = nothing
    constant::Maybe{Bool} = nothing
    spatial_dimensions::Maybe{Int} = nothing
    size::Maybe{Float64} = nothing
    units::Maybe{String} = nothing
    notes::Maybe{String} = nothing
    annotation::Maybe{String} = nothing
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
Base.@kwdef struct Reaction
    name::Maybe{String} = nothing
    reactants::Dict{String,Float64} = Dict()
    products::Dict{String,Float64} = Dict()
    kinetic_parameters::Dict{String,Parameter} = Dict()
    lower_bound::Maybe{String} = nothing
    upper_bound::Maybe{String} = nothing
    gene_product_association::Maybe{GeneProductAssociation} = nothing
    kinetic_math::Maybe{Math} = nothing
    reversible::Bool
    notes::Maybe{String} = nothing
    annotation::Maybe{String} = nothing
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

SBML constraint.

# Fields
$(TYPEDFIELDS)
"""
struct Constraint
    math::Math
    message::String
end

"""
$(TYPEDEF)

Species metadata -- contains a human-readable `name`, a `compartment`
identifier, `formula`, `charge`, and additional `notes` and `annotation`.

# Fields
$(TYPEDFIELDS)
"""
Base.@kwdef struct Species
    name::Maybe{String} = nothing
    compartment::String
    boundary_condition::Maybe{Bool} = nothing
    formula::Maybe{String} = nothing
    charge::Maybe{Int} = nothing
    initial_amount::Maybe{Float64} = nothing
    initial_concentration::Maybe{Float64} = nothing
    substance_units::Maybe{String} = nothing
    only_substance_units::Maybe{Bool} = nothing
    constant::Maybe{Bool} = nothing
    notes::Maybe{String} = nothing
    annotation::Maybe{String} = nothing
end

"""
$(TYPEDEF)

Gene product metadata.

# Fields
$(TYPEDFIELDS)
"""
Base.@kwdef struct GeneProduct
    name::Maybe{String} = nothing
    label::Maybe{String} = nothing
    notes::Maybe{String} = nothing
    annotation::Maybe{String} = nothing
end

"""
Custom function definition.
"""
Base.@kwdef struct FunctionDefinition
    name::Maybe{String} = nothing
    body::Maybe{Math} = nothing
    notes::Maybe{String} = nothing
    annotation::Maybe{String} = nothing
end

"""
$(TYPEDEF)

# Fields
$(TYPEDFIELDS)
"""
Base.@kwdef struct EventAssignment
    variable::String
    math::Maybe{Math} = nothing
end

"""
$(TYPEDEF)

# Fields
$(TYPEDFIELDS)
"""
Base.@kwdef struct Event
    name::Maybe{String} = nothing
    trigger::Maybe{Math} = nothing
    event_assignments::Maybe{Vector{EventAssignment}} = nothing
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
Base.@kwdef struct Model
    parameters::Dict{String,Parameter} = Dict()
    units::Dict{String,UnitDefinition} = Dict()
    compartments::Dict{String,Compartment} = Dict()
    species::Dict{String,Species} = Dict()
    initial_assignments::Dict{String,Math} = Dict()
    rules::Vector{Rule} = Rule[]
    constraints::Vector{Constraint} = Constraint[]
    reactions::Dict{String,Reaction} = Dict()
    objective::Dict{String,Float64} = Dict()
    gene_products::Dict{String,GeneProduct} = Dict()
    function_definitions::Dict{String,FunctionDefinition} = Dict()
    events::Dict{String,Event} = Dict()
    name::Maybe{String} = nothing
    id::Maybe{String} = nothing
    conversion_factor::Maybe{String} = nothing
    area_units::Maybe{String} = nothing
    extent_units::Maybe{String} = nothing
    length_units::Maybe{String} = nothing
    substance_units::Maybe{String} = nothing
    time_units::Maybe{String} = nothing
    volume_units::Maybe{String} = nothing
    notes::Maybe{String} = nothing
    annotation::Maybe{String} = nothing
end
