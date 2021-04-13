
"""
    ast_is(ast::VPtr, what::Symbol)::Bool

Helper for quickly recognizing kinds of ASTs
"""
ast_is(ast::VPtr, what::Symbol)::Bool = ccall(sbml(what), Cint, (VPtr,), ast) != 0

"""
    parse_math(ast::VPtr)::Math

This attempts to parse out a decent Julia-esque ([`Math`](@ref) AST from a
pointer to `ASTNode_t`.
"""
function parse_math(ast::VPtr)::Math
    if ast_is(ast, :ASTNode_isName) || ast_is(ast, :ASTNode_isConstant)
        return MathIdent(get_string(ast, :ASTNode_getName))
    elseif ast_is(ast, :ASTNode_isConstantNumber)
        return MathVal(ccall_sbml(:ASTNode_getValue), Cdouble, (VPtr,), ast)
    elseif ast_is(ast, :ASTNode_isFunction)
        return MathApply(
            get_string(ast, :ASTNode_getName),
            [
                parse_math(ccall(sbml(:ASTNode_getChild), VPtr, (VPtr, Cuint), ast, i - 1))
                for i = 1:ccall(sbml(:ASTNode_getNumChildren), Cuint, (VPtr,), ast)
            ],
        )
    elseif ast_is(ast, :ASTNode_isOperator)
        return MathApply(
            string(Char(ccall(sbml(:ASTNode_getCharacter), Cchar, (VPtr,), ast))),
            [
                parse_math(ccall(sbml(:ASTNode_getChild), VPtr, (VPtr, Cuint), ast, i - 1))
                for i = 1:ccall(sbml(:ASTNode_getNumChildren), Cuint, (VPtr,), ast)
            ],
        )
    else
        @warn "unsupported math element at $ast"
        return MathIdent("?unsupported?")
    end
end
