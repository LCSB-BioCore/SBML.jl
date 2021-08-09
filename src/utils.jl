"""
    function stoichiometry_matrix(m::SBML.Model; zeros=spzeros)::Tuple{Vector{String},Vector{String},AbstractMatrix{Float64}}

Extract the vector of species (aka metabolite) identifiers, vector of reaction
identifiers, and the (dense) stoichiometry matrix from an existing `SBML.Model`.
Returns a tuple with these values.

The matrix is sparse by default (initially constructed by
`SparseArrays.spzeros`). You can fill in a custom empty matrix constructed to
argument `zeros`; e.g. running with `zeros=zeros` will produce a dense matrix.
"""
function stoichiometry_matrix(
    m::SBML.Model;
    zeros = spzeros,
)::Tuple{Vector{String},Vector{String},AbstractMatrix{Float64}}
    rows = [k for k in keys(m.species)]
    cols = [k for k in keys(m.reactions)]
    rowsd = Dict(k => i for (i, k) in enumerate(rows))
    S = zeros(Float64, length(rows), length(cols))
    for col = 1:length(cols)
        s = m.reactions[cols[col]].reactants
        S[getindex.(Ref(rowsd), keys(s)), col] .-= values(s)
        s = m.reactions[cols[col]].products
        S[getindex.(Ref(rowsd), keys(s)), col] .+= values(s)
    end
    return rows, cols, S
end

"""
    flux_bounds(m::SBML.Model)::NTuple{2, Vector{Tuple{Float64,String}}}

Extract the vectors of lower and upper bounds of reaction rates from the model. All bounds
are accompanied with the unit of the corresponding value (this behavior is based on SBML
specification).
"""
flux_bounds(m::SBML.Model)::NTuple{2,Vector{Tuple{Float64,String}}} =
    (broadcast(x -> x.lb, values(m.reactions)), broadcast(x -> x.ub, values(m.reactions)))

"""
    flux_objective(m::SBML.Model)::Vector{Float64}

Extract the vector of objective coefficients of each reaction.
"""
flux_objective(m::SBML.Model)::Vector{Float64} = broadcast(x -> x.oc, values(m.reactions))

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
    function extensive_kinetic_math(
        m::SBML.Model,
        formula::SBML.Math;
        handle_empty_compartment_size = (id::String) -> throw(
            DomainError(
                "Non-substance-only-unit reference to species `\$id' in an unsized compartment `\$(m.species[id].compartment)'",
            ),
        ),
    )

Convert a SBML math `formula` to "extensive" kinetic laws, where the references
to species that are marked as not having only substance units are converted
from amounts to concentrations.

If the data is missing, you can supply a function that adds them. A common way
to handle errors is to assume that unsized compartments have volume 1.0 (of
whatever units), you can specify that behavior by supplying
`handle_empty_compartment_size = _ -> 1.0`.

Handling of units in the conversion process is ignored in this version.
"""
function extensive_kinetic_math(
    m::SBML.Model,
    formula::SBML.Math;
    handle_empty_compartment_size = (id::String) -> throw(
        DomainError(
            "Non-substance-only-unit reference to species `$id' in an unsized compartment `$(m.species[id].compartment)'",
        ),
    ),
)
    conv(x::SBML.MathIdent) = begin
        haskey(m.species, x.id) || return x
        sp = m.species[x.id]
        sp.only_substance_units && return x
        sz = m.compartments[sp.compartment].size
        isnothing(sz) && (sz = handle_empty_compartment_size(x.id))
        SBML.MathApply("/", [x, SBML.MathVal(sz)])
    end
    conv(x::SBML.MathApply) = SBML.MathApply(x.fn, conv.(x.args))
    conv(x::SBML.Math) = x

    conv(formula)
end

"""
    get_error_messages(doc::VPtr, error::Exception, report_severities)

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
    check_errors(
        success::Integer,
        doc::VPtr,
        error::Exception,
        report_severities = ["Fatal", "Error"],
    )

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

# NOTE: this mapping is valid for Level 3/Version 2, it *may* not be valid for
# other versions.  See
# https://github.com/sbmlteam/libsbml/blob/d4bc12abc4e72e451a0a0f2be4b0b6101ac94160/src/sbml/UnitKind.c#L46-L85
const UNIT_KIND_STRINGS_TO_UNIT = Dict(
    "ampere" => 1.0 * u"A", # UNIT_KIND_AMPERE
    "avogadro" => ustrip(u"mol^-1", Unitful.Na), # UNIT_KIND_AVOGADRO
    "becquerel" => 1.0 * u"Bq", # UNIT_KIND_BECQUEREL
    "candela" => 1.0 * u"cd", # UNIT_KIND_CANDELA
    "Celsius" => 1.0 * u"°C", # UNIT_KIND_CELSIUS
    "coulomb" => 1.0 * u"C", # UNIT_KIND_COULOMB
    "dimensionless" => 1, # UNIT_KIND_DIMENSIONLESS
    "farad" => 1.0 * u"F", # UNIT_KIND_FARAD
    "gram" => 1.0 * u"g", # UNIT_KIND_GRAM
    "gray" => 1.0 * u"Gy", # UNIT_KIND_GRAY
    "henry" => 1.0 * u"H", # UNIT_KIND_HENRY
    "hertz" => 1.0 * u"Hz", # UNIT_KIND_HERTZ
    "item" => 1, # UNIT_KIND_ITEM
    "joule" => 1.0 * u"J", # UNIT_KIND_JOULE
    "katal" => 1.0 * u"kat", # UNIT_KIND_KATAL
    "kelvin" => 1.0 * u"K", # UNIT_KIND_KELVIN
    "kilogram" => 1.0 * u"kg", # UNIT_KIND_KILOGRAM
    "liter" => 1.0 * u"L", # UNIT_KIND_LITER
    "litre" => 1.0 * u"L", # UNIT_KIND_LITRE
    "lumen" => 1.0 * u"lm", # UNIT_KIND_LUMEN
    "lux" => 1.0 * u"lx", # UNIT_KIND_LUX
    "meter" => 1.0 * u"m", # UNIT_KIND_METER
    "metre" => 1.0 * u"m", # UNIT_KIND_METRE
    "mole" => 1.0 * u"mol", # UNIT_KIND_MOLE
    "newton" => 1.0 * u"N", # UNIT_KIND_NEWTON
    "ohm" => 1.0 * u"Ω", # UNIT_KIND_OHM
    "pascal" => 1.0 * u"Pa", # UNIT_KIND_PASCAL
    "radian" => 1.0 * u"rad", # UNIT_KIND_RADIAN
    "second" => 1.0 * u"s", # UNIT_KIND_SECOND
    "siemens" => 1.0 * u"S", # UNIT_KIND_SIEMENS
    "sievert" => 1.0 * u"Sv", # UNIT_KIND_SIEVERT
    "steradian" => 1.0 * u"sr", # UNIT_KIND_STERADIAN
    "tesla" => 1.0 * u"T", # UNIT_KIND_TESLA
    "volt" => 1.0 * u"V", # UNIT_KIND_VOLT
    "watt" => 1.0 * u"W", # UNIT_KIND_WATT
    "weber" => 1.0 * u"W", # UNIT_KIND_WEBER
    "(Invalid UnitKind)" => 1, # UNIT_KIND_INVALID (let's treat is as a dimensionless quantity)
)

# Get a `Unitful` quantity out of a `Unit_t`.
function get_unit(u::VPtr)
    multiplier = ccall(sbml(:Unit_getMultiplier), Cdouble, (VPtr,), u)
    unit = UNIT_KIND_STRINGS_TO_UNIT[unsafe_string(
        ccall(
            sbml(:UnitKind_toString),
            Cstring,
            (Cint,),
            ccall(sbml(:Unit_getKind), Cint, (VPtr,), u),
        ),
    )]
    scale = ccall(sbml(:Unit_getScale), Cint, (VPtr,), u)
    exponent = ccall(sbml(:Unit_getExponent), Cint, (VPtr,), u)
    # See page 44 of
    # http://sbml.org/Special/specifications/sbml-level-3/version-2/core/release-2/sbml-level-3-version-2-release-2-core.pdf
    return (multiplier * unit * exp10(scale)) ^ exponent
end

# Get `Unitful` quantity out of a `UnitDefinition_t`.
get_units(ud::VPtr) = prod(
    get_unit(ccall(sbml(:UnitDefinition_getUnit), VPtr, (VPtr, Cuint), ud, j - 1)) for
    j = 1:ccall(sbml(:UnitDefinition_getNumUnits), Cuint, (VPtr,), ud)
)
