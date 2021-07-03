
"""
    set_level_and_version(level, version)

A converter to pass into [`readSBML`](@ref) that enforces certain SBML level
and version.
"""
set_level_and_version(level, version) =
    doc -> check_errors(
        ccall(
            sbml(:SBMLDocument_setLevelAndVersion),
            Cint,
            (VPtr, Cint, Cint),
            doc,
            level,
            version,
        ),
        doc,
        ErrorException("Setting of level and version did not succeed"),
    )

"""
    libsbml_convert(conversion_options::Vector{Pair{String, Dict{String, String}}})

A converter that runs the SBML conversion routine, with specified conversion
options. The argument is a vector of pairs to allow specifying the order of
conversions.
"""
libsbml_convert(
    conversion_options::AbstractVector{<:Pair{String,<:AbstractDict{String,String}}},
) =
    doc -> begin
        for (converter, options) in conversion_options
            props = ccall(sbml(:ConversionProperties_create), VPtr, ())
            opt = ccall(sbml(:ConversionOption_create), VPtr, (Cstring,), converter)
            ccall(sbml(:ConversionProperties_addOption), Cvoid, (VPtr, VPtr), props, opt)
            for (k, v) in options
                opt = ccall(sbml(:ConversionOption_create), VPtr, (Cstring,), k)
                ccall(sbml(:ConversionOption_setValue), Cvoid, (VPtr, Cstring), opt, v)
                ccall(
                    sbml(:ConversionProperties_addOption),
                    Cvoid,
                    (VPtr, VPtr),
                    props,
                    opt,
                )
            end
            check_errors(
                ccall(sbml(:SBMLDocument_convert), Cint, (VPtr, VPtr), doc, props),
                doc,
                ErrorException("Conversion returned errors"),
            )
        end
    end

"""
    libsbml_convert(converter::String; kwargs...)

Quickly construct a single run of a `libsbml` converter from keyword arguments.

# Example
```
readSBML("example.xml", libsbml_convert("stripPackage", package="layout"))
```
"""
libsbml_convert(converter::String; kwargs...) = libsbml_convert([
    converter => Dict{String,String}(string(k) => string(v) for (k, v) in kwargs),
])

"""
    convert_simplify_math

Shortcut for [`libsbml_convert`](@ref) that expands functions, local
parameters, and initial assignments in the SBML document.
"""
const convert_simplify_math = libsbml_convert(
    ["promoteLocalParameters", "expandFunctionDefinitions", "expandInitialAssignments"] .=> Ref(Dict{String,String}()),
)
