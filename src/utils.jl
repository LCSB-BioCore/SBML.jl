# Enum OperationReturnValues_t defined in
# `src/sbml/common/operationReturnValues.h`
const OPERATION_RETURN_VALUES = Dict(
    0 => "LIBSBML_OPERATION_SUCCESS",
    -1 => "LIBSBML_INDEX_EXCEEDS_SIZE",
    -2 => "LIBSBML_UNEXPECTED_ATTRIBUTE",
    -3 => "LIBSBML_OPERATION_FAILED",
    -4 => "LIBSBML_INVALID_ATTRIBUTE_VALUE",
    -5 => "LIBSBML_INVALID_OBJECT",
    -6 => "LIBSBML_DUPLICATE_OBJECT_ID",
    -7 => "LIBSBML_LEVEL_MISMATCH",
    -8 => "LIBSBML_VERSION_MISMATCH",
    -9 => "LIBSBML_INVALID_XML_OPERATION",
    -10 => "LIBSBML_NAMESPACES_MISMATCH",
    -11 => "LIBSBML_DUPLICATE_ANNOTATION_NS",
    -12 => "LIBSBML_ANNOTATION_NAME_NOT_FOUND",
    -13 => "LIBSBML_ANNOTATION_NS_NOT_FOUND",
    -14 => "LIBSBML_MISSING_METAID",
    -15 => "LIBSBML_DEPRECATED_ATTRIBUTE",
    -16 => "LIBSBML_USE_ID_ATTRIBUTE_FUNCTION",
    -20 => "LIBSBML_PKG_VERSION_MISMATCH",
    -21 => "LIBSBML_PKG_UNKNOWN",
    -22 => "LIBSBML_PKG_UNKNOWN_VERSION",
    -23 => "LIBSBML_PKG_DISABLED",
    -24 => "LIBSBML_PKG_CONFLICTED_VERSION",
    -25 => "LIBSBML_PKG_CONFLICT",
    -30 => "LIBSBML_CONV_INVALID_TARGET_NAMESPACE",
    -31 => "LIBSBML_CONV_PKG_CONVERSION_NOT_AVAILABLE",
    -32 => "LIBSBML_CONV_INVALID_SRC_DOCUMENT",
    -33 => "LIBSBML_CONV_CONVERSION_NOT_AVAILABLE",
    -34 => "LIBSBML_CONV_PKG_CONSIDERED_UNKNOWN",
)

"""
$(TYPEDSIGNATURES)

Extract the vector of species (aka metabolite) identifiers, vector of reaction
identifiers, and a sparse stoichiometry matrix (of type `SparseMatrixCSC` from
`SparseArrays` package) from an existing `SBML.Model`. Returns a 3-tuple with
these values.
"""
function stoichiometry_matrix(m::SBML.Model)
    rows = collect(keys(m.species))
    cols = collect(keys(m.reactions))
    row_idx = Dict(k => i for (i, k) in enumerate(rows))
    col_idx = Dict(k => i for (i, k) in enumerate(cols))

    nnz = 0
    for (_, r) in m.reactions
        for _ in r.reactants
            nnz += 1
        end
        for _ in r.products
            nnz += 1
        end
    end

    SI = Int[]
    RI = Int[]
    SV = Float64[]
    sizehint!(SI, nnz)
    sizehint!(RI, nnz)
    sizehint!(SV, nnz)

    for (rid, r) in m.reactions
        ridx = col_idx[rid]
        for sr in r.reactants
            push!(SI, row_idx[sr.species])
            push!(RI, ridx)
            push!(SV, isnothing(sr.stoichiometry) ? -1.0 : -sr.stoichiometry)
        end
        for sr in r.products
            push!(SI, row_idx[sr.species])
            push!(RI, ridx)
            push!(SV, isnothing(sr.stoichiometry) ? 1.0 : sr.stoichiometry)
        end
    end
    return rows, cols, SparseArrays.sparse(SI, RI, SV, length(rows), length(cols))
end

"""
$(TYPEDSIGNATURES)

Extract the vectors of lower and upper bounds of reaction rates from the model,
in the same order as `keys(m.reactions)`.  All bounds are accompanied with the
unit of the corresponding value (the behavior is based on SBML specification).
Missing bounds are represented by negative/positive infinite values with
empty-string unit.
"""
function flux_bounds(m::SBML.Model)::NTuple{2,Vector{Tuple{Float64,String}}}
    # Now this is tricky. There are multiple ways in SBML to specify a
    # lower/upper bound. There are the "global" model bounds that we completely
    # ignore now because no one uses them. In reaction, you can specify the
    # bounds using "LOWER_BOUND" and "UPPER_BOUND" parameters, but also there
    # may be a FBC plugged-in objective name that refers to the parameters.
    # We extract these, using the units from the parameters. For unbounded
    # reactions this gives -Inf or Inf as a default.

    function get_bound(rxn, fld, param, default)
        param_name = mayfirst(getfield(rxn, fld), param)
        param =
            get(rxn.kinetic_parameters, param_name, get(m.parameters, param_name, default))
        return (param.value, mayfirst(param.units, ""))
    end

    (
        get_bound.(
            values(m.reactions),
            :lower_bound,
            "LOWER_BOUND",
            Ref(Parameter(value = -Inf)),
        ),
        get_bound.(
            values(m.reactions),
            :upper_bound,
            "UPPER_BOUND",
            Ref(Parameter(value = Inf)),
        ),
    )
end

"""
$(TYPEDSIGNATURES)

Get the specified FBC maximization objective from a model, as a vector in the
same order as `keys(m.reactions)`.
"""
function fbc_flux_objective(m::Model, oid::String)

    obj = m.objectives[oid]
    coef = obj.type == "maximize" ? 1.0 : -1.0

    [
        maylift(o -> o * coef, get(obj.flux_objectives, rid, 0.0)) for
        rid in keys(m.reactions)
    ]
end

"""
$(TYPEDSIGNATURES)

Get a kinetic-parameter-specified flux objective from the model, as a vector in
the same order as `keys(m.reactions)`.
"""
function kinetic_flux_objective(m::Model)
    mayfirst.(
        (
            maylift(
                p -> p.value,
                get(m.reactions[rid].kinetic_parameters, "OBJECTIVE_COEFFICIENT", nothing),
            ) for rid in keys(m.reactions)
        ),
        0.0,
    )
end

"""
$(TYPEDSIGNATURES)

Collect a single maximization objective from FBC, and from kinetic parameters
if FBC is not available. Fails if there is more than 1 FBC objective.

Provided for simplicity and compatibility with earlier versions of SBML.jl.
"""
function flux_objective(m::Model)::Vector{Float64}
    oids = keys(m.objectives)
    if length(oids) == 1
        fbc_flux_objective(m, first(oids))
    elseif length(oids) == 0
        kinetic_flux_objective(m)
    else
        throw(
            DomainError(
                oids,
                "Ambiguous objective choice in flux_objective. Use fbc_flux_objective to select a single objective.",
            ),
        )
    end
end

"""
$(TYPEDSIGNATURES)

Helper to get the first non-`nothing` value from the arguments.
"""
function mayfirst(args...)
    for i in args
        if !isnothing(i)
            return i
        end
    end
    nothing
end

"""
$(TYPEDSIGNATURES)

Helper to lift a function to work on [`Maybe`](@ref), returning `nothing`
whenever there's a `nothing` in args.
"""
maylift(f, args::Maybe...) = any(isnothing, args) ? nothing : f(args...)

"""
$(TYPEDSIGNATURES)

A helper for easily getting out a defaulted compartment size.
"""
get_compartment_size(m::SBML.Model, compartment; default = nothing) =
    let c = get(m.compartments, compartment, nothing)
        mayfirst(
            maylift(x -> x.size, c),
            maylift(x -> x.spatial_dimensions == 0 ? 1.0 : nothing, c),
            default,
        )
    end

"""
$(TYPEDSIGNATURES)

Return initial amounts for each species as a generator of pairs
`species_name => initial_amount`; the amount is set to `nothing` if not
available. If `convert_concentrations` is true and there is information about
initial concentration available together with compartment size, the result is
computed from the species' initial concentration.

The units of measurement are ignored in this computation, but one may
reconstruct them from `substance_units` field of [`Species`](@ref) structure.

# Example
```
# get the initial amounts as dictionary
Dict(SBML.initial_amounts(model, convert_concentrations = true))

# suppose the compartment size is 10.0 if unspecified
collect(SBML.initial_amounts(
    model,
    convert_concentrations = true,
    compartment_size = comp -> SBML.get_compartment_size(model, comp, 10.0),
))

# remove the empty entries
Dict(k => v for (k,v) in SBML.initial_amounts(model) if !isnothing(v))
```
"""
initial_amounts(
    m::SBML.Model;
    convert_concentrations = false,
    compartment_size = comp -> get_compartment_size(m, comp),
) = (
    k => mayfirst(
        maylift(first, s.initial_amount),
        if convert_concentrations
            maylift(
                (ic, s) -> ic * s,
                s.initial_concentration,
                compartment_size(s.compartment),
            )
        end,
    ) for (k, s) in m.species
)

"""
$(TYPEDSIGNATURES)

Return initial concentrations of the species in the model. Refer to work-alike
[`initial_amounts`](@ref) for details.
"""
initial_concentrations(
    m::SBML.Model;
    convert_amounts = false,
    compartment_size = comp -> get_compartment_size(m, comp),
) = (
    k => mayfirst(
        maylift(first, s.initial_concentration),
        if convert_amounts
            maylift((ia, s) -> ia / s, s.initial_amount, compartment_size(s.compartment))
        end,
    ) for (k, s) in m.species
)

"""
    isfreein(id::String, expr::SBML.Math)

Determine if `id` is used and not bound (aka. free) in `expr`.
"""
isfreein(id::String, expr::SBML.Math) = interpret_math(
    expr,
    map_apply = (x, rec) -> any(rec.(x.args)),
    map_const = _ -> false,
    map_ident = x -> x.id == id,
    map_lambda = (x, rec) -> id in x.args ? false : rec(x.body),
    map_time = _ -> false,
    map_value = _ -> false,
)

"""
    isboundbyrules(
        id::String,
        m::SBML.Model
    )

Determine if an identifier seems defined or used by any Rules in the model.
"""
seemsdefined(id::String, m::SBML.Model) =
    any(r.variable == id for r in m.rules if r isa AssignmentRule) ||
    any(r.variable == id for r in m.rules if r isa RateRule) ||
    any(isfreein(id, r.math) for r in m.rules if r isa AlgebraicRule)

"""
$(TYPEDSIGNATURES)

Convert a SBML math `formula` to "extensive" kinetic laws, where the references
to species that are marked as not having only substance units are converted
from amounts to concentrations. Compartment sizes are referenced by compartment
identifiers. A compartment with no obvious definition available in the model
(as detected by [`seemsdefined`](@ref)) is either defaulted as size-less (i.e.,
size is 1.0) in case it does not have spatial dimensions, or reported as
erroneous.
"""
extensive_kinetic_math(m::SBML.Model, formula::SBML.Math) = interpret_math(
    formula,
    map_apply = (x, rec) -> SBML.MathApply(x.fn, rec.(x.args)),
    map_const = identity,
    map_ident = (x::SBML.MathIdent) -> begin
        haskey(m.species, x.id) || return x
        sp = m.species[x.id]
        sp.only_substance_units && return x
        if isnothing(m.compartments[sp.compartment].size) &&
           !seemsdefined(sp.compartment, m)
            if m.compartments[sp.compartment].spatial_dimensions == 0
                # If the comparment ID doesn't seem directly defined anywhere
                # and it is a zero-dimensional unsized compartment, just avoid
                # any sizing questions.
                return x
            else
                # In case the compartment is expected to be defined, complain.
                throw(
                    DomainError(
                        sp.compartment,
                        "compartment size is insufficiently defined",
                    ),
                )
            end
        else
            # Now we are sure that the model either has the compartment with
            # constant size, or the definition is easily reachable. So just use
            # the compartment ID as a variable to compute the concentration (or
            # area-centration etc, with different dimensionalities) by dividing
            # it.
            return SBML.MathApply("/", [x, SBML.MathIdent(sp.compartment)])
        end
    end,
    map_lambda = (x, _) -> error(
        ErrorException("converting lambdas to extensive kinetic math is not supported"),
    ),
    map_time = identity,
    map_value = identity,
)

"""
$(TYPEDSIGNATURES)

Show the error messages reported by SBML in the `doc` document and throw the
`error` if they are more than 1.

`report_severities` switches the reporting of certain error types defined by
libsbml; you can choose from `["Fatal", "Error", "Warning", "Informational"]`.
"""
function get_error_messages(doc::VPtr, error::Exception, report_severities)
    n_errs = ccall(sbml(:SBMLDocument_getNumErrors), Cuint, (VPtr,), doc)
    do_throw = false
    for i = 1:n_errs
        err = ccall(sbml(:SBMLDocument_getError), VPtr, (VPtr, Cuint), doc, i - 1)
        msg = string(strip(get_string(err, :XMLError_getMessage)))
        sev = string(strip(get_string(err, :XMLError_getSeverityAsString)))
        # keywords from `libsbml/src/sbml/xml/XMLError.cpp` xmlSeverityStringTable:
        if sev == "Fatal"
            sev in report_severities && @error "SBML reported fatal error: $(msg)"
            do_throw = true
        elseif sev == "Error"
            sev in report_severities && @error "SBML reported error: $(msg)"
            do_throw = true
        elseif sev == "Warning"
            sev in report_severities && @warn "SBML reported warning: $(msg)"
        elseif sev == "Informational"
            sev in report_severities && @info "SBML reported: $(msg)"
        end
    end
    do_throw && throw(error)
    nothing
end

"""
$(TYPEDSIGNATURES)

If success is a 0-valued `Integer` (a logical `false`), then call
[`get_error_messages`](@ref) to show the error messages reported by SBML in the
`doc` document and throw the `error` if they are more than 1.  `success` is
typically the value returned by an SBML C function operating on `doc` which
returns a boolean flag to signal a successful operation.
"""
check_errors(
    success::Integer,
    doc::VPtr,
    error::Exception,
    report_severities = ["Fatal", "Error"],
) = Bool(success) || get_error_messages(doc, error, report_severities)

"""
$(TYPEDSIGNATURES)

Pretty-printer for a SBML model.
Avoids flushing too much stuff to terminal by accident.
"""
function Base.show(io::IO, ::MIME"text/plain", m::SBML.Model)
    print(
        io,
        repr(typeof(m)),
        " with ",
        length(m.reactions),
        " reactions, ",
        length(m.species),
        " species, and ",
        length(m.parameters),
        " parameters.",
    )
end
