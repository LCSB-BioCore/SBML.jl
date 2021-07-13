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
    getLBs(m::SBML.Model)::Vector{Tuple{Float64,String}}

Extract a vector of lower bounds of reaction rates from the model. All bounds
are accompanied with the unit of the corresponding value (this behavior is
based on SBML specification).
"""
getLBs(m::SBML.Model)::Vector{Tuple{Float64,String}} =
    broadcast(x -> x.lb, values(m.reactions))

"""
    getUBs(m::SBML.Model)::Vector{Tuple{Float64,String}}

Likewise to [`getLBs`](@ref), extract the upper bounds.
"""
getUBs(m::SBML.Model)::Vector{Tuple{Float64,String}} =
    broadcast(x -> x.ub, values(m.reactions))

"""
    getOCs(m::SBML.Model)::Vector{Float64}

Extract the vector of objective coefficients of each reaction.
"""
getOCs(m::SBML.Model)::Vector{Float64} = broadcast(x -> x.oc, values(m.reactions))

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
initial_amounts(m::SBML.Model; convert_concentrations = false) = (
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
initial_concentrations(m::SBML.Model; convert_amounts = false) = (
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


"""
    extensive_kinetic_math(m::SBML.Model, formula::SBML.Math)

Convert a SBML math `formula` to "extensive" kinetic laws, where the references
to species that are marked as not having only substance units are converted
from amounts to concentrations.

Handling of units in the conversion process is ignored in this version.
"""
function extensive_kinetic_math(m::SBML.Model, formula::SBML.Math)
    conv(x::SBML.MathIdent) = begin
        haskey(m.species, x.id) || return x
        sp = m.species[x.id]
        sp.only_substance_units && return x
        sz = m.compartments[sp.compartment].size
        isnothing(sz) && throw(
            DomainError(
                formula,
                "Non-substance-only-unit reference to species `$(x.id)' in an unsized compartment `$(sp.compartment)'.",
            ),
        )
        SBML.MathApply("/", [x, SBML.MathVal(sz)])
    end
    conv(x::SBML.MathApply) = SBML.MathApply(x.fn, conv.(x.args))
    conv(x::SBML.Math) = x

    conv(formula)
end

"""
    get_error_messages(doc::Ptr{Cvoid}, error::Exception)

Show the error messages reported by SBML in the `doc` document and throw the
`error` if they are more than 1.
"""
function get_error_messages(doc::VPtr, error::Exception)
    n_errs = ccall(sbml(:SBMLDocument_getNumErrors), Cuint, (VPtr,), doc)
    do_throw = false
    for i = 1:n_errs
        err = ccall(sbml(:SBMLDocument_getError), VPtr, (VPtr, Cuint), doc, i - 1)
        msg = string(strip(get_string(err, :XMLError_getMessage)))
        sev = string(strip(get_string(err, :XMLError_getSeverityAsString)))
        # keywords from `libsbml/src/sbml/xml/XMLError.cpp` xmlSeverityStringTable:
        if sev == "Fatal"
            @error "SBML reported fatal error: $(msg)"
            do_throw = true
        elseif sev == "Error"
            @error "SBML reported error: $(msg)"
            do_throw = true
        elseif sev == "Warning"
            @warn "SBML reported warning: $(msg)"
        else # sev=="Informational"
            @info "SBML reported: $(msg)"
        end
    end
    do_throw && throw(error)
    nothing
end

"""
    check_errors(success::Integer, doc::Ptr{Cvoid}, error::Exception)

If success is a 0-valued `Integer` (a logical `false`), then call
[`get_error_messages`](@ref) to show the error messages reported by SBML in the
`doc` document and throw the `error` if they are more than 1.  `success` is
typically the value returned by an SBML C function operating on `doc` which
returns a boolean flag to signal a successful operation.
"""
check_errors(success::Integer, doc::VPtr, error::Exception) =
    Bool(success) || get_error_messages(doc, error)
