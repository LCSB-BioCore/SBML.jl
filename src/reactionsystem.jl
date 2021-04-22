using Catalyst, ModelingToolkit, Symbolics

# module SBML
# struct Model end
# struct Reaction end
# struct Compartment end
# struct Species end
# end

""" ReactionSystem constructor """
function ModelingToolkit.ReactionSystem(model::Model; kwargs...)  # Todo: requires unique parameters (i.e. SBML must have been imported with localParameter promotion in libSBML)
    model = make_extensive(model)
    model = expand_reversible(model)
    rxs = mtk_reaction.(model.reactions)
    t = DEFAULT_IV
    species = [create_var(k) for k in keys(model.species)]
    params = vcat([create_var(k) for k in keys(model.parameters)], [create_par(k) for k in keys(model.compartments)])
    ReactionSystem(rxs,t,species,params; kwargs...)
end

""" ReactionSystem constructor """
function ModelingToolkit.ReactionSystem(sbmlfile::String; kwargs...)
    model = readSBML(sbmlfile)
    ReactionSystem(model; kwargs...)
end

""" ODESystem constructor """
function ModelingToolkit.ODESystem(model::Model; kwargs...)
    rs = ReactionSystem(model, kwargs...)
    u0map = get_u0(model)
    parammap = get_paramap(model)
    defaults = vcat(u0map, parammap)
    convert(ODESystem, rs, defaults=defaults)
end

""" ODESystem constructor """
function ModelingToolkit.ODESystem(sbmlfile::String; kwargs...)
    model = readSBML(sbmlfile)
    ODESystem(model; kwargs...)
end

""" ODEProblem constructor """
function ModelingToolkit.ODEProblem(model::Model,tspan;kwargs...)  # PL: Todo: add u0 and parameters argument
    odesys = ODESystem(model,kwargs...)
    ODEProblem(odesys, [], tspan)
end

""" ODEProblem constructor """
function ModelingToolkit.ODEProblem(sbmlfile::String,tspan;kwargs...)  # PL: Todo: add u0 and parameters argument
    odesys = ODESystem(sbmlfile;kwargs...)
    ODEProblem(odesys, [], tspan)
end

""" Convert intensive to extensive expressions """
function make_extensive(model)
    model = to_initial_amounts(model)
    model = to_extensive_math(model)
    model  # Todo: For spevies with `hOSU=false` multiply all occurences in mathematical expressions by compartment size.
           # Also convert species initialConcentrations to initialAmounts
end

""" Convert initial_concentration to initial_amount """
function to_initial_amounts(model::Model)
    model = deepcopy(model)
    for specie in model.species
        if isequal(specie.initial_amount, nothing)
            compartment = model.compartments[specie.compartment]
            specie.initial_amount = specie.initial_concentration * compartment.size
            specie.initial_concentration = nothing
        end
    end
    model
end

""" Convert intensive to extensive mathematical expression """
function to_extensive_math(model::Model)
    model = deepcopy(model)
    for reaction in model.reactions
        km = reaction.kinetic_math
        reaction.km = ...  # PL: Todo: @Anand can you multiply species with `hOSU=true` with their compartment volume?
    end
    reaction
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
    # PL: Todo: @Anand: can you convert kinetic_math to Symbolic expression. Perhaps it would actually better if kinetic Math would be a Symbolics.jl expression rather than of type `Math`? But Mirek wants `Math`, I think.
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
