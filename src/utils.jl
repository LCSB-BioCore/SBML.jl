"""
    function getS(m::Model; zeros=spzeros)::Tuple{Vector{String},Vector{String},AbstractMatrix{Float64}}

Extract the vector of species (aka metabolite) identifiers, vector of reaction
identifiers, and the (dense) stoichiometry matrix from an existing `Model`.
Returns a tuple with these values.

The matrix is sparse by default (initially constructed by
`SparseArrays.spzeros`). You can fill in a custom empty matrix constructed to
argument `zeros`; e.g. running with `zeros=zeros` will produce a dense matrix.
"""
function getS(
    m::Model;
    zeros = spzeros,
)::Tuple{Vector{String},Vector{String},AbstractMatrix{Float64}}
    rows = [k for k in keys(m.species)]
    cols = [k for k in keys(m.reactions)]
    rowsd = Dict(k => i for (i, k) in enumerate(rows))
    S = zeros(Float64, length(rows), length(cols))
    for col = 1:length(cols)
        stoi = m.reactions[cols[col]].stoichiometry
        S[getindex.(Ref(rowsd), keys(stoi)), col] .= values(stoi)
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
