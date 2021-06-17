
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

function Base.convert(::Type{Num}, x::SBML.Math; mapping = default_symbolics_mapping)
    conv(x::SBML.MathApply) = eval(allowed_sym(x.fn, mapping))(conv.(x.args)...)
    conv(x::SBML.MathIdent) = Num(Variable(Symbol(x.id))).val
    conv(x::SBML.MathVal) = x.val
    conv(x::SBML.MathLambda) = throw(DomainError(x, "can't translate lambdas to symbolics"))
    conv(x)
end
