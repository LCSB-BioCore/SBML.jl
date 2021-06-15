
"""
    Maybe{X}

Type shortcut for "`X` or nothing" or "nullable `X`" in javaspeak. Name
got inspired by our functional friends.
"""
const Maybe{X} = Union{Nothing,X}

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
    UnitPart(k, e, s, m) = new(k, e, s, m)
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
mutable struct MathApply <: Math
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
SBML Compartment with sizing information.
"""
struct Compartment
    name::Maybe{String}
    constant::Maybe{Bool}
    spatial_dimensions::Maybe{Int}
    size::Maybe{Float64}
    units::Maybe{String}
    notes::Maybe{String}
    annotation::Maybe{String}
    Compartment(na, c, sd, s, u, no = nothing, an = nothing) = new(na, c, sd, s, u, no, an)
end

"""
Reaction with stoichiometry that assigns reactants and products their relative
consumption/production rates (accessible in field `stoichiometry`), lower/upper
bounds (in tuples `lb` and `ub`, with unit names), and objective coefficient
(`oc`). Also may contains `notes` and `annotation`.
"""
mutable struct Reaction
    stoichiometry::Dict{String,Float64}  # PL: @Mirek: Why do we allow/require non-integer stoichiometries?
    lb::Maybe{Tuple{Float64,String}}
    ub::Maybe{Tuple{Float64,String}}
    oc::Maybe{Float64}
    gene_product_association::Maybe{GeneProductAssociation}
    kinetic_math::Maybe{Math}
    reversible::Bool
    notes::Maybe{String}
    annotation::Maybe{String}
    Reaction(s, l, u, o, as, km, r, n = nothing, an = nothing) =
        new(s, l, u, o, as, km, r, n, an)
end

"""
Species metadata -- contains a human-readable `name`, a `compartment`
identifier, `formula`, `charge`, and additional `notes` and `annotation`.
"""
mutable struct Species
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
    Species(na, co, b, f, ch, ia, ic, osu, no = nothing, a = nothing) =
        new(na, co, b, f, ch, ia, ic, osu, no, a)
end

"""
Gene product metadata.
"""
struct GeneProduct
    name::Maybe{String}
    label::Maybe{String}
    notes::Maybe{String}
    annotation::Maybe{String}
    GeneProduct(na, l, no = nothing, a = nothing) = new(na, l, no, a)
end

"""
Custom function definition.
"""
struct FunctionDefinition
    name::Maybe{String}
    body::Maybe{Math}
    notes::Maybe{String}
    annotation::Maybe{String}
    FunctionDefinition(na, b, no = nothing, a = nothing) = new(na, b, no, a)
end

"""
Structure that collects the model-related data. Contains `parameters`, `units`,
`compartments`, `species` and `reactions` and `gene_products`, and additional
`notes` and `annotation` (also present internally in some of the data fields).
The contained dictionaries are indexed by identifiers of the corresponding
objects.
"""
struct Model
    parameters::Dict{String,Float64}
    units::Dict{String,Vector{UnitPart}}
    compartments::Dict{String,Compartment}
    species::Dict{String,Species}
    reactions::Dict{String,Reaction}
    gene_products::Dict{String,GeneProduct}
    function_definitions::Dict{String,FunctionDefinition}
    notes::Maybe{String}
    annotation::Maybe{String}
    Model(p, u, c, s, r, g, f, n = nothing, a = nothing) = new(p, u, c, s, r, g, f, n, a)
end
