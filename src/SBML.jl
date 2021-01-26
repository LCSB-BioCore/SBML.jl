module SBML

using CxxWrap
using SBML_jll

function __init__()
  @initcxx
end

@wrapmodule(libsbml)

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
