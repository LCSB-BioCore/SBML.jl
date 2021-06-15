
"""
    ast_is(ast::VPtr, what::Symbol)::Bool

Helper for quickly recognizing kinds of ASTs
"""
ast_is(ast::VPtr, what::Symbol)::Bool = ccall(sbml(what), Cint, (VPtr,), ast) != 0

"""
    parse_math_children(ast::VPtr)::Vector{Math}

Recursively parse all children of an AST node.
"""
parse_math_children(ast::VPtr)::Vector{Math} = [
    parse_math(ccall(sbml(:ASTNode_getChild), VPtr, (VPtr, Cuint), ast, i - 1)) for
    i = 1:ccall(sbml(:ASTNode_getNumChildren), Cuint, (VPtr,), ast)
]

"""
    parse_math(ast::VPtr)::Math

This attempts to parse out a decent Julia-esque ([`Math`](@ref) AST from a
pointer to `ASTNode_t`.
"""
function parse_math(ast::VPtr)::Math
    if ast_is(ast, :ASTNode_isName)
        if ccall(sbml(:ASTNode_getType), Cint, (VPtr,), ast) == 262
            # This is a special case checking for the value of "simulation
            # time" as defined by SBML. The constant `262` is the value of the
            # enum AST_NAME_TIME in `libsbml/src/sbml/math/ASTNodeType.h`,
            # needs to be kept up to date with the library (otherwise this
            # breaks).
            return MathTime(get_string(ast, :ASTNode_getName))
        else
            return MathIdent(get_string(ast, :ASTNode_getName))
        end
    elseif ast_is(ast, :ASTNode_isConstant)
        return MathConst(get_string(ast, :ASTNode_getName))
    elseif ast_is(ast, :ASTNode_isInteger)
        return MathVal(ccall(sbml(:ASTNode_getInteger), Cint, (VPtr,), ast))
    elseif ast_is(ast, :ASTNode_isReal)
        return MathVal(ccall(sbml(:ASTNode_getReal), Cdouble, (VPtr,), ast))
    elseif ast_is(ast, :ASTNode_isFunction) || ast_is(ast, :ASTNode_isRelational)
        return MathApply(get_string(ast, :ASTNode_getName), parse_math_children(ast))
    elseif ast_is(ast, :ASTNode_isOperator) || ast_is(ast, :ASTNode_isRelational)
        return MathApply(
            string(Char(ccall(sbml(:ASTNode_getCharacter), Cchar, (VPtr,), ast))),
            parse_math_children(ast),
        )
    elseif ast_is(ast, :ASTNode_isLambda)
        children = parse_math_children(ast)
        if !isempty(children)
            body = pop!(children)
            return MathLambda(broadcast((x::MathIdent) -> x.id, children), body)
        else
            @warn "invalid function definition found"
            return MathIdent("?invalid?")
        end
    else
        @warn "unsupported math element found: $(get_string(ast, :ASTNode_getName))"
        return MathIdent("?unsupported?")
    end
end
