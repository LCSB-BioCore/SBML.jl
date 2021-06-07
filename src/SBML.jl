module SBML

using SBML_jll, Libdl, Pkg
using SparseArrays

include("structs.jl")
include("version.jl")

include("readsbml.jl")
include("converters.jl")
include("math.jl")
include("utils.jl")

sbml = (sym::Symbol) -> dlsym(SBML_jll.libsbml_handle, sym)

export SBMLVersion, readSBML, getS, getLBs, getUBs, getOCs
export convert_level_and_version, libsbml_convert, convert_simplify_math

end # module
