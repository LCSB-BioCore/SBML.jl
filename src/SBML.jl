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
export set_level_and_version, libsbml_convert, convert_simplify_math, convert_promote_expand

# Read a file at precompile time, to improve time-to-first `readSBML`.
writeSBML(readSBML(joinpath(@__DIR__, "..", "test", "data", "Dasgupta2020-written.xml")))

end # module
