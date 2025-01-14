
"""
$(TYPEDEF)

Common supertype for all SBML.jl objects.
"""
abstract type SBMLObject end

"""
$(TYPEDEF)

Part of a measurement unit definition that corresponds to the SBML definition
of `Unit`. For example, the unit "per square megahour", Mh^(-2), is written as:

    SBML.UnitPart("second",  # base SI unit, this says we are measuring time
             -2,        # exponent, says "per square"
             6,         # log-10 scale of the unit, says "mega"
             1/3600)    # second-to-hour multiplier

Compound units (such as "volt-amperes" and "dozens of yards per ounce") are
built from multiple `UnitPart`s.  See also [`SBML.UnitDefinition`](@ref).

# Fields
$(TYPEDFIELDS)
"""
Base.@kwdef struct UnitPart <: SBMLObject
    kind::String
    exponent::Int
    scale::Int
    multiplier::Float64
end

"""
$(TYPEDEF)

Representation of SBML unit definition, holding the name of the unit and a
vector of [`SBML.UnitPart`](@ref)s.  See the definition of field `units` in
[`SBML.Model`](@ref).

# Fields
$(TYPEDFIELDS)
"""
Base.@kwdef struct UnitDefinition <: SBMLObject
    name::Maybe{String} = nothing
    unit_parts::Vector{UnitPart}
end

"""
$(TYPEDEF)

Abstract type for all kinds of gene product associations
"""
abstract type GeneProductAssociation <: SBMLObject end

"""
$(TYPEDEF)

Gene product reference in the association expression

# Fields
$(TYPEDFIELDS)
"""
struct GPARef <: GeneProductAssociation
    gene_product::String
end

"""
$(TYPEDEF)

Boolean binary "and" in the association expression

# Fields
$(TYPEDFIELDS)
"""
struct GPAAnd <: GeneProductAssociation
    terms::Vector{GeneProductAssociation}
end

"""
$(TYPEDEF)

Boolean binary "or" in the association expression

# Fields
$(TYPEDFIELDS)
"""
struct GPAOr <: GeneProductAssociation
    terms::Vector{GeneProductAssociation}
end

"""
$(TYPEDEF)

A simplified representation of MathML-specified math AST
"""
abstract type Math <: SBMLObject end

"""
$(TYPEDEF)

A literal value (usually a numeric constant) in mathematical expression

# Fields
$(TYPEDFIELDS)
"""
struct MathVal{T} <: Math where {T}
    val::T
end

"""
$(TYPEDEF)

An identifier (usually a variable name) in mathematical expression

# Fields
$(TYPEDFIELDS)
"""
struct MathIdent <: Math
    id::String
end

"""
$(TYPEDEF)

A constant identified by name (usually something like `pi`, `e` or `true`) in
mathematical expression

# Fields
$(TYPEDFIELDS)
"""
struct MathConst <: Math
    id::String
end

"""
$(TYPEDEF)

A special value representing the current time of the simulation, with a special
name.

# Fields
$(TYPEDFIELDS)
"""
struct MathTime <: Math
    id::String
end

"""
$(TYPEDEF)

A special value representing the Avogadro constant (which is a special named
value in SBML).

# Fields
$(TYPEDFIELDS)
"""
struct MathAvogadro <: Math
    id::String
end

"""
$(TYPEDEF)

Function application ("call by name", no tricks allowed) in mathematical expression

# Fields
$(TYPEDFIELDS)
"""
struct MathApply <: Math
    fn::String
    args::Vector{Math}
end

"""
$(TYPEDEF)

Function definition (aka "lambda") in mathematical expression

# Fields
$(TYPEDFIELDS)
"""
struct MathLambda <: Math
    args::Vector{String}
    body::Math
end



"""
$(TYPEDEF)

Representation of a SBML CVTerm, usually carrying Model or Biological
qualifier, a list of resources, and possibly nested CV terms.

# Fields
$(TYPEDFIELDS)
"""
Base.@kwdef struct CVTerm <: SBMLObject
    biological_qualifier::Maybe{Symbol} = nothing
    model_qualifier::Maybe{Symbol} = nothing
    resource_uris::Vector{String} = []
    nested_cvterms::Vector{CVTerm} = []
end

"""
$(TYPEDEF)

Representation of SBML Parameter structure, holding a value annotated with
units and constantness information.

# Fields
$(TYPEDFIELDS)
"""
Base.@kwdef struct Parameter <: SBMLObject
    name::Maybe{String} = nothing
    value::Maybe{Float64} = nothing
    units::Maybe{String} = nothing
    constant::Maybe{Bool} = nothing
    metaid::Maybe{String} = nothing
    notes::Maybe{String} = nothing
    annotation::Maybe{String} = nothing
    sbo::Maybe{String} = nothing
    cv_terms::Vector{CVTerm} = []
end

"""
$(TYPEDEF)

SBML Compartment with sizing information.

# Fields
$(TYPEDFIELDS)
"""
Base.@kwdef struct Compartment <: SBMLObject
    name::Maybe{String} = nothing
    constant::Maybe{Bool} = nothing
    spatial_dimensions::Maybe{Int} = nothing
    size::Maybe{Float64} = nothing
    units::Maybe{String} = nothing
    metaid::Maybe{String} = nothing
    notes::Maybe{String} = nothing
    annotation::Maybe{String} = nothing
    sbo::Maybe{String} = nothing
    cv_terms::Vector{CVTerm} = []
end

"""
$(TYPEDEF)

SBML SpeciesReference.

# Fields
$(TYPEDFIELDS)
"""
Base.@kwdef struct SpeciesReference <: SBMLObject
    id::Maybe{String} = nothing
    species::String
    stoichiometry::Maybe{Float64} = nothing
    constant::Maybe{Bool} = nothing
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
Base.@kwdef struct Reaction <: SBMLObject
    name::Maybe{String} = nothing
    reactants::Vector{SpeciesReference} = []
    products::Vector{SpeciesReference} = []
    kinetic_parameters::Dict{String,Parameter} = Dict()
    lower_bound::Maybe{String} = nothing
    upper_bound::Maybe{String} = nothing
    gene_product_association::Maybe{GeneProductAssociation} = nothing
    kinetic_math::Maybe{Math} = nothing
    reversible::Bool
    metaid::Maybe{String} = nothing
    notes::Maybe{String} = nothing
    annotation::Maybe{String} = nothing
    sbo::Maybe{String} = nothing
    cv_terms::Vector{CVTerm} = []
end

"""
$(TYPEDEF)

Abstract type representing SBML rules.
"""
abstract type Rule <: SBMLObject end

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
    variable::String
    math::Math
end

"""
$(TYPEDEF)

SBML rate rule.

# Fields
$(TYPEDFIELDS)
"""
struct RateRule <: Rule
    variable::String
    math::Math
end

"""
$(TYPEDEF)

SBML constraint.

# Fields
$(TYPEDFIELDS)
"""
struct Constraint <: SBMLObject
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
Base.@kwdef struct Species <: SBMLObject
    name::Maybe{String} = nothing
    compartment::String
    boundary_condition::Maybe{Bool} = nothing
    formula::Maybe{String} = nothing
    charge::Maybe{Int} = nothing
    initial_amount::Maybe{Float64} = nothing
    initial_concentration::Maybe{Float64} = nothing
    substance_units::Maybe{String} = nothing
    conversion_factor::Maybe{String} = nothing
    only_substance_units::Maybe{Bool} = nothing
    constant::Maybe{Bool} = nothing
    metaid::Maybe{String} = nothing
    notes::Maybe{String} = nothing
    annotation::Maybe{String} = nothing
    sbo::Maybe{String} = nothing
    cv_terms::Vector{CVTerm} = []
end

"""
$(TYPEDEF)

Gene product metadata.

# Fields
$(TYPEDFIELDS)
"""
Base.@kwdef struct GeneProduct <: SBMLObject
    label::String
    name::Maybe{String} = nothing
    metaid::Maybe{String} = nothing
    notes::Maybe{String} = nothing
    annotation::Maybe{String} = nothing
    sbo::Maybe{String} = nothing
    cv_terms::Vector{CVTerm} = []
end

"""
$(TYPEDEF)

Custom function definition.

# Fields
$(TYPEDFIELDS)
"""
Base.@kwdef struct FunctionDefinition <: SBMLObject
    name::Maybe{String} = nothing
    metaid::Maybe{String} = nothing
    body::Maybe{Math} = nothing
    notes::Maybe{String} = nothing
    annotation::Maybe{String} = nothing
    sbo::Maybe{String} = nothing
    cv_terms::Vector{CVTerm} = []
end

"""
$(TYPEDEF)

# Fields
$(TYPEDFIELDS)
"""
Base.@kwdef struct EventAssignment <: SBMLObject
    variable::String
    math::Maybe{Math} = nothing
end

"""
$(TYPEDEF)

# Fields
$(TYPEDFIELDS)
"""
Base.@kwdef struct Trigger <: SBMLObject
    persistent::Bool
    initial_value::Bool
    math::Maybe{Math} = nothing
end

"""
$(TYPEDEF)

# Fields
$(TYPEDFIELDS)
"""
Base.@kwdef struct Objective <: SBMLObject
    type::String
    flux_objectives::Dict{String,Float64} = Dict()
end

"""
$(TYPEDEF)

# Fields
$(TYPEDFIELDS)
"""
Base.@kwdef struct Event <: SBMLObject
    use_values_from_trigger_time::Bool
    name::Maybe{String} = nothing
    trigger::Maybe{Trigger} = nothing
    event_assignments::Maybe{Vector{EventAssignment}} = nothing
end

"""
$(TYPEDEF)

# Fields
$(TYPEDFIELDS)
"""
Base.@kwdef struct Member <: SBMLObject
    id::Maybe{String} = nothing
    metaid::Maybe{String} = nothing
    name::Maybe{String} = nothing
    id_ref::Maybe{String} = nothing
    metaid_ref::Maybe{String} = nothing
    notes::Maybe{String} = nothing
    annotation::Maybe{String} = nothing
    sbo::Maybe{String} = nothing
    cv_terms::Vector{CVTerm} = []
end

"""
$(TYPEDEF)

# Fields
$(TYPEDFIELDS)
"""
Base.@kwdef struct Group <: SBMLObject
    metaid::Maybe{String} = nothing
    kind::Maybe{String} = nothing
    name::Maybe{String} = nothing
    members::Vector{Member} = []
    notes::Maybe{String} = nothing
    annotation::Maybe{String} = nothing
    sbo::Maybe{String} = nothing
    cv_terms::Vector{CVTerm} = []
end

"""
$(TYPEDEF)

Julia representation of SBML Model structure, with the reactions, species,
units, compartments, and many other things.

Where available, all objects are contained in dictionaries indexed by SBML
identifiers.

# Fields
$(TYPEDFIELDS)
"""
Base.@kwdef struct Model <: SBMLObject
    parameters::Dict{String,Parameter} = Dict()
    units::Dict{String,UnitDefinition} = Dict()
    compartments::Dict{String,Compartment} = Dict()
    species::Dict{String,Species} = Dict()
    initial_assignments::Dict{String,Math} = Dict()
    rules::Vector{Rule} = Rule[]
    constraints::Vector{Constraint} = Constraint[]
    reactions::Dict{String,Reaction} = Dict()
    objectives::Dict{String,Objective} = Dict()
    active_objective::Maybe{String} = nothing
    gene_products::Dict{String,GeneProduct} = Dict()
    function_definitions::Dict{String,FunctionDefinition} = Dict()
    events::Vector{Pair{Maybe{String},Event}} = Pair{Maybe{String},Event}[]
    groups::Dict{String,Group} = Dict()
    name::Maybe{String} = nothing
    id::Maybe{String} = nothing
    metaid::Maybe{String} = nothing
    conversion_factor::Maybe{String} = nothing
    area_units::Maybe{String} = nothing
    extent_units::Maybe{String} = nothing
    length_units::Maybe{String} = nothing
    substance_units::Maybe{String} = nothing
    time_units::Maybe{String} = nothing
    volume_units::Maybe{String} = nothing
    notes::Maybe{String} = nothing
    annotation::Maybe{String} = nothing
    sbo::Maybe{String} = nothing
    cv_terms::Vector{CVTerm} = []
end

# Explicitly make all SBML structs "broadcastable" as scalars.
# (This must be updated if any of the structs are added or removed.)
#
# Use this to regenerate the Union contents moreless automatically:
#
#   sed -ne 's/.*\<struct \([A-Z][A-Za-z0-9]*\)\>.*/\1,/p' src/structs.jl
Base.Broadcast.broadcastable(x::SBMLObject) = Ref(x)
