"""
    Plug(id[; dual = false])
    Plug(i, j, ...[; dual = false])

Represents a physical index related to a [`Site`](@ref) with an annotation of input or output.
"""
Base.@kwdef struct Plug{S} <: Link
    site::S
    isdual::Bool = false
end

Plug(site::S; kwargs...) where {S} = Plug{S}(; site, kwargs...)
Plug(id::Int; kwargs...) = Plug(CartesianSite(id); kwargs...)
Plug(@nospecialize(id::NTuple{N,Int}); kwargs...) where {N} = Plug(CartesianSite(id); kwargs...)
Plug(@nospecialize(id::Vararg{Int,N}); kwargs...) where {N} = Plug(CartesianSite(id); kwargs...)
Plug(@nospecialize(id::CartesianIndex); kwargs...) = Plug(CartesianSite(id); kwargs...)

Base.show(io::IO, x::Plug) = print(io, "plug<$(site(x))$(isdual(x) ? "'" : "")>")

isplug(_) = false
isplug(::Tag) = false
isplug(::Plug) = true

isdual(x::Plug) = x.isdual

site(x::Plug) = x.site
plug(x::Plug) = x

is_plug_equal(x, y) = isplug(x) && isplug(y) ? plug(x) == plug(y) : false

Base.adjoint(x::Plug) = Plug(site(x); isdual=(!isdual(x)))

"""
    plug"i,j,...[']"

Constructs a [`Site`](@ref) object with the given coordinates. The coordinates are given as a comma-separated list of integers.
Optionally, a trailing `'` can be added to indicate that the site is a dual site (i.e. an "input").

See also: [`@site_str`](@ref)
"""
macro plug_str(str)
    isdual = endswith(str, '\'')
    str = chopsuffix(str, "'")
    site_expr = var"@site_str"(Core.LineNumberNode(0, ""), QuantumTags, str)
    return :(Plug($(site_expr); isdual=($isdual)))
end
