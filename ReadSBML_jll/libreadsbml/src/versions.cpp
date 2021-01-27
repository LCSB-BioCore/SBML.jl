
#include "versions.hpp"

#include <sbml/SBMLTypes.h>
#include <string>

inline static std::string
notnull_string(const char *s)
{
  if (s)
    return std::string(s);
  else
    return std::string();
}

JLCXX_MODULE
define_sbml_versions(jlcxx::Module &mod)
{
  mod.method("getLibSBMLDottedVersion",
             []() -> std::string { return getLibSBMLDottedVersion(); });
  mod.method("getLibSBMLVersionString",
             []() -> std::string { return getLibSBMLVersionString(); });
  mod.method("getLibSBMLVersion", []() { return getLibSBMLVersion(); });
  mod.method("isLibSBMLCompiledWith", [](const std::string &s) -> bool {
    return isLibSBMLCompiledWith(s.c_str());
  });
  mod.method("getLibSBMLDependencyVersionOf",
             [](const std::string &s) -> std::string {
               return notnull_string(getLibSBMLDependencyVersionOf(s.c_str()));
             });
}
