using ModelingToolkit, Symbolics

allowed_funs = Dict(
    "+" => :+,
    "-" => :-,
    "*" => :*,
    "multiply" => :*,
    "/" => :/,
    "power" => :^,
    #TODO add translations of SBML functions to Julia
)

allowed_sym(x) = haskey(allowed_funs,x) ? allowed_funs[x] : DomainError(x,"Unknown SBML function")

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
