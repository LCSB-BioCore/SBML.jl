
"""
$(TYPEDSIGNATURES)

Get the version of the used SBML library in Julia version format.
"""
function Version()::VersionNumber
    VersionNumber(unsafe_string(ccall(sbml(:getLibSBMLDottedVersion), Cstring, ())))
end
