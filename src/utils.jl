"""
    function getS(m::SBML.Model; zeros=spzeros)::Tuple{Vector{String},Vector{String},AbstractMatrix{Float64}}

Extract the vector of species (aka metabolite) identifiers, vector of reaction
identifiers, and the (dense) stoichiometry matrix from an existing `SBML.Model`.
Returns a tuple with these values.

The matrix is sparse by default (initially constructed by
`SparseArrays.spzeros`). You can fill in a custom empty matrix constructed to
argument `zeros`; e.g. running with `zeros=zeros` will produce a dense matrix.
"""
function getS(
    m::SBML.Model;
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
    function getLBs(m::SBML.Model)::Vector{Tuple{Float64,String}}

Extract a vector of lower bounds of reaction rates from the model. All bounds
are accompanied with the unit of the corresponding value (this behavior is
based on SBML specification).
"""
function getLBs(m::SBML.Model)::Vector{Tuple{Float64,String}}
    return broadcast(x -> x.lb, values(m.reactions))
end

"""
    function getUBs(m::SBML.Model)::Vector{Tuple{Float64,String}}

Likewise to `getLBs`, extract the upper bounds.
"""
function getUBs(m::SBML.Model)::Vector{Tuple{Float64,String}}
    return broadcast(x -> x.ub, values(m.reactions))
end

"""
    function getOCs(m::SBML.Model)::Vector{Float64}

Extract the vector of objective coefficients of each reaction.
"""
function getOCs(m::SBML.Model)::Vector{Float64}
    return broadcast(x -> x.oc, values(m.reactions))
end

"""
    initial_amounts(m::SBML.Model; convert_concentrations = false)

Return initial amounts for each species as a generator of pairs
`species_name => initial_amount`; the amount is set to `nothing` if not
available. If `convert_concentrations` is true and there is information about
initial concentration available together with compartment size, the result is
computed from the species' initial concentration.

In the current version, units of the measurements are completely ignored.

# Example
```
# get the initial amounts as dictionary
Dict(initial_amounts(model, convert_concentrations = true))

# remove the empty entries
Dict(k => v for (k,v) in initial_amounts(model) if !isnothing(v))
```
"""
const initial_amounts(m::SBML.Model; convert_concentrations = false) = (
    k => if !isnothing(s.initial_amount)
        s.initial_amount[1]
    elseif convert_concentrations &&
           !isnothing(s.initial_concentration) &&
           haskey(m.compartments, s.compartment) &&
           !isnothing(m.compartments[s.compartment].size)
        s.initial_concentration[1] * m.compartments[s.compartment].size
    else
        nothing
    end for (k, s) in m.species
)

"""
    initial_concentrations(m::SBML.Model; convert_amounts = false)

Return initial concentrations of the species in the model. Refer to work-alike
[`initial_amounts`](@ref) for details.
"""
const initial_concentrations(m::SBML.Model; convert_amounts = false) = (
    k => if !isnothing(s.initial_concentration)
        s.initial_concentration[1]
    elseif convert_amounts &&
           !isnothing(s.initial_amount) &&
           haskey(m.compartments, s.compartment) &&
           !isnothing(m.compartments[s.compartment].size)
        s.initial_amount[1] / m.compartments[s.compartment].size
    else
        nothing
    end for (k, s) in m.species
)
