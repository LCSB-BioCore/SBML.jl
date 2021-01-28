
struct UnitPart
    kind::String
    exponent::Int
    scale::Int
    multiplier::Float64
    UnitPart(k, e, s, m) = new(k, e, s, m)
end

struct Reaction
    stoichiometry::Dict{String,Float64}
    lb::Tuple{Float64,String}
    ub::Tuple{Float64,String}
    oc::Float64
    Reaction(s, l, u, o) = new(s, l, u, o)
end

struct Species
    name::String
    compartment::String
    Species(n, c) = new(n, c)
end

struct Model
    units::Dict{String,Vector{UnitPart}}
    compartments::Vector{String}
    species::Dict{String,Species}
    reactions::Dict{String,Reaction}
    Model(u, c, s, r) = new(u, c, s, r)
end
