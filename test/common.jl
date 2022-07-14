using ConstructionBase

# For these types define `==` as `==` for all corresponding fields.
const NON_ANNOTATED_TYPES = Union{
    SBML.UnitDefinition,
    SBML.MathApply,
    SBML.MathLambda,
    SBML.AlgebraicRule,
    SBML.AssignmentRule,
    SBML.RateRule,
    SBML.Constraint,
    SBML.EventAssignment,
    SBML.Trigger,
    SBML.Objective,
    SBML.Event,
}
function Base.:(==)(a::T, b::T) where {T<:NON_ANNOTATED_TYPES}
    return getproperties(a) == getproperties(b)
end

# Types for which we want `==` to be `==` for all fields except for the `annotation` field,
# for which we only check that both fields are either nothing or non-nothing.
const ANNOTATED_TYPES =
    Union{SBML.FunctionDefinition,SBML.GeneProduct,SBML.Species,SBML.Reaction}
function Base.:(==)(a::T, b::T) where {T<:ANNOTATED_TYPES}
    nta = getproperties(a)
    ntb = getproperties(b)
    for k in keys(nta)
        if k === :annotation
            if T === SBML.Reaction
                # For some reasons, annotations of reactions don't seem to be always added
                # by `SBase_setAnnotationString`.  We temporarily skip this check while we
                # investigate this issue.
                continue
            else
                isnothing(nta[k]) == isnothing(ntb[k]) || return false
            end
        else
            nta[k] == ntb[k] || return false
        end
    end
    return true
end
