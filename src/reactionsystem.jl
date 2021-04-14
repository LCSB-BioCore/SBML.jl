using Catalyst, ModelingToolkit, Symbolics

# module SBML
# struct Model end
# struct Reaction end
# struct Compartment end
# struct Species end
# end

""" ReactionSystem constructor """
function ModelingToolkit.ReactionSystem(model::Model)  # Todo: requires unique parameters (i.e. SBML must have been imported with localParameter promotion in libSBML)
    model = make_extensive(model)
    model = expand_reversible(model)
    rxs = mtk_reaction.(model.reactions)
    t = DEFAULT_IV
    species = [create_var(k) for k in keys(model.species)]
    params = vcat([create_var(k) for k in keys(model.parameters)], [create_par(k) for k in keys(model.compartments)])
    ReactionSystem(rxs,t,species,params)
end

""" ReactionSystem constructor """
function ModelingToolkit.ReactionSystem(sbmlfile::String)
    model = readSBML(sbmlfile)
    ReactionSystem(model)
end

""" ODESystem constructor """
function ModelingToolkit.ODESystem(model::Model)
    rs = ReactionSystem(model)
    u0map = get_u0(model)
    parammap = get_paramap(model)
    defaults = vcat(u0map, parammap)
    convert(ODESystem, rs, defaults=defaults)
end

""" ODESystem constructor """
function ModelingToolkit.ODESystem(sbmlfile::String)
    model = readSBML(sbmlfile)
    ODESystem(model)
end

""" ODEProblem constructor """
function ModelingToolkit.ODEProblem(model::Model,tspan)  # Todo: add u0 and parameters argument
    odesys = ODESystem(model)
    ODEProblem(odesys, [], tspan)
end

""" ODEProblem constructor """
function ModelingToolkit.ODEProblem(sbmlfile::String,tspan)  # Todo: add u0 and parameters argument
    odesys = ODESystem(sbmlfile)
    ODEProblem(odesys, [], tspan)
end

""" Convert intensive to extensive expressions """
function make_extensive(model)
    model  # Todo: For spevies with `hOSU=false` divide all occurences in mathematical expressions by compartment size.
           # Also convert species initialConcentrations to initialAmounts
end

""" Expand reversible reactions to two reactions """
function expand_reversible(model)
    model  # Todo: convert all Reactions that are `reversible=true` to a forward and reverse reaction with `reversible=false`.
end

""" Convert SBML.Reaction to MTK.Reaction """
function mtk_reaction(reaction::SBML.Reaction)
    reactants = []
    rstoich = []
    products = []
    pstoich = []
    for (k,v) in reaction.stoichiometry
        if v < 0
            push!(reactants, create_var(k))
            push!(rstoich, -v)
        elseif v > 0
            push!(products, create_var(k))
            push!(pstoich, -v)
        else
            @error("Stoichiometry of $k must be non-zero")
        end
    end
    subsdict = _get_substitutions(model)
    # PL: Todo: convert kinetic_math to Symbolic MTK expression
    kl = substitute(reaction.kinetic_math, subsdict)  # PL: Todo: might need conversion of kinetic_math to Symbolic MTK expression
    ModelingToolkit.Reaction(reaction.kinetic_math,reactants,prodcts,rstoich,pstoich;only_use_rate=true)
end

""" Get dictonary to change types in kineticLaw """
function _get_substitution(model)
    subsdict = Dict()
    for k in keys(model.species)
        push!(substict, Pair(Num(Variable(Symbol(k))),create_var(k)))
    end
    for k in keys(model.parameters)
        push!(subsdict, Pair(Num(Variable(Symbol(k))),create_par(k)))
    end
    for k in keys(model.compartments)
        push!(subsdict, Pair(Num(Variable(Symbol(k))),create_par(k)))
    end
    subsdict
end

""" Extract u0map from Model """
function get_u0(model)
    u0map = []
    for (k,v) in model.species
        push!(Pair(create_var(k),vinitial_amount))
    end
    u0map
end

""" Extract paramap from Model """
function get_paramap(model)
    paramap = []
    for (k,v) in model.parameters
        push!(Pair(create_par(k),v))
    end
    for (k,v) in model.compartments
        push!(Pair(create_par(k),v.size))
    end
    paramap
end

create_var(x) = Num(Variable(Symbol(x)))
# # create_var(x, iv) = Num(Sym{FnType{Tuple{Real}}}(Symbol(x))(Variable(Symbol(iv)))).val
# # create_var(x, iv) = Num(Variable{Symbolics.FnType{Tuple{Any},Real}}(Symbol(x)))(Variable(Symbol(iv)))
create_param(x) = Num(Sym{ModelingToolkit.Parameter{Real}}(Symbol(x)))
