
default_symbolics_mapping = Dict(
    "+" => :+,
    "-" => :-,
    "*" => :*,
    "/" => :/,
    "power" => :^,
    "lt" => :<,
    "leq" => :<=,
    "geq" => :>=,
    "gt" => :>,
    "ceiling" => :ceil,
    "floor" => :floor,
    "piecewise" => :(Core.ifelse),
    #TODO extend this in the future
)

allowed_sym(x, allowed_funs) =
    haskey(allowed_funs, x) ? allowed_funs[x] :
    throw(DomainError(x, "Unknown SBML function"))

"""
    Base.convert(
        ::Type{Num},
        x::SBML.Math;
        mapping = default_symbolics_mapping,
        convert_time = (x::SBML.MathTime) -> Num(Variable(Symbol(x.id))).val,
    )

Convert SBML.[`Math`](@ref) to `Num` type Symbolics package. The conversion of
functions can be customized by supplying a custom mapping to symbols; if
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
)
    conv(x::SBML.MathApply) = eval(allowed_sym(x.fn, mapping))(conv.(x.args)...)
    conv(x::SBML.MathTime) = convert_time(x)
    conv(x::SBML.MathIdent) = Num(Variable(Symbol(x.id))).val
    conv(x::SBML.MathVal) = x.val
    conv(x::SBML.MathLambda) = throw(DomainError(x, "can't translate lambdas to symbolics"))
    conv(x)
end
