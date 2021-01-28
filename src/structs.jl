
"""
Part of a measurement unit definition that corresponds to the SBML definition of `Unit`. For example, "per square megahour", Mh^(-2), is written as:

    UnitPart("second", # base unit of time
             -2, # exponent, says "per square"
             6, # scale in powers of 10, says "mega"
             1/3600) # second-to-hour multiplier
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
consumption/production rates, lower/upper bounds (in tuples with unit names),
and objective coefficient.
"""
struct Reaction
    stoichiometry::Dict{String,Float64}
    lb::Tuple{Float64,String}
    ub::Tuple{Float64,String}
    oc::Float64
    Reaction(s, l, u, o) = new(s, l, u, o)
end

"""
Species metadata -- human-readable name and compartment identifier
"""
struct Species
    name::String
    compartment::String
    Species(n, c) = new(n, c)
end

"""
Structure that collects the model-related data. Dictionaries are indexed by
identifiers of the corresponding objects.
"""
struct Model
    units::Dict{String,Vector{UnitPart}}
    compartments::Vector{String}
    species::Dict{String,Species}
    reactions::Dict{String,Reaction}
    Model(u, c, s, r) = new(u, c, s, r)
end
