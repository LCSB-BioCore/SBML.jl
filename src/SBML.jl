module SBML

include("readsbml.jl")

using CxxWrap
using SBML_jll

@wrapmodule(libsbml)

export getLibSBMLDottedVersion,
    readSBML

function __init__()
  @initcxx
end

end # module
