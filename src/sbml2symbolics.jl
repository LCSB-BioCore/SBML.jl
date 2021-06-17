
@register Base.factorial(x)  # Todo: remove this line once factorial is registered per default

function parse_piecewise(val, cond, other)
    IfElse.ifelse(cond, val, other)
end

allowed_funs = Dict(
    # Operators    
    "+" => :+,
    "-" => :-,
    "*" => :*,
    "/" => :/,
    "power" => :^,

    # Relational functions
    "lt" => :<,
    "leq" => :<=,
    "geq" => :>=,
    "gt" => :>,
    
    # Other
    "factorial" => :factorial,
    "ceiling" => :ceil,
    "floor" => :floor,
    "piecewise" => SBML.parse_piecewise,
    #TODO add further translations of SBML functions to Julia
)

allowed_sym(x) = haskey(allowed_funs,x) ? allowed_funs[x] : throw(DomainError(x,"Unknown SBML function"))

function Base.convert(::Type{Num}, x::SBML.Math)
    conv(x::SBML.MathApply) =
        eval(allowed_sym(x.fn))(conv.(x.args)...)
    conv(x::SBML.MathIdent) =
        Num(Variable(Symbol(x.id))).val
    conv(x::SBML.MathVal) = x.val
    conv(x::SBML.MathLambda) =
        throw(DomainError(x, "can't translate lambdas to symbolics"))
    conv(x)
end
