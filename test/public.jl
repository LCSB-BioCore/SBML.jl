const PUBLIC_NOT_EXPORTED = [
    :Maybe,
    :VPtr,
    :SBMLObject,
    :UnitPart,
    :UnitDefinition,
    :GeneProductAssociation,
    :GPARef,
    :GPAAnd,
    :GPAOr,
    :Math,
    :MathVal,
    :MathIdent,
    :MathConst,
    :MathTime,
    :MathAvogadro,
    :MathApply,
    :MathLambda,
    :CVTerm,
    :Parameter,
    :Compartment,
    :SpeciesReference,
    :Reaction,
    :Rule,
    :AlgebraicRule,
    :AssignmentRule,
    :RateRule,
    :Constraint,
    :Species,
    :GeneProduct,
    :FunctionDefinition,
    :EventAssignment,
    :Trigger,
    :Objective,
    :Event,
    :Member,
    :Group,
    :Model,
    :Version,
    :interpret_math,
    :default_function_mapping,
    :default_constants,
    :unitful,
    :extensive_kinetic_math,
    :fbc_flux_objective,
    :kinetic_flux_objective,
    :get_compartment_size,
    :initial_amounts,
    :initial_concentrations,
    :isfreein,
    :seemsdefined,
    :test_suite_url,
]

@testset "Public API" begin
    @testset "$name is defined and documented" for name in PUBLIC_NOT_EXPORTED
        @test isdefined(SBML, name)
        @test haskey(Docs.meta(SBML), Docs.Binding(SBML, name))
    end

    if VERSION >= v"1.11"
        @testset "$name is public and unexported" for name in PUBLIC_NOT_EXPORTED
            @test Base.ispublic(SBML, name)
            @test !Base.isexported(SBML, name)
        end

        @testset "every name reachable by `using SBML` is public" begin
            for name in names(SBML)
                name === :SBML && continue
                @test Base.ispublic(SBML, name)
            end
        end
    end
end
