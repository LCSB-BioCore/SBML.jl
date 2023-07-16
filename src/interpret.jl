
# some helper functions for interpreting SBML math

function sbmlPiecewise(args...)
    if length(args) == 1
        args[1]
    elseif length(args) >= 3
        IfElse.ifelse(args[2], args[1], sbmlPiecewise(args[3:end]...))
    else
        throw(DomainError(args, "malformed piecewise SBML function"))
    end
end

sbmlNeq(a, b) = !isequal(a, b)
function sbmlRelational(op)
    _iter(x, y) = op(x, y)
    _iter(x, y, args...) = IfElse.ifelse(op(x, y), _iter(y, args...), op(x, y))
    _iter
end

sbmlLog(x) = sbmlLog(10, x)
sbmlLog(base, x) = log(base, x)

sbmlPower(x::Integer, y::Integer) = x^float(y)
sbmlPower(x, y) = x^y
sbmlRoot(x) = sqrt(x)
sbmlRoot(power, x) = x^(1 / power)

sbmlRateOf(x) = throw(ErrorException("`rateOf' function mapping not defined"))

"""
$(TYPEDSIGNATURES)

Default mapping of SBML function names to Julia functions, represented as a
dictionary from Strings (SBML names) to functions.

The default mapping only contains the basic SBML functions that are
unambiguously represented in Julia; it is supposed to be extended by the user
if more functions need to be supported.
"""
const default_function_mapping = Dict{String,Any}(
    "*" => *,
    "+" => +,
    "-" => -,
    "/" => /,
    "abs" => abs,
    "and" => &,
    "arccos" => acos,
    "arccosh" => acosh,
    "arccot" => acot,
    "arccoth" => acoth,
    "arccsc" => acsc,
    "arccsch" => acsch,
    "arcsec" => asec,
    "arcsech" => asech,
    "arcsin" => asin,
    "arcsinh" => asinh,
    "arctan" => atan,
    "arctanh" => atanh,
    "ceiling" => ceil,
    "cos" => cos,
    "cosh" => cosh,
    "cot" => cot,
    "coth" => coth,
    "csc" => csc,
    "csch" => csch,
    "eq" => sbmlRelational(isequal),
    "exp" => exp,
    "factorial" => factorial,
    "floor" => floor,
    "geq" => sbmlRelational(>=),
    "gt" => sbmlRelational(>),
    "leq" => sbmlRelational(<=),
    "ln" => log,
    "log" => sbmlLog,
    "lt" => sbmlRelational(<),
    "neq" => sbmlRelational(sbmlNeq),
    "not" => !,
    "or" => |,
    "piecewise" => sbmlPiecewise,
    "power" => sbmlPower,
    "rateOf" => sbmlRateOf,
    "root" => sbmlRoot,
    "sech" => sech,
    "sec" => sec,
    "sinh" => sinh,
    "sin" => sin,
    "tanh" => tanh,
    "tan" => tan,
    "xor" => xor,
)

allowed_sym(x, allowed_funs) =
    haskey(allowed_funs, x) ? allowed_funs[x] :
    throw(DomainError(x, "Unknown SBML function"))

"""
$(TYPEDSIGNATURES)

A dictionary of default constants filled in place of SBML Math constants in the
function conversion.
"""
const default_constants = Dict{String,Any}(
    "true" => true,
    "false" => false,
    "pi" => pi,
    "e" => exp(1),
    "exponentiale" => exp(1),
    "avogadro" => 6.02214076e23,
)

"""
$(TYPEDSIGNATURES)

Recursively interpret SBML.[`Math`](@ref) type. This can be used to relatively
easily traverse and evaluate the SBML math, or translate it into any custom
representation, such as `Expr` or the `Num` of Symbolics.jl (see the SBML test
suite for examples).

By default, the function can convert SBML constants, values and function
applications, but identifiers, time values and lambdas are not mapped and throw
an error. Similarly SBML function `rateOf` is undefined, users must to supply
their own definition of `rateOf` that uses the correct derivative.
"""
function interpret_math(
    x::SBML.Math;
    map_apply = (x::SBML.MathApply, interpret::Function) ->
        SBML.default_function_mapping[x.fn](interpret.(x.args)...),
    map_const = (x::SBML.MathConst) -> default_constants[x.id],
    map_ident = (x::SBML.MathIdent) ->
        throw(ErrorException("identifier mapping not defined")),
    map_lambda = (x::SBML.MathLambda, interpret::Function) ->
        throw(ErrorException("lambda function mapping not defined")),
    map_time = (x::SBML.MathTime) -> throw(ErrorException("time mapping not defined")),
    map_avogadro = (x::SBML.MathAvogadro) -> map_ident(SBML.MathIdent(x.id)),
    map_value = (x::SBML.MathVal) -> x.val,
)
    interpret(x::SBML.MathApply) = map_apply(x, interpret)
    interpret(x::SBML.MathConst) = map_const(x)
    interpret(x::SBML.MathIdent) = map_ident(x)
    interpret(x::SBML.MathLambda) = map_lambda(x, interpret)
    interpret(x::SBML.MathTime) = map_time(x)
    interpret(x::SBML.MathAvogadro) = map_avogadro(x)
    interpret(x::SBML.MathVal) = map_value(x)

    interpret(x)
end
