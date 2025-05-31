module QuantumTags

using Compat: @compat

@compat public Tag

export Site, CartesianSite, issite, site, @site_str, is_site_equal
export Link, islink
export Bond, isbond, bond, @bond_str, hassite, sites
export Plug, isplug, plug, isdual, @plug_str, is_plug_equal

abstract type Tag end

# TODO checkout whether this is a good idea
Base.copy(x::Tag) = x

# Site interface
abstract type Site <: Tag end

issite(_) = false
issite(::Tag) = false
issite(::Site) = true

is_site_equal(x, y) = issite(x) && issite(y) ? site(x) == site(y) : false

function site end
site(x::Site) = x

"""
    site"i,j,..."

Constructs a [`CartesianSite`](@ref) object with the given coordinates. The coordinates are given as a comma-separated list of integers.
"""
macro site_str(str)
    expr = Meta.parse(str)

    # shortcut for 1-dim sites (e.g. `site"1"`)
    if expr isa Int
        return :(CartesianSite($expr))
    elseif expr isa Symbol
        return :(CartesianSite($(esc(expr))))
    elseif Meta.isexpr(expr, :tuple)
        return :(CartesianSite($(map(esc, expr.args)...)))
    else
        throw(ArgumentError("Invalid site string"))
    end
end

"""
    CartesianSite(id)
    CartesianSite(i, j, ...)

Represents a physical site in a Cartesian coordinate system.
"""
struct CartesianSite{N} <: Site
    id::NTuple{N,Int}
end

CartesianSite(site::CartesianSite) = site
CartesianSite(id::Int) = CartesianSite((id,))
CartesianSite(id::Vararg{Int,N}) where {N} = CartesianSite(id)
CartesianSite(id::Base.CartesianIndex) = CartesianSite(Tuple(id))

Base.isless(a::CartesianSite, b::CartesianSite) = a.id < b.id
Base.ndims(::CartesianSite{N}) where {N} = N

Base.show(io::IO, x::CartesianSite) = print(io, "$(x.id)")

Core.Tuple(x::CartesianSite) = x.id
Base.CartesianIndex(x::CartesianSite) = CartesianIndex(Tuple(x))

# Bond interface
abstract type Link <: Tag end

islink(_) = false
islink(::Tag) = false
islink(::Link) = true

"""
    Bond(src, dst)

Represents a bond between two [`Site`](@ref) objects.
"""
struct Bond{A,B} <: Link
    src::A
    dst::B
end

# required for set-like equivalence to work on dictionaries (i.e. )
Base.hash(bond::Bond, h::UInt) = hash(bond.src, h) ⊻ hash(bond.dst, h)
Base.:(==)(a::Bond, b::Bond) = a.src == b.src && a.dst == b.dst || a.src == b.dst && a.dst == b.src

"""
    bond"i,j,...-k,l,..."

Constructs a [`Bond`](@ref) object.
[`Site`](@ref)s are given as a comma-separated list of integers, and source and destination sites are separated by a `-`.
"""
macro bond_str(str)
    m = match(r"([\w,]+)[-]([\w,]+)", str)
    @assert length(m.captures) == 2
    src = m.captures[1]
    dst = m.captures[2]
    src_expr = var"@site_str"(Core.LineNumberNode(0, ""), QuantumTags, src)
    dst_expr = var"@site_str"(Core.LineNumberNode(0, ""), QuantumTags, dst)
    return :(Bond($src_expr, $dst_expr))
end

isbond(_) = false
isbond(::Tag) = false
isbond(::Bond) = true

bond(x::Bond) = x

Base.show(io::IO, x::Bond) = print(io, "$(x.src) <=> $(x.dst)")

hassite(bond::Bond, x) = x == site(bond.src) || x == site(bond.dst)
sites(bond::Bond) = (site(bond.src), site(bond.dst))

Core.Pair(e::Bond) = e.src => e.dst
Core.Tuple(e::Bond) = (e.src, e.dst)

function Base.getindex(bond::Bond, i::Int)
    if i == 1
        return bond.src
    elseif i == 2
        return bond.dst
    else
        throw(BoundsError(bond, i))
    end
end

function Base.iterate(bond::Bond, state=0)
    if state == 0
        (bond.src, 1)
    elseif state == 1
        (bond.dst, 2)
    else
        nothing
    end
end

Base.IteratorSize(::Type{<:Bond}) = Base.HasLength()
Base.length(::Bond) = 2
Base.IteratorEltype(::Type{Bond{L}}) where {L} = Base.HasEltype()
Base.eltype(::Bond{L}) where {L} = L
Base.isdone(::Bond, state) = state == 2

Base.first(bond::Bond) = bond.src
Base.last(bond::Bond) = bond.dst

# Plug interface
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

isplug(_) = false
isplug(::Tag) = false
isplug(::Plug) = true
isdual(x::Plug) = x.isdual

site(x::Plug) = x.site
plug(x::Plug) = x

is_plug_equal(x, y) = isplug(x) && isplug(y) ? plug(x) == plug(y) : false

Base.adjoint(x::Plug) = Plug(site(x); isdual=!isdual(x))

Base.show(io::IO, x::Plug) = print(io, "$(site(x))$(isdual(x) ? "'" : "")")

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
    return :(Plug($(site_expr); isdual=$isdual))
end

end # module QuantumTags
