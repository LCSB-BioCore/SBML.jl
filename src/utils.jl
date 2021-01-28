"""
    function getS(m::Model)::Tuple{Vector{String},Vector{String},Matrix{Float64}}

Extract the vector of species (aka metabolite) identifiers, vector of reaction
identifiers, and the (dense) stoichiometry matrix from an existing `Model`.
Returns a tuple with these values.
"""
function getS(m::Model)::Tuple{Vector{String},Vector{String},Matrix{Float64}}
    #TODO this will need a sparse version and faster row ID lookup
    rows = [k for k in keys(m.species)] #TODO this too
    cols = [k for k in keys(m.reactions)]
    S = zeros(Float64, length(rows), length(cols))
    for ri = 1:length(cols)
        stoi = m.reactions[cols[ri]].stoichiometry
        S[indexin(keys(stoi), rows), ri] .= values(stoi)
    end
    return rows, cols, S
end

"""
    function getLBs(m::Model)::Vector{Tuple{Float64,String}}

Extract a vector of lower bounds of reaction rates from the model. All bounds
are accompanied with the unit of the corresponding value (this behavior is
based on SBML specification).
"""
function getLBs(m::Model)::Vector{Tuple{Float64,String}}
    return broadcast(x -> x.lb, values(m.reactions))
end

"""
    function getUBs(m::Model)::Vector{Tuple{Float64,String}}

Likewise to `getLBs`, extract the upper bounds.
"""
function getUBs(m::Model)::Vector{Tuple{Float64,String}}
    return broadcast(x -> x.ub, values(m.reactions))
end

"""
    function getOCs(m::Model)::Vector{Float64}

Extract the vector of objective coefficients of each reaction.
"""
function getOCs(m::Model)::Vector{Float64}
    return broadcast(x -> x.oc, values(m.reactions))
end
