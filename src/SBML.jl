module SBML

using SBML_jll, Libdl, Pkg
using SparseArrays
using Symbolics

include("structs.jl")
include("version.jl")

include("readsbml.jl")
include("converters.jl")
include("math.jl")
include("utils.jl")
include("symbolics.jl")

sbml(sym::Symbol) = dlsym(SBML_jll.libsbml_handle, sym)

export SBMLVersion, readSBML, getS, getLBs, getUBs, getOCs
export set_level_and_version, libsbml_convert, convert_simplify_math

end # module
