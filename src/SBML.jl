module SBML

using SBML_jll, Libdl
using SparseArrays
using Symbolics

include("structs.jl")
include("version.jl")

include("utils.jl")
include("readsbml.jl")
include("converters.jl")
include("math.jl")
include("symbolics.jl")

sbml(sym::Symbol) = dlsym(SBML_jll.libsbml_handle, sym)

export SBMLVersion, readSBML, getS, getLBs, getUBs, getOCs
export set_level_and_version, libsbml_convert, convert_simplify_math

end # module
