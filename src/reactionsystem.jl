create_var(x) = Num(Variable(Symbol(x)))
function create_param(x)
  p = Sym{Real}(Symbol(x))
  ModelingToolkit.toparam(p)
  p
end


""" ModelingToolkit.Reaction constructor """
function ModelingToolkit.Reaction(reaction::Reaction; only_use_rate=true)
    # pass
end


""" ReactionSystem constructor """
function ModelingToolkit.ReactionSystem(model::Model)
    rxs = [Reaction(reac...; only_use_rate=true) for reac in values(model.reactions)]
    t = Variable(:t)
    species = [create_var(spec) for spec in keys(model.species)]
    pars = [create_param(p) for p in keys(model.parameters)]
    comps = [create_param(c) for c in keys(model.compartments)]
    pc = vcat(pars,comps)
    ReactionSystem(rxs,t,species,pc)
end


""" ODESystem constructor """
function ModelingToolkit.ODESystem(model::Model)
    rs = ReactionSystem(model)
    u0map = [create_var(k) => v[2] for (k, v) in model.species]
    parammap = vcat([create_param(k) => v for (k,v) in model.parameters],
                    [create_param(k) => v for (k,v) in model.compartments])
    defaults = vcat(u0map, parammap)
    convert(ODESystem, rs, defaults=defaults)
end


""" ODEProblem constructor """
function ModelingToolkit.ODEProblem(model::Model,tspan)  # PL: Todo: add u0 and parameters argument
    odesys = ODESystem(model)
    ODEProblem(odesys, [], tspan)
end