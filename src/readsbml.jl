
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
    Reaction(s,l,u,o) = new(s,l,u,o)
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
    Model(u,c,s,r) = new(u,c,s,r)
end

function readSBML(fn::String)::Model
    mi = readSBML_internal(fn)
    if length(errors(mi))>0
        @error "Loading failed!" errors(mi)
    end

    us = Dict{String, Vector{UnitPart}}()
    for u in units(mi)
        us[unit(u)]=Vector{UnitPart}()
    end
    for u in units(mi)
        push!(us[unit(u)], UnitPart(kind(u), exponent(u), scale(u), multiplier(u)))
    end

    ss = Dict{String, Species}()
    for s in species(mi)
        ss[id(s)] = Species(name(s), compartment(s))
    end

    rs = Dict{String, Reaction}()
    for r in reactions(mi)
        sts = Dict{String, Float64}()
        for s in species(r)
            sts[id(s)] = stoichiometry(s)
        end
        rs[id(r)] = Reaction(sts, lb(r), ub(r), oc(r))
    end

    return Model(us, compartments(mi), ss, rs)
end

#TODO this needs a sparse version and faster row ID lookup
function getS(m::Model)::Tuple{Vector{String}, Vector{String}, Matrix{Float64}}
    rows = [k for k in keys(m.species)] #TODO this too
    cols = [k for k in keys(m.reactions)]
    S = zeros(Float64, length(rows), length(cols))
    for ri in 1:length(cols)
        stoi = m.reactions[cols[ri]].stoichiometry
        S[indexin(keys(stoi), rows), ri] .= values(stoi)
    end
    return rows, cols, S
end

function getLBs(m::Model)::Vector{Tuple{Float64,String}}
    return broadcast(x -> x.lb, values(m.reactions))
end

function getUBs(m::Model)::Vector{Tuple{Float64,String}}
    return broadcast(x -> x.ub, values(m.reactions))
end

function getOCs(m::Model)::Vector{Float64}
    return broadcast(x -> x.oc, values(m.reactions))
end
