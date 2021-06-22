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

Return a vector of initial amounts for each species, or `nothing` if the
information is not available. If `convert_concentrations` is true and there is
information about initial concentration available together with compartment
size, the result is computed from the species' initial concentration.

In the current version, units of the measurements are completely ignored.
"""
function initial_amounts(
    m::SBML.Model;
    convert_concentrations = false,
)::Vector{Union{Float64,Nothing}}
    function get_ia(x::Species)
        if !isnothing(x.initial_amount)
            x.initial_amount[1]
        elseif !isnothing(x.initial_concentration) &&
               haskey(m.compartments, x.compartment) &&
               !isnothing(m.compartments[x.compartment].size)
            x.initial_concentration[1] * m.compartments[x.compartment].size
        else
            nothing
        end
    end

    if convert_concentrations
        get_ia.(values(m.species))
    else
        return broadcast(
            x -> isnothing(x.initial_amount) ? nothing : x.initial_amount[1],
            values(m.species),
        )
    end
end

"""
    initial_concentrations(m::SBML.Model; convert_amounts = false)

Return a vector of initial concentrations for each species, or `nothing` if
the information is not available. If `convert_amounts` is true and there is
information about initial amount available together with compartment size, the
result is computed from the species' initial amount.

In the current version, units of the measurements are completely ignored.
"""
function initial_concentrations(
    m::SBML.Model;
    convert_amounts = false,
)::Vector{Union{Float64,Nothing}}
    function get_ic(x::Species)
        if !isnothing(x.initial_concentration)
            x.initial_concentration[1]
        elseif !isnothing(x.initial_amount) &&
               haskey(m.compartments, x.compartment) &&
               !isnothing(m.compartments[x.compartment].size)
            x.initial_amount[1] / m.compartments[x.compartment].size
        else
            nothing
        end
    end

    if convert_amounts
        get_ic.(values(m.species))
    else
        broadcast(
            x -> isnothing(x.initial_concentration) ? nothing : x.initial_concentration[1],
            values(m.species),
        )
    end
end
