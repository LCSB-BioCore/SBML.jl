
"""
    set_level_and_version(level, version, report_severities = ["Fatal", "Error"])

A converter to pass into [`readSBML`](@ref) that enforces certain SBML level
and version.  `report_severities` switches on and off reporting of certain
errors; see the documentation of [`get_error_messages`](@ref) for details.
"""
set_level_and_version(level, version, report_severities = ["Fatal", "Error"]) =
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
        report_severities,
    )

"""
    libsbml_convert(conversion_options::Vector{Pair{String, Dict{String, String}}}, report_severities = ["Fatal", "Error"])

A converter that runs the SBML conversion routine, with specified conversion
options. The argument is a vector of pairs to allow specifying the order of
conversions.  `report_severities` switches on and off reporting of certain
errors; see the documentation of [`get_error_messages`](@ref) for details.
"""
libsbml_convert(
    conversion_options::AbstractVector{<:Pair{String,<:AbstractDict{String,String}}},
    report_severities = ["Fatal", "Error"],
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
                # `SBMLDocument_convert` returns `LIBSBML_OPERATION_SUCCESS` (== 0) for a
                # successful operation, something else when there is a failure.
                iszero(ccall(sbml(:SBMLDocument_convert), Cint, (VPtr, VPtr), doc, props)),
                doc,
                ErrorException("Conversion returned errors"),
                report_severities,
            )
        end
    end

"""
    libsbml_convert(converter::String, report_severities = ["Fatal", "Error"]; kwargs...)

Quickly construct a single run of a `libsbml` converter from keyword arguments.
`report_severities` switches on and off reporting of certain errors; see the
documentation of [`get_error_messages`](@ref) for details.

# Example
```
readSBML("example.xml", libsbml_convert("stripPackage", package="layout"))
```
"""
libsbml_convert(converter::String, report_severities = ["Fatal", "Error"]; kwargs...) =
    libsbml_convert([
        converter => Dict{String,String}(string(k) => string(v) for (k, v) in kwargs),
    ],
                    report_severities)

"""
    convert_simplify_math

Shortcut for [`libsbml_convert`](@ref) that expands functions, local
parameters, and initial assignments in the SBML document.
"""
const convert_simplify_math = libsbml_convert(
    ["promoteLocalParameters", "expandFunctionDefinitions", "expandInitialAssignments"] .=> Ref(Dict{String,String}()),
)
