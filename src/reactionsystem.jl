""" ReactionSystem constructor """
function ModelingToolkit.ReactionSystem(model::Model; kwargs...)  # Todo: requires unique parameters (i.e. SBML must have been imported with localParameter promotion in libSBML)
    checksupport(model)
    model = make_extensive(model)
    rxs = mtk_reactions(model)
    t = Catalyst.DEFAULT_IV
    species = [create_var(k) for k in keys(model.species)]
    params = vcat([create_param(k) for k in keys(model.parameters)], [create_param(k) for k in keys(model.compartments)])
    ReactionSystem(rxs,t,species,params; kwargs...)
end

""" ReactionSystem constructor """
function ModelingToolkit.ReactionSystem(sbmlfile::String; kwargs...)
    model = readSBML(sbmlfile)
    ReactionSystem(model; kwargs...)
end

""" ODESystem constructor """
function ModelingToolkit.ODESystem(model::Model; kwargs...)
    rs = ReactionSystem(model; kwargs...)
    model = make_extensive(model)  # PL: consider making `make_extensive!` to avoid duplicate calling in ReactionSystem and here
    u0map = get_u0(model)
    parammap = get_paramap(model)
    defaults = Dict(vcat(u0map, parammap))
    convert(ODESystem, rs, defaults=defaults)
end

""" ODESystem constructor """
function ModelingToolkit.ODESystem(sbmlfile::String; kwargs...)
    model = readSBML(sbmlfile)
    ODESystem(model; kwargs...)
end

""" ODEProblem constructor """
function ModelingToolkit.ODEProblem(model::Model,tspan;kwargs...)  # PL: Todo: add u0 and parameters argument
    odesys = ODESystem(model)
    ODEProblem(odesys, [], tspan; kwargs...)
end

""" ODEProblem constructor """
function ModelingToolkit.ODEProblem(sbmlfile::String,tspan;kwargs...)  # PL: Todo: add u0 and parameters argument
    odesys = ODESystem(sbmlfile)
    ODEProblem(odesys, [], tspan; kwargs...)
end

""" Check if conversion to ReactionSystem is possible """
function checksupport(model)
    for (k, v) in model.reactions
        if v.reversible
            throw(AssertionError("Reaction $(k) is reversible. Its `kineticLaw` cannot safely be converted to forward and reverse `MTK.Reaction.rate`s."))
        end
    end
    return
end

""" Convert intensive to extensive expressions """
function make_extensive(model)
    model = to_initial_amounts(model)
    model = to_extensive_math!(model)
    model
end

""" Convert initial_concentration to initial_amount """
function to_initial_amounts(model::Model)
    model = deepcopy(model)
    for specie in values(model.species)
        if isnothing(specie.initial_amount)
            compartment = model.compartments[specie.compartment]
            specie.initial_amount = (specie.initial_concentration[1] * compartment.size, "")
            specie.initial_concentration = nothing
        end
    end
    model
end

""" Convert intensive to extensive mathematical expression """
function to_extensive_math!(model::SBML.Model)
    function conv(x::SBML.MathApply)
        SBML.MathApply(x.fn, SBML.Math[conv(x) for x in x.args])
    end
    function conv(x::SBML.MathIdent)
        x_new = x
        if x.id in keys(model.species)
            specie = model.species[x.id]
            if !specie.only_substance_units
                compartment = model.compartments[specie.compartment]
                x_new = SBML.MathApply("*", SBML.Math[
                            SBML.MathVal(compartment.size),
                            x])
            specie.only_substance_units = true
            end
        end
        x_new
    end
    # conv(x::SBML.MathVal) = x
    conv(x::SBML.MathLambda) =
        throw(DomainError(x, "can't translate lambdas to extensive units"))
    for reaction in values(model.reactions)
        reaction.kinetic_math = conv(reaction.kinetic_math)
    end
    model
end

""" Get dictonary to change types in kineticLaw """
function _get_substitutions(model)
    subsdict = Dict()
    for k in keys(model.species)
        push!(subsdict, Pair(Num(Variable(Symbol(k))),create_var(k)))
    end
    for k in keys(model.parameters)
        push!(subsdict, Pair(Num(Variable(Symbol(k))),create_param(k)))
    end
    for k in keys(model.compartments)
        push!(subsdict, Pair(Num(Variable(Symbol(k))),create_param(k)))
    end
    subsdict
end

""" Convert SBML.Reaction to MTK.Reaction """
function mtk_reactions(model::Model)
    subsdict = _get_substitutions(model)
    rxs = []
    for reaction in values(model.reactions)
        reactants = Num[]
        rstoich = Num[]
        products = Num[]
        pstoich = Num[]
        for (k,v) in reaction.stoichiometry
            if v < 0
                push!(reactants, create_var(k))
                push!(rstoich, -v)
            elseif v > 0
                push!(products, create_var(k))
                push!(pstoich, v)
            else
                @error("Stoichiometry of $k must be non-zero")
            end
        end
        if (length(reactants)==0) reactants = nothing; rstoich = nothing end
        if (length(products)==0) products = nothing; pstoich = nothing end
        symbolic_math = convert(Num, reaction.kinetic_math)
        kl = substitute(symbolic_math, subsdict)
        push!(rxs, ModelingToolkit.Reaction(kl,reactants,products,rstoich,pstoich;only_use_rate=true))
    end
    rxs
end

""" Extract u0map from Model """
function get_u0(model)
    u0map = []
    for (k,v) in model.species
        push!(u0map,Pair(create_var(k), v.initial_amount[1]))
    end
    u0map
end

""" Extract paramap from Model """
function get_paramap(model)
    paramap = Pair{Num, Float64}[]
    for (k,v) in model.parameters
        push!(paramap,Pair(create_param(k),v))
    end
    for (k,v) in model.compartments
        push!(paramap,Pair(create_param(k),v.size))
    end
    paramap
end

create_var(x) = Num(Variable(Symbol(x))).val
function create_param(x)
    p = Sym{Real}(Symbol(x))
    ModelingToolkit.toparam(p)
end
