
"""
    Maybe{X}

Type shortcut for "`X` or nothing" or "nullable `X`" in javaspeak. Name
got inspired by our functional friends.
"""
const Maybe{X} = Union{Nothing,X}

"""
    VPtr

A convenience wrapper for "any" (C `void`) pointer.
"""
const VPtr = Ptr{Cvoid}
