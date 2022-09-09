
# Conversion to symbolics
symbolicsRateOf(x) = Symbolics.Differential(convert(Num, MathTime("t")))(x)

symbolics_mapping = Dict(SBML.default_function_mapping..., "rateOf" => symbolicsRateOf)

map_symbolics_time_ident(x) = begin
    sym = Symbol(x.id)
    Symbolics.unwrap(first(@variables $sym))
end

const interpret_as_num(x::SBML.Math) = SBML.interpret_math(
    x;
    map_apply = (x::SBML.MathApply, interpret::Function) ->
        Num(symbolics_mapping[x.fn](interpret.(x.args)...)),
    map_const = (x::SBML.MathConst) -> Num(SBML.default_constants[x.id]),
    map_ident = map_symbolics_time_ident,
    map_lambda = (_, _) ->
        throw(ErrorException("Symbolics.jl does not support lambda functions")),
    map_time = map_symbolics_time_ident,
    map_value = (x::SBML.MathVal) -> Num(x.val),
)

@testset "Symbolics compatibility" begin

    test = SBML.MathApply(
        "piecewise",
        SBML.Math[
            SBML.MathVal(123),
            SBML.MathApply(
                "lt",
                SBML.Math[SBML.MathVal(2), SBML.MathVal(1), SBML.MathVal(0)],
            ),
            SBML.MathVal(456),
        ],
    )

    @test isequal(interpret_as_num(test), 456)

    @variables A B C D Time

    test = SBML.MathApply(
        "*",
        SBML.Math[
            SBML.MathApply(
                "+",
                SBML.Math[
                    SBML.MathApply(
                        "*",
                        SBML.Math[SBML.MathIdent("A"), SBML.MathIdent("B")],
                    ),
                    SBML.MathApply(
                        "-",
                        SBML.Math[SBML.MathApply(
                            "*",
                            SBML.Math[SBML.MathIdent("C"), SBML.MathIdent("D")],
                        )],
                    ),
                ],
            ),
            SBML.MathTime("Time"),
        ],
    )

    @test isequal(interpret_as_num(test), (A * B - C * D) * Time)
end
