
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
Reaction with stoichiometry that assigns reactants and products their relative
consumption/production rates (accessible in field `stoichiometry`), lower/upper
bounds (in tuples `lb` and `ub`, with unit names), and objective coefficient
(`oc`).
"""
struct Reaction
    stoichiometry::Dict{String,Float64}
    lb::Tuple{Float64,String}
    ub::Tuple{Float64,String}
    oc::Float64
    Reaction(s, l, u, o) = new(s, l, u, o)
end

"""
Species metadata -- contains a human-readable `name`, and a `compartment`
identifier
"""
struct Species
    name::String
    compartment::String
    formula::String
    Species(n, c, f) = new(n, c, f)
end

"""
Structure that collects the model-related data. Contains `units`,
`compartments`, `species` and `reactions`. The contained dictionaries are
indexed by identifiers of the corresponding objects.
"""
struct Model
    params::Dict{String,Float64}
    units::Dict{String,Vector{UnitPart}}
    compartments::Vector{String}
    species::Dict{String,Species}
    reactions::Dict{String,Reaction}
    Model(p, u, c, s, r) = new(p, u, c, s, r)
end
