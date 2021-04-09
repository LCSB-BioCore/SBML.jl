### This file suggest to possibilities of adapting the types to accommodate also dynamic models

############# Version 1 #################
abstract type Reaction end
abstract type Species end
abstract type SbmlModel end

struct DynamicSpecies <: Species
    initialAmout::Float64
    # etc
end

struct FbaSpecies <: Species
    # etc
end

struct DynamicReaction <: Reaction
    kineticLaw::String
    # etc
end

struct FbaReaction <: Reaction
    lb::Float64
    ub::Float64
    # etc
end

struct DynamicReactionModel <: SbmlModel
    species::Dict(String,DynamicSpecies)
    reactions::Dict(String,DynamicReaction)
    # etc
end

struct FbaModel <: SbmlModel
    species::Dict(String,FbaSpecies)
    reactions::Dict(String,FbaReaction)
    # etc
end

############# Version 2 #################

const Maybe{X} = Union{Nothing,X}

struct Reaction
    kineticLaw::Maybe{String}
    stoichiometry::Dict{String,Float64}
    lb::Maybe{Tuple{Float64,String}}
    ub::Maybe{Tuple{Float64,String}}
    oc::Maybe{Float64}
    gene_product_association::Maybe{GeneProductAssociation}
    notes::Maybe{String}
    annotation::Maybe{String}
    Reaction(s, l, u, o, as, n = nothing, an = nothing) = new(s, l, u, o, as, n, an)

end

struct Species
    initialAmount::Maybe{Float}
    name::String
    compartment::Union{String,Tuple{String,Float64}}
    formula::Maybe{String}
    charge::Maybe{Int}
    notes::Maybe{String}
    annotation::Maybe{String}
    Species(na, co, f, ch, no = nothing, a = nothing) = new(na, co, f, ch, no, a)

end

struct Model
    parameters::Dict{String,Float64}
    units::Dict{String,Vector{UnitPart}}
    compartments::Vector{String}
    species::Dict{String,Species}
    reactions::Dict{String,Reaction}
    gene_products::Dict{String,GeneProduct}
    notes::Maybe{String}
    annotation::Maybe{String}
    Model(p, u, c, s, r, g, n = nothing, a = nothing) = new(p, u, c, s, r, g, n, a)
end