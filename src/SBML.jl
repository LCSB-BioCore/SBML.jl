module SBML

using CxxWrap

# TODO: load the libsbml project from the BinaryBuilder destination
@wrapmodule("./libsbml-cxxwrapjl.so")

function __init__()
  @initcxx
end

end # module
