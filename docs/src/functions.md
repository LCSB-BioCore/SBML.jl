
## What counts as public API

A name is public if it is exported, or if it is declared `public`. On Julia
1.11 and newer both cases answer `true` to `Base.ispublic(SBML, name)`, which
is the authoritative check. Anything else — including some parser and math
helpers that this reference still renders, such as the
[internal math helpers](#Internal-math-helpers) — may change in any release.

Much of the public API is deliberately *not* exported, so that `using SBML`
does not bring generic names such as `Model`, `Species` or `Version` into your
namespace. Reach those through the module instead: `SBML.Model`,
`SBML.MathApply`, `SBML.extensive_kinetic_math`, and so on.

Julia has no field-level visibility, so a public struct type also makes its
documented fields (listed under each type below) part of the public API.

# Data types

## Helper types

```@autodocs
Modules = [SBML]
Pages = ["types.jl"]
```

## Model data structures

```@autodocs
Modules = [SBML]
Pages = ["structs.jl"]
```

# Base functions

```@autodocs
Modules = [SBML]
Pages = ["SBML.jl"]
```

## Loading, writing and versioning

```@autodocs
Modules = [SBML]
Pages = ["readsbml.jl", "writesbml.jl", "version.jl"]
```

## `libsbml` representation converters

The converters are intended to be used as parameters of [`readSBML`](@ref).

```@autodocs
Modules = [SBML]
Pages = ["converters.jl"]
```

# Helper functions

## Data accessors

```@autodocs
Modules = [SBML]
Pages = ["utils.jl"]
```

## Units support

```@autodocs
Modules = [SBML]
Pages = ["unitful.jl"]
```

## Math interpretation

```@autodocs
Modules = [SBML]
Pages = ["interpret.jl"]
```

### Internal math helpers

```@autodocs
Modules = [SBML]
Pages = ["math.jl"]
```
