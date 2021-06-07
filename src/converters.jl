
"""
    convert_level_and_version(level, version)

A converter to pass into [`readSBML`](@ref) that enforces certain SBML level
and version.
"""
convert_level_and_version(level, version) =
    doc -> begin
        ccall(
            sbml(:SBMLDocument_setLevelAndVersion),
            Cint,
            (VPtr, Cint, Cint),
            doc,
            level,
            version,
        )
    end

"""
    libsbml_convert(conversion_options::Vector{Pair{String, Dict{String, String}}})

A converter that runs the SBML conversion routine, with specified conversion
options. The argument is a vector of pairs to allow specifying the order of
conversions.
"""
libsbml_convert(conversion_options::Vector{Pair{String,Dict{String,String}}}) =
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
            ccall(sbml(:SBMLDocument_convert), Cint, (VPtr, VPtr), doc, props)
        end
    end

"""
    convert_simplify_math

Shortcut for [`libsbml_convert`](@ref) that expands functions, local
parameters, and initial assignments in the SBML document.
"""
convert_simplify_math = libsbml_convert(
    ["promoteLocalParameters", "expandFunctionDefinitions", "setLevelAndVersion"] .=>
        Dict(),
)
