using MacroTools

abstract type Site <: Tag end

issite(::T) where {T} = issite(T)
issite(::Type) = false
issite(::Type{<:Site}) = true

site(x::Site) = x

is_site_equal(x, y) = isequal(site(x), site(y))

dispatch_site_constructor(x::Site) = x
dispatch_site_constructor(x::Symbol) = NamedSite(x)
dispatch_site_constructor(x::AbstractString) = NamedSite(x)
dispatch_site_constructor(x::Int) = CartesianSite(x)
dispatch_site_constructor(x::NTuple{N,Int}) where {N} = CartesianSite(x)
dispatch_site_constructor(x::Vararg{Int,N}) where {N} = CartesianSite(x)
dispatch_site_constructor(x::Base.CartesianIndex) = CartesianSite(Tuple(x))

macro site(expr)
    expr = MacroTools.postwalk(expr) do x
        Meta.isexpr(x, :$) ? esc(only(x.args)) : x
    end

    return :(dispatch_site_constructor($expr))
end

"""
    site"i,j,..."

Constructs a [`CartesianSite`](@ref) object with the given coordinates. The coordinates are given as a comma-separated list of integers.
"""
macro site_str(str)
    expr = Meta.parse(str)
    esc(:($@site $expr))
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

struct LayerSite{S<:Site,L<:Layer} <: Site
    site::S
    layer::L
end

LayerSite(site, layer) = LayerSite(site, Layer(layer))

site(x::LayerSite) = site(x.site)
layer(x::LayerSite) = layer(partition(x))
partition(x::LayerSite) = x.layer

Base.show(io::IO, x::LayerSite) = print(io, "$(x.site) at $(repr(layer(x)))")
