using ConstructionBase

# For these types define `==` as `==` for all corresponding fields.
const NON_ANNOTATED_TYPES = Union{
    SBML.AlgebraicRule,
    SBML.AssignmentRule,
    SBML.Constraint,
    SBML.CVTerm,
    SBML.Event,
    SBML.EventAssignment,
    SBML.GeneProductAssociation,
    SBML.MathApply,
    SBML.MathLambda,
    SBML.Objective,
    SBML.RateRule,
    SBML.Trigger,
}
function Base.:(==)(a::T, b::T) where {T<:NON_ANNOTATED_TYPES}
    return getproperties(a) == getproperties(b)
end

# Types for which we want `==` to be `==` for all fields except for the `annotation` field,
# for which we only check that both fields are either nothing or non-nothing.
const ANNOTATED_TYPES = Union{
    SBML.Compartment,
    SBML.FunctionDefinition,
    SBML.GeneProduct,
    SBML.Group,
    SBML.Member,
    SBML.Model,
    SBML.Parameter,
    SBML.Reaction,
    SBML.Species,
    SBML.UnitDefinition,
}
function Base.:(==)(a::T, b::T) where {T<:ANNOTATED_TYPES}
    nta = getproperties(a)
    ntb = getproperties(b)
    for k in keys(nta)
        if k === :annotation
            isnothing(nta[k]) == isnothing(ntb[k]) || return false
        else
            nta[k] == ntb[k] || return false
        end
    end
    return true
end
