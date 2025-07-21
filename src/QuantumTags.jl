module QuantumTags

using MacroTools

export Site, @site, @site_str, is_site_equal, issite
export CartesianSite, NamedSite
export Bond, @bond, @bond_str, is_bond_equal, isbond
export SimpleBond
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
    Bond <: Link

Represents a bond between two [`Site`](@ref) objects.

## Interface

  - `isbond`
  - `bond`
  - `sites`
  - `hassite`
  - `is_bond_equal`
"""
abstract type Bond <: Link end

isbond(::T) where {T} = isbond(T)
isbond(::Type) = false
isbond(::Type{<:Bond}) = true

bond(b::Bond) = b

hassite(bond::Bond, _site) = any(Base.Fix1(is_site_equal, _site), sites(bond))

# required for set-like equivalence to work on dictionaries (i.e. )
@deprecate bond_hash(bond::Bond, h::UInt) hash(bond, h)

function is_bond_equal(a::Bond, b::Bond)
    s1a, s2a = sites(a)
    s1b, s2b = sites(b)
    is_site_equal(s1a, s1b) && is_site_equal(s2a, s2b) || is_site_equal(s1a, s2b) && is_site_equal(s2a, s1b)
end

Core.Pair(bond::Bond) = Pair(sites(bond)...)
Core.Tuple(bond::Bond) = Tuple(sites(bond))

Base.IteratorSize(::Type{<:Bond}) = Base.HasLength()
Base.length(bond::Bond) = length(sites(bond))
Base.IteratorEltype(::Type{<:Bond}) = Base.HasEltype()
Base.eltype(bond::Bond) = eltype(sites(bond))
Base.isdone(bond::Bond, state) = isdone(bond, state)

Base.first(bond::Bond) = first(sites(bond))
Base.last(bond::Bond) = last(sites(bond))

Base.getindex(bond::Bond, i) = getindex(sites(bond), i)
Base.iterate(bond::Bond) = iterate(sites(bond))
Base.iterate(bond::Bond, state) = iterate(sites(bond), state)

"""
    SimpleBond(src, dst)

Represents a bond between two [`Site`](@ref) objects.

!!! info

    In order to use `SimpleBond` whithin a set-like context (e.g. as a key in a dictionary), it implements `isequal` and `hash` for set-like equivalence.
    This means that `isequal(bond"1-2", bond"2-1")` and `hash(bond"1-2", bond"2-1")` are `true`, but `bond"1-2" == bond"2-1"` is `false`.
"""
struct SimpleBond{S} <: Bond
    sites::NTuple{2,S}
end

SimpleBond(a, b) = SimpleBond((a, b))
@deprecate Bond(a::Site, b::Site) SimpleBond(a, b) true

Base.show(io::IO, x::SimpleBond) = print(io, "bond<$(x.sites[1]) ⟷ $(x.sites[2])>")
Base.isequal(a::SimpleBond, b::SimpleBond) = is_bond_equal(a, b)

# NOTE taken from `set.jl`: this is like `hash` method for `AbstractSet`
const hashs_seed = UInt === UInt64 ? 0x852ada37cfe8e0ce : 0xcfe8e0ce
function Base.hash(b::Bond, h::UInt)
    hv = hashs_seed
    hv ⊻= hash(b.sites[1])
    hv ⊻= hash(b.sites[2])
    hash(hv, h)
end

hassite(bond::SimpleBond, x) = is_site_equal(bond.sites[1], x) || is_site_equal(bond.sites[2], x)
sites(bond::SimpleBond) = site.(bond.sites)

dispatch_bond_constructor(a, b) = SimpleBond(a, b)

"""
    bond"i-j"
    bond"(i,j,...)-(k,l,...)"

Constructs a [`SimpleBond`](@ref) object.
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
    return esc(:($dispatch_bond_constructor(@site($src), @site($dst))))
end

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
