"""
    Plug <: Link

Represents a physical index related to a [`Site`](@ref) with an annotation of input or output.

## Interface

    - `isplug`
    - `plug`
    - `site`
    - `hassite`
    - `isdual`
    - `is_plug_equal`
    - `Base.adjoint`
    - `Base.reverse`
"""
abstract type Plug <: Link end

isplug(::T) where {T} = isplug(T)
isplug(::Type) = false
isplug(::Type{<:Plug}) = true

plug(p::Plug) = p

hassite(plug::Plug, _site) = is_site_equal(site(plug), _site)
function is_plug_equal(x, y)
    if !(isplug(x) && isplug(y))
        return false
    end
    return is_site_equal(site(x), site(y)) && isdual(x) == isdual(y)
end

function Base.show(io::IO, x::Plug)
    print(io, "plug<")
    print(io, site(x))
    isdual(x) && print(io, "'")
    print(io, ">")
end

"""
    plug"i,j,...[']"

Constructs a [`Site`](@ref) object with the given coordinates. The coordinates are given as a comma-separated list of integers.
Optionally, a trailing `'` can be added to indicate that the site is a dual site (i.e. an "input").

See also: [`@site_str`](@ref)
"""
macro plug_str(str)
    isdual = endswith(str, '\'')
    str = chopsuffix(str, "'")
    site_expr = _site_expr(Meta.parse(str))
    return :(SimplePlug($(site_expr); isdual=($isdual)))
end

"""
    SimplePlug(id[; dual = false])
    SimplePlug(i, j, ...[; dual = false])

Represents a physical index related to a [`Site`](@ref) with an annotation of input or output.
"""
Base.@kwdef struct SimplePlug{S} <: Plug
    site::S
    isdual::Bool = false
end

SimplePlug(site::S; kwargs...) where {S} = SimplePlug{S}(; site, kwargs...)
SimplePlug(id::Int; kwargs...) = SimplePlug(CartesianSite(id); kwargs...)
SimplePlug(@nospecialize(id::NTuple{N,Int}); kwargs...) where {N} = SimplePlug(CartesianSite(id); kwargs...)
SimplePlug(@nospecialize(id::Vararg{Int,N}); kwargs...) where {N} = SimplePlug(CartesianSite(id); kwargs...)
SimplePlug(@nospecialize(id::CartesianIndex); kwargs...) = SimplePlug(CartesianSite(id); kwargs...)
@deprecate Plug(args...; kwargs...) SimplePlug(args...; kwargs...) true

site(p::SimplePlug) = p.site
isdual(p::SimplePlug) = p.isdual

Base.adjoint(p::SimplePlug) = SimplePlug(site(p); isdual=(!isdual(p)))
Base.reverse(p::SimplePlug) = adjoint(p)

struct LayerPlug{P<:Plug,L<:Layer} <: Plug
    plug::P
    layer::L
end

LayerPlug(plug, layer) = LayerPlug(plug, Layer(layer))

isplug(x::LayerPlug) = isplug(x.plug)

site(x::LayerPlug) = LayerSite(site(x.plug), x.layer)
plug(x::LayerPlug) = plug(x.plug)
isdual(x::LayerPlug) = isdual(x.plug)

partition(x::LayerPlug) = layer(x)
layer(x::LayerPlug) = layer(x.layer)

Base.adjoint(x::LayerPlug) = LayerPlug(adjoint(x.plug), layer(x))
Base.reverse(x::LayerPlug) = LayerPlug(reverse(x.plug), layer(x))
