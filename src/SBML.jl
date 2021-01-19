module SBML

using CxxWrap
using SBML_jll

@wrapmodule(libsbml)

# version tools
export getLibSBMLDependencyVersionOf,
    getLibSBMLDottedVersion,
    getLibSBMLVersion,
    getLibSBMLVersionString,
    isLibSBMLCompiledWith

function __init__()
  @initcxx
end

end # module
