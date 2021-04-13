
"""
    parseMath(ast::VPtr)::Math

This attempts to parse out a decent Julia-esque ([`Math`](@ref) AST from a
pointer to `ASTNode_t`.
"""
function parseMath(ast::VPtr)::Math
    @info "got $ast"
    MathIdent("placeholder")
end
