
"""
$(TYPEDSIGNATURES)

Helper for quickly recognizing kinds of ASTs
"""
ast_is(ast::VPtr, what::Symbol)::Bool = ccall(sbml(what), Cint, (VPtr,), ast) != 0

"""
$(TYPEDSIGNATURES)

Recursively parse all children of an AST node.
"""
parse_math_children(ast::VPtr)::Vector{Math} = [
    parse_math(ccall(sbml(:ASTNode_getChild), VPtr, (VPtr, Cuint), ast, i - 1)) for
    i = 1:ccall(sbml(:ASTNode_getNumChildren), Cuint, (VPtr,), ast)
]



# Mapping of AST node type value subset to relational operations. Depends on
# `ASTNodeType.h` (also see below the case with AST_NAME_TIME)
const relational_opers = Dict{Int32,String}(
    308 => "eq",
    309 => "geq",
    310 => "gt",
    311 => "leq",
    312 => "lt",
    313 => "neq",
)
# Inverse mapping, needed for creating `ASTNode_t` pointers from `MathApply` objects.
const inv_relational_opers = Dict(val => key for (key, val) in relational_opers)

function relational_oper(t::Int)
    haskey(relational_opers, t) ||
        throw(DomainError(t, "Unknown ASTNodeType value for relational operator"))
    relational_opers[t]
end

# Mapping of AST node type value subset to mathematical operations. Depends on
# `ASTNodeType.h` (also see below the case with AST_NAME_TIME)
const math_opers = Dict{Int32,String}(43 => "+", 45 => "-", 42 => "*", 47 => "/", 94 => "^")
# Inverse mapping, needed for creating `ASTNode_t` pointers from `MathApply` objects.
const inv_math_opers = Dict(val => key for (key, val) in math_opers)

# Mapping of AST node type value subset to logical operations. Depends on
# `ASTNodeType.h` (also see below the case with AST_NAME_TIME)
const logical_opers =
    Dict{Int32,String}(304 => "and", 305 => "not", 306 => "or", 307 => "xor")
# Inverse mapping, needed for creating `ASTNode_t` pointers from `MathApply` objects.
const inv_logical_opers = Dict(val => key for (key, val) in logical_opers)

# Mapping of AST node type value subset to mathematical functions. Depends on
# `ASTNodeType.h` (also see below the case with AST_NAME_TIME)
const math_funcs = Dict{Int32,String}(
    269 => "abs",
    270 => "arccos",
    271 => "arccosh",
    272 => "arccot",
    273 => "arccoth",
    274 => "arccsc",
    275 => "arccsch",
    276 => "arcsec",
    277 => "arcsech",
    278 => "arcsin",
    279 => "arcsinh",
    280 => "arctan",
    281 => "arctanh",
    282 => "ceiling",
    283 => "cos",
    284 => "cosh",
    285 => "cot",
    286 => "coth",
    287 => "csc",
    288 => "csch",
    289 => "delay",
    290 => "exp",
    291 => "factorial",
    292 => "floor",
    293 => "ln",
    294 => "log",
    295 => "piecewise",
    296 => "power",
    297 => "root",
    298 => "sec",
    299 => "sech",
    300 => "sin",
    301 => "sinh",
    302 => "tan",
    303 => "tanh",
)
# Inverse mapping, needed for creating `ASTNode_t` pointers from `MathApply` objects.
const inv_math_funcs = Dict(val => key for (key, val) in math_funcs)
# Everybody wants to be a map!
const all_inv_function_mappings =
    merge(inv_relational_opers, inv_math_opers, inv_logical_opers, inv_math_funcs)

"""
$(TYPEDSIGNATURES)

This attempts to parse out a decent Julia-esque [`Math`](@ref) AST from a
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
    elseif ast_is(ast, :ASTNode_isRational)
        return MathVal(
            ccall(sbml(:ASTNode_getNumerator), Cint, (VPtr,), ast) //
            ccall(sbml(:ASTNode_getDenominator), Cint, (VPtr,), ast),
        )
    elseif ast_is(ast, :ASTNode_isReal)
        return MathVal(ccall(sbml(:ASTNode_getReal), Cdouble, (VPtr,), ast))
    elseif ast_is(ast, :ASTNode_isFunction)
        return MathApply(get_string(ast, :ASTNode_getName), parse_math_children(ast))
    elseif ast_is(ast, :ASTNode_isOperator)
        return MathApply(
            string(Char(ccall(sbml(:ASTNode_getCharacter), Cchar, (VPtr,), ast))),
            parse_math_children(ast),
        )
    elseif ast_is(ast, :ASTNode_isRelational)
        return MathApply(
            relational_oper(Int(ccall(sbml(:ASTNode_getType), Cint, (VPtr,), ast))),
            parse_math_children(ast),
        )
    elseif ast_is(ast, :ASTNode_isLogical)
        return MathApply(get_string(ast, :ASTNode_getName), parse_math_children(ast))
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
        @warn "unsupported math element found"
        return MathIdent("?unsupported?")
    end
end

## Inverse of `parse_math`: create `ASTNode_t` pointers from `Math` objects.

function get_astnode_ptr(m::MathTime)::VPtr
    astnode = ccall(sbml(:ASTNode_create), VPtr, ())
    ccall(sbml(:ASTNode_setName), Cint, (VPtr, Cstring), astnode, m.id)
    # Same comment as in `parse_math`: this constant must be kept in-sync with
    # the value of `AST_NAME_TIME` in `libsbml/src/sbml/math/ASTNodeType.h`.
    ccall(sbml(:ASTNode_setType), Cint, (VPtr, Cuint), astnode, 262)
    ccall(sbml(:ASTNode_canonicalize), Cint, (VPtr,), astnode)
    return astnode
end

function get_astnode_ptr(m::Union{MathIdent,MathConst})::VPtr
    m.id in ("?invalid?", "?unsupported?") &&
        error("Cannot get a pointer for `MathIdent` with ID \"$(m.id)\"")
    astnode = ccall(sbml(:ASTNode_create), VPtr, ())
    ccall(sbml(:ASTNode_setName), Cint, (VPtr, Cstring), astnode, m.id)
    ccall(sbml(:ASTNode_canonicalize), Cint, (VPtr,), astnode)
    return astnode
end

function get_astnode_ptr(m::MathVal{<:Integer})::VPtr
    astnode = ccall(sbml(:ASTNode_create), VPtr, ())
    ccall(sbml(:ASTNode_setInteger), Cint, (VPtr, Clong), astnode, m.val)
    ccall(sbml(:ASTNode_canonicalize), Cint, (VPtr,), astnode)
    return astnode
end

function get_astnode_ptr(m::MathVal{<:Rational})::VPtr
    astnode = ccall(sbml(:ASTNode_create), VPtr, ())
    # Note: this can be in principle a lossy reconstruction as `Rational`s in
    # Julia are automatically simplified (e.g., 5//10 -> 1//2).
    ccall(
        sbml(:ASTNode_setRational),
        Cint,
        (VPtr, Clong, Clong),
        astnode,
        numerator(m.val),
        denominator(m.val),
    )
    ccall(sbml(:ASTNode_canonicalize), Cint, (VPtr,), astnode)
    return astnode
end

function get_astnode_ptr(m::MathVal{<:Real})::VPtr
    astnode = ccall(sbml(:ASTNode_create), VPtr, ())
    ccall(sbml(:ASTNode_setReal), Cint, (VPtr, Cdouble), astnode, m.val)
    ccall(sbml(:ASTNode_canonicalize), Cint, (VPtr,), astnode)
    return astnode
end

function get_astnode_ptr(m::MathApply)::VPtr
    astnode = ccall(sbml(:ASTNode_create), VPtr, ())
    # Set the name
    ccall(sbml(:ASTNode_setName), Cint, (VPtr, Cstring), astnode, m.fn)
    # Set the type
    if m.fn in keys(all_inv_function_mappings)
        ccall(
            sbml(:ASTNode_setType),
            Cint,
            (VPtr, Cuint),
            astnode,
            all_inv_function_mappings[m.fn],
        )
    else
        ccall(sbml(:ASTNode_setType), Cint, (VPtr, Cuint), astnode, 268) # 268 == AST_FUNCTION
    end
    # Add children
    for child in m.args
        child_ptr = get_astnode_ptr(child)
        ccall(sbml(:ASTNode_addChild), Cint, (VPtr, VPtr), astnode, child_ptr)
    end
    ccall(sbml(:ASTNode_canonicalize), Cint, (VPtr,), astnode)
    return astnode
end

function get_astnode_ptr(m::MathLambda)::VPtr
    astnode = ccall(sbml(:ASTNode_create), VPtr, ())
    # All arguments
    for child in MathIdent.(m.args)
        child_ptr = get_astnode_ptr(child)
        ccall(sbml(:ASTNode_addChild), Cint, (VPtr, VPtr), astnode, child_ptr)
    end
    # Add the body
    body = get_astnode_ptr(m.body)
    ccall(sbml(:ASTNode_addChild), Cint, (VPtr, VPtr), astnode, body)
    # Set the type
    ccall(sbml(:ASTNode_setType), Cint, (VPtr, Cuint), astnode, 267) # 267 == AST_LAMBDA
    # Done
    return astnode
end
