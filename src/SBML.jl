module SBML

using SBML_jll, Libdl, Pkg
using SparseArrays

include("structs.jl")
include("version.jl")
include("readsbml.jl")
include("math.jl")
include("utils.jl")

sbml = (sym::Symbol) -> dlsym(SBML_jll.libsbml_handle, sym)

export SBMLVersion,
    readSBML, getS, getLBs, getUBs, getOCs

end # module
