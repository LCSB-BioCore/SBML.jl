
"""
    Maybe{X}

Type shortcut for "`X` or nothing" or "nullable `X`" in javaspeak. Name
got inspired by our functional friends.
"""
const Maybe{X} = Union{Nothing,X}

"""
Part of a measurement unit definition that corresponds to the SBML definition
of `Unit`. For example, the unit "per square megahour", Mh^(-2), is written as:

    UnitPart("second",  # base SI unit, this says we are measuring time
             -2,        # exponent, says "per square"
             6,         # log-10 scale of the unit, says "mega"
             1/3600)    # second-to-hour multiplier

Compound units (such as "volt-amperes" and "dozens of yards per ounce") are
built from multiple `UnitPart`s; see the definition of field `units` in
[`Model`](@ref).
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
Reaction with stoichiometry that assigns reactants and products their relative
consumption/production rates (accessible in field `stoichiometry`), lower/upper
bounds (in tuples `lb` and `ub`, with unit names), and objective coefficient
(`oc`). Also may contains `notes` and `annotation`.
"""
struct Reaction
    mathml::String
    stoichiometry::Dict{String,Float64}
    lb::Tuple{Float64,String}
    ub::Tuple{Float64,String}
    oc::Float64
    gene_product_association::Maybe{GeneProductAssociation}
    notes::Maybe{String}
    annotation::Maybe{String}
    Reaction(s, l, u, o, as, n = nothing, an = nothing) = new(s, l, u, o, as, n, an)
end

"""
Species metadata -- contains a human-readable `name`, a `compartment`
identifier, `formula`, `charge`, and additional `notes` and `annotation`.
"""
struct Species
    name::String
    compartment::String
    formula::Maybe{String}
    charge::Maybe{Int}
    notes::Maybe{String}
    annotation::Maybe{String}
    Species(na, co, f, ch, no = nothing, a = nothing) = new(na, co, f, ch, no, a)
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
Structure that collects the model-related data. Contains `parameters`, `units`,
`compartments`, `species` and `reactions` and `gene_products`, and additional
`notes` and `annotation` (also present internally in some of the data fields).
The contained dictionaries are indexed by identifiers of the corresponding
objects.
"""
struct Model
    parameters::Dict{String,Float64}
    units::Dict{String,Vector{UnitPart}}
    compartments::Dict{String,Float64}  # PL: Float64 to describe size
    species::Dict{String,Tuple{Species,Float64}}  # PL: Tuple of Species and initialAmount
    reactions::Dict{String,Reaction}
    gene_products::Dict{String,GeneProduct}
    notes::Maybe{String}
    annotation::Maybe{String}
    Model(p, u, c, s, r, g, n = nothing, a = nothing) = new(p, u, c, s, r, g, n, a)
end
