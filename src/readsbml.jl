struct UnitPart
    kind :: String
    exponent :: Int
    scale :: Int
    multiplier :: Float64
    UnitPart(k,e,s,m) = new(k,e,s,m)
end

struct Reaction
    stoichiometry :: Dict{String, Float64}
    lb :: Tuple{Float64, String}
    ub :: Tuple{Float64, String}
    oc :: Float64
    Reaction() = new()
end

struct Species
    name :: String
    compartment :: String
    Species(n,c) = new(n,c)
end

struct Model
    units :: Dict{String,Vector{UnitPart}}
    compartments :: Vector{String}
    species :: Dict{String,Species}
    reactions :: Dict{String, Reaction}
    Model() = new()
end

function readSMBL(fn::String)::Model
    mi = readSBML_internal(fn)
    if length(errors(mi))
        @error "Loading failed!" errors(mi)
    end

    m = Model()

    m.compartments = compartments(mi)
    
    return m
end

function getS(m::Model)::Matrix{Float64}
end

function getLBs(m::Model)::Vector{Tuple{Float64,String}}
end

function getUBs(m::Model)::Vector{Tuple{Float64,String}}
end

function getOCs(m::Model)::Vector{Float64}
end
