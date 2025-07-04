module QuantumTags

using MacroTools

export Site, @site, @site_str, is_site_equal, issite
export CartesianSite, NamedSite
export Bond, @bond, @bond_str, is_bond_equal, isbond
export Plug, @plug, @plug_str, is_plug_equal, isplug
export isdual, isinput, isoutput

abstract type Tag end

# TODO checkout whether this is a good idea
Base.copy(x::Tag) = x

abstract type Site <: Tag end

issite(_) = false
issite(::Tag) = false
issite(::Site) = true

is_site_equal(x, y) = issite(x) && issite(y) ? site(x) == site(y) : false

function site end
site(x::Site) = x

dispatch_site_constructor(x::Site) = x
dispatch_site_constructor(x::Symbol) = NamedSite(x)
dispatch_site_constructor(x::AbstractString) = NamedSite(x)
dispatch_site_constructor(x::Int) = CartesianSite(x)
dispatch_site_constructor(x::NTuple{N,Int}) where {N} = CartesianSite(x)
dispatch_site_constructor(x::Vararg{Int,N}) where {N} = CartesianSite(x)
dispatch_site_constructor(x::Base.CartesianIndex) = CartesianSite(Tuple(x))

"""
    site"i,j,..."

Constructs a [`CartesianSite`](@ref) object with the given coordinates. The coordinates are given as a comma-separated list of integers.
"""
macro site_str(str)
    expr = Meta.parse(str)
    esc(:(@site $expr))
end

macro site(expr)
    expr = MacroTools.postwalk(expr) do x
        Meta.isexpr(x, :$) ? esc(only(x.args)) : x
    end

    return :(dispatch_site_constructor($expr))
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
CartesianSite(id::NTuple{N}) where {N} = CartesianSite{N}(id)
CartesianSite(id::Int) = CartesianSite((id,))
CartesianSite(id::Vararg{Int,N}) where {N} = CartesianSite(id)
CartesianSite(id::Base.CartesianIndex) = CartesianSite(Tuple(id))

Base.show(io::IO, x::CartesianSite) = print(io, "site<$(x.id)>")

Base.isless(a::CartesianSite, b::CartesianSite) = a.id < b.id
Base.ndims(::CartesianSite{N}) where {N} = N

Core.Tuple(x::CartesianSite) = x.id
Base.CartesianIndex(x::CartesianSite) = CartesianIndex(Tuple(x))

"""
    NamedSite(name)

Represents a site identified by a name. `name` must be a `AbstractString` or `Symbol`.
"""
struct NamedSite{S<:Union{<:AbstractString,Symbol}} <: Site
    id::S
end

Base.string(x::NamedSite) = string(x.id)
Base.show(io::IO, x::NamedSite{<:AbstractString}) = print(io, "site<\"$(x.id)\">")
Base.show(io::IO, x::NamedSite{Symbol}) = print(io, "site<:$(x.id)>")

# """
#     MultiSite(a, b, ...)

# Represents a site that is a combination of multiple sites. The sites are given as a comma-separated list of [`Site`](@ref) objects.
# """
# const MultiSite{N,S<:Site} = Site{NTuple{N,S}}

# MultiSite(sites::Vararg{S,N}) where {N,S<:Site} = MultiSite{N,S}(sites)
# MultiSite(sites::S...) where {S<:Site} = MultiSite{length(sites),S}(sites)

# is_site_equal(a::MultiSite, b::MultiSite) = length(a.id) == length(b.id) && all(is_site_equal.(a.id, b.id))
# hassite(site::MultiSite, x) = any(is_site_equal(x, s) for s in site.id)

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

Base.show(io::IO, x::Bond) = print(io, "bond<$(x.src) ⟷ $(x.dst)>")

# required for set-like equivalence to work on dictionaries (i.e. )
bond_hash(bond::Bond, h::UInt) = hash(bond.src, h) ⊻ hash(bond.dst, h)
function is_bond_equal(a::Bond, b::Bond)
    is_site_equal(a.src, b.src) && is_site_equal(a.dst, b.dst) ||
        is_site_equal(a.src, b.dst) && is_site_equal(a.dst, b.src)
end

"""
    bond"i,j,...-k,l,..."

Constructs a [`Bond`](@ref) object.
[`Site`](@ref)s are given as a comma-separated list of integers, and source and destination sites are separated by a `-`.
"""
macro bond_str(str)
    expr = Meta.parse(str)
    if !(Meta.isexpr(expr, :call) && expr.args[1] == :-)
        throw(
            ArgumentError(
                "Bond string must be in the form 'src-dst', where src and dst are site strings acceptable for @site_str.",
            ),
        )
    end

    src, dst = expr.args[2:end]
    return esc(:(Bond(@site($src), @site($dst))))
end

isbond(_) = false
isbond(::Tag) = false
isbond(::Bond) = true

bond(x::Bond) = x

hassite(bond::Bond, x) = is_site_equal(bond.src, x) || is_site_equal(bond.dst, x)
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

end # module QuantumTags
