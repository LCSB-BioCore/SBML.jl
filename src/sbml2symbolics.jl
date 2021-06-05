using ModelingToolkit, Symbolics

@register factorial(x)
@register ceil(x)

function parse_piecewise(val, cond, other)
    println((val, cond, other))
    println(typeof(cond))
    () -> cond ? val : other
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
    "piecewise" => SBML.parse_piecewise,
    #TODO add translations of SBML functions to Julia
)

allowed_sym(x) = haskey(allowed_funs,x) ? allowed_funs[x] : throw(DomainError(x,"Unknown SBML function"))

function Base.convert(::Type{Num}, x::Math)
    conv(x::SBML.MathApply) =
        eval(allowed_sym(x.fn))(conv.(x.args)...)
    conv(x::SBML.MathIdent) =
        Symbolics.Variable(Symbol(x.id))
    conv(x::SBML.MathVal) = x.val
    conv(x::SBML.MathLambda) =
        throw(DomainError(x, "can't translate lambdas to symbolics"))
    conv(x)
end
