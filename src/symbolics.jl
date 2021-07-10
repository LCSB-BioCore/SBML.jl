
"""
    default_symbolics_mapping :: Dict{String,Any}

Default mapping of SBML function names to Julia functions, represented as a
dictionary from Strings (SBML names) to anything `eval`uable as Julia&Symbolics
functions, such as symbols and expressions.

The default mapping only contains the basic SBML functions that are
unambiguously represented in Julia; it is supposed to be extended by the user
if more functions need to be supported.
"""
const default_symbolics_mapping = Dict{String,Any}(
    "*" => :*,
    "+" => :+,
    "-" => :-,
    "/" => :/,
    "abs" => :abs,
    "arccos" => :acos,
    "arccosh" => :acosh,
    "arccot" => :acot,
    "arccoth" => :acoth,
    "arccsc" => :acsc,
    "arccsch" => :acsch,
    "arcsec" => :asec,
    "arcsech" => :asech,
    "arcsin" => :asin,
    "arcsinh" => :asinh,
    "arctan" => :atan,
    "arctanh" => :atanh,
    "ceiling" => :ceil,
    "cos" => :cos,
    "cosh" => :cosh,
    "cot" => :cot,
    "coth" => :coth,
    "csc" => :csc,
    "csch" => :csch,
    "eq" => :isequal,
    "exp" => :exp,
    "factorial" => :factorial,
    "floor" => :floor,
    "geq" => :>=,
    "gt" => :>,
    "leq" => :<=,
    "ln" => :log,
    "log" => :sbmlLog,
    "lt" => :<,
    "piecewise" => :(sbmlPiecewise),
    "power" => :^,
    "root" => :sbmlRoot,
    "sech" => :sech,
    "sec" => :sec,
    "sinh" => :sinh,
    "sin" => :sin,
    "tanh" => :tanh,
    "tan" => :tan,
)

function sbmlPiecewise(args...)
    if length(args) == 1
        args[1]
    elseif length(args) >= 3
        Core.ifelse(args[2], args[1], sbmlPiecewise(args[3:end]...))
    else
        throw(AssertionError("malformed piecewise SBML function"))
    end
end


sbmlLog(x) = log(x, 10)
sbmlLog(base, x) = log(base, x)

sbmlRoot(x) = sqrt(x)
sbmlRoot(power, x) = x^(1 / power)

allowed_sym(x, allowed_funs) =
    haskey(allowed_funs, x) ? allowed_funs[x] :
    throw(DomainError(x, "Unknown SBML function"))

"""
    const default_symbolics_constants::Dict{String, Any}

A dictionary of default constants filled in place of SBML Math constants in the
symbolics conversion.
"""
const default_symbolics_constants =
    Dict{String,Any}("true" => true, "false" => false, "pi" => pi, "e" => exp(1))

"""
    Base.convert(
        ::Type{Num},
        x::SBML.Math;
        mapping = default_symbolics_mapping,
        convert_time = (x::SBML.MathTime) -> Num(Variable(Symbol(x.id))).val,
        convert_const = (x::SBML.MathConst) -> Num(default_symbolics_constants[x.id]),
    )

Convert SBML.[`Math`](@ref) to `Num` type from Symbolics package. The
conversion of functions can be customized by supplying a custom mapping; if
nothing is supplied, [`default_symbolics_mapping`](@ref) that translates basic
functions to their Julia equivalents is assumed.

Translation of [`MathLambda`](@ref) is not supported by Symbolics.

[`MathTime`](@ref) is handled specially, the function from the argument
`convert_time` is called to possibly specify any desired behavior. By default,
it just creates a variable with the same name as the time variable name stored
in SBML.
"""
function Base.convert(
    ::Type{Num},
    x::SBML.Math;
    mapping = default_symbolics_mapping,
    convert_time = (x::SBML.MathTime) -> Num(Variable(Symbol(x.id))).val,
    convert_const = (x::SBML.MathConst) -> Num(default_symbolics_constants[x.id]),
)
    conv(x::SBML.MathApply) = eval(allowed_sym(x.fn, mapping))(conv.(x.args)...)
    conv(x::SBML.MathTime) = convert_time(x)
    conv(x::SBML.MathConst) = convert_const(x)
    conv(x::SBML.MathIdent) = Num(Variable(Symbol(x.id))).val
    conv(x::SBML.MathVal) = Num(x.val)
    conv(x::SBML.MathLambda) = throw(DomainError(x, "can't translate lambdas to symbolics"))
    conv(x)
end
