using ModelingToolkit, Symbolics

allowed_funs = Dict(
    "+" => :+,
    "-" => :-,
    "*" => :*,
    "/" => :/,
    #TODO add translations of SBML functions to Julia
)

allowed_sym(x) = haskey(allowed_funs,x) ? allowed_funs[x] : DomainError(x,"Unknown SBML function")

function SBML2Symbolics(x::Math)
    conv(x::SBML.MathApply) =
        eval(allowed_sym(x.fn))(conv.(x.args)...)
    conv(x::SBML.MathIdent) =
        Symbolics.Variable(Symbol(x.id))
    conv(x::SBML.MathVal) = x.val
    conv(x::SBML.MathLambda) =
        throw(DomainError(x, "can't translate lambdas to symbolics"))
    conv(x)
end
