
#include "jlcxx/jlcxx.hpp"
#include "versions.hpp"

JLCXX_MODULE
define_julia_module(jlcxx::Module &mod)
{
  define_sbml_versions(mod);
}
