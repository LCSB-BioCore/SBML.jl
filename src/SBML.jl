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

# Read a file at precompile time, to improve time-to-first `readSBML`.
# Skip on 32-bit: SBML_jll/libsbml has returned NULL C strings during model
# walks on i686 (ArgumentError: cannot convert NULL to string).
if Sys.WORD_SIZE == 64
    writeSBML(readSBML(joinpath(@__DIR__, "..", "test", "data", "Dasgupta2020-written.xml")))
end

end # module
