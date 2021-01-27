module SBML

using CxxWrap
using ReadSBML_jll

function __init__()
  @initcxx
end

@wrapmodule(libreadsbml)

include("readsbml.jl")

export getLibSBMLDottedVersion,
    readSBML,
    Model,
    UnitPart,
    Species,
    Reaction,
    getS,
    getLBs,
    getUBs,
    getOCs

end # module
