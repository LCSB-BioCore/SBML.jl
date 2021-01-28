
function SBMLVersion()
    VersionNumber(unsafe_string(ccall(sbml(:getLibSBMLDottedVersion), Cstring, ())))
end
