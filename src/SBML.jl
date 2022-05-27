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
include("unitful.jl")
include("utils.jl")

"""
$(TYPEDSIGNATURES)

A shortcut that loads a function symbol from `SBML_jll`.
"""
sbml(sym::Symbol)::VPtr = dlsym(SBML_jll.libsbml_handle, sym)

export readSBML, readSBMLFromString, stoichiometry_matrix, flux_bounds, flux_objective
export set_level_and_version, libsbml_convert, convert_simplify_math

end # module
