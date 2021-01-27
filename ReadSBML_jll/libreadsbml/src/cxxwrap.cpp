
#include "jlcxx/jlcxx.hpp"
#include "versions.hpp"
#include "readsbml.hpp"

JLCXX_MODULE
define_julia_module(jlcxx::Module &mod)
{
  define_sbml_versions(mod);
  define_readsbml(mod);
}
