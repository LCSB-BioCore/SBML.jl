"""
$(DocStringExtensions.README)
"""
module SBML

using SBML_jll, Libdl

using DocStringExtensions
using IfElse
using SparseArrays
using Unitful

include("types.jl")
include("structs.jl")
include("version.jl")

include("converters.jl")
include("interpret.jl")
include("math.jl")
include("readsbml.jl")
include("writesbml.jl")
include("unitful.jl")
include("utils.jl")

"""
$(TYPEDSIGNATURES)

A shortcut that loads a function symbol from `SBML_jll`.
"""
sbml(sym::Symbol)::VPtr = dlsym(SBML_jll.libsbml_handle, sym)

export readSBML, readSBMLFromString, stoichiometry_matrix, flux_bounds, flux_objective
export writeSBML
export set_level_and_version,
    libsbml_convert, convert_simplify_math, convert_promotelocals_expandfuns

# The names below are documented API that is deliberately not exported, to keep
# `using SBML` from polluting the namespace with generic names like `Model`,
# `Parameter` or `Version`. Downstream packages are expected to reach them as
# `SBML.Model` etc., so they are declared `public`.
#
# `public` is a Julia 1.11 feature and this package still supports 1.6, so the
# declaration goes through `eval` behind a version guard; a bare `public ...`
# would be a syntax error on older versions. Julia has no field-level
# visibility, so for the struct types here the documented fields (rendered from
# `$(TYPEDFIELDS)`) are covered by the type being public.
@static if VERSION >= v"1.11"
    eval(
        Expr(
            :public,
            # types.jl
            :Maybe,
            :VPtr,
            # structs.jl
            :SBMLObject,
            :UnitPart,
            :UnitDefinition,
            :GeneProductAssociation,
            :GPARef,
            :GPAAnd,
            :GPAOr,
            :Math,
            :MathVal,
            :MathIdent,
            :MathConst,
            :MathTime,
            :MathAvogadro,
            :MathApply,
            :MathLambda,
            :CVTerm,
            :Parameter,
            :Compartment,
            :SpeciesReference,
            :Reaction,
            :Rule,
            :AlgebraicRule,
            :AssignmentRule,
            :RateRule,
            :Constraint,
            :Species,
            :GeneProduct,
            :FunctionDefinition,
            :EventAssignment,
            :Trigger,
            :Objective,
            :Event,
            :Member,
            :Group,
            :Model,
            # version.jl
            :Version,
            # interpret.jl
            :interpret_math,
            :default_function_mapping,
            :default_constants,
            # unitful.jl
            :unitful,
            # utils.jl
            :extensive_kinetic_math,
            :fbc_flux_objective,
            :kinetic_flux_objective,
            :get_compartment_size,
            :initial_amounts,
            :initial_concentrations,
            :isfreein,
            :seemsdefined,
            :test_suite_url,
        ),
    )
end

# Read a file at precompile time, to improve time-to-first `readSBML`.
writeSBML(readSBML(joinpath(@__DIR__, "..", "test", "data", "Dasgupta2020-written.xml")))

end # module
