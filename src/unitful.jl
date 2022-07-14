
# NOTE: this mapping is valid for Level 3/Version 2, it *may* not be valid for
# other versions.  See
# https://github.com/sbmlteam/libsbml/blob/d4bc12abc4e72e451a0a0f2be4b0b6101ac94160/src/sbml/UnitKind.c#L46-L85
const UNITFUL_KIND_STRING = Dict(
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


"""
$(TYPEDSIGNATURES)

Converts an SBML unit definition (i.e., its vector of [`UnitPart`](@ref)s) to a
corresponding Unitful unit.
"""
unitful(u::UnitDefinition) = unitful(u.unit_parts)

"""
$(TYPEDSIGNATURES)

Converts a [`UnitPart`](@ref) to a corresponding Unitful unit.

The conversion is done according to the formula from
[SBML L3v2 core manual release 2](http://sbml.org/Special/specifications/sbml-level-3/version-2/core/release-2/sbml-level-3-version-2-release-2-core.pdf)(section 4.4.2).
"""
unitful(u::UnitPart) =
    (u.multiplier * UNITFUL_KIND_STRING[u.kind] * exp10(u.scale))^u.exponent

"""
$(TYPEDSIGNATURES)

Converts an SBML unit (i.e., a vector of [`UnitPart`](@ref)s) to a corresponding
Unitful unit.
"""
unitful(u::Vector{UnitPart}) = prod(unitful.(u))

"""
$(TYPEDSIGNATURES)

Computes a properly unitful value from a value-unit pair stored in the model
`m`.
"""
unitful(m::Model, val::Tuple{Float64,String}) = unitful(m.units[val[2]]) * val[1]

"""
$(TYPEDSIGNATURES)

Overload of [`unitful`](@ref) that uses the `default_unit` if the unit is not
found in the model.

# Example
```
julia> SBML.unitful(mdl, (10.0,"firkin"), 90 * u"lb")
990.0 lb
```
"""
unitful(m::Model, val::Tuple{Float64,String}, default_unit::Number) =
    mayfirst(maylift(unitful, get(m.units, val[2], nothing)), default_unit) * val[1]

"""
$(TYPEDSIGNATURES)

Overload of [`unitful`](@ref) that allows specification of the `default_unit` by
string ID.
"""
unitful(m::Model, val::Tuple{Float64,String}, default_unit::String) =
    unitful(m, val, unitful(m.units[default_unit]))

function unit_definition(id::String, units::UnitDefinition)::VPtr
    unit_definition = ccall(
        sbml(:UnitDefinition_create),
        VPtr,
        (Cint, Cint),
        WRITESBML_DEFAULT_LEVEL,
        WRITESBML_DEFAULT_VERSION,
    )
    ccall(sbml(:UnitDefinition_setId), Cint, (VPtr, Cstring), unit_definition, id)
    isnothing(units.name) || ccall(
        sbml(:UnitDefinition_setName),
        Cint,
        (VPtr, Cstring),
        unit_definition,
        units.name,
    )
    for unit in units.unit_parts
        unit_ptr = ccall(sbml(:UnitDefinition_createUnit), VPtr, (VPtr,), unit_definition)
        unit_kind = ccall(sbml(:UnitKind_forName), Cint, (Cstring,), unit.kind)
        ccall(sbml(:Unit_setKind), Cint, (VPtr, Cint), unit_ptr, unit_kind)
        ccall(sbml(:Unit_setScale), Cint, (VPtr, Cint), unit_ptr, unit.scale)
        ccall(sbml(:Unit_setExponent), Cint, (VPtr, Cint), unit_ptr, unit.exponent)
        ccall(sbml(:Unit_setMultiplier), Cint, (VPtr, Cdouble), unit_ptr, unit.multiplier)
    end
    return unit_definition
end
