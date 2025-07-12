module QuantumTags

export Site, @site, @site_str, is_site_equal, issite
export CartesianSite, NamedSite
export Bond, @bond, @bond_str, is_bond_equal, isbond
export SimpleBond
export Plug, @plug, @plug_str, is_plug_equal, isplug
export SimplePlug
export isdual, isinput, isoutput

abstract type Tag end

# TODO checkout whether this is a good idea
Base.copy(x::Tag) = x

abstract type Site <: Tag end

issite(::T) where {T} = issite(T)
issite(::Type) = false
issite(::Type{<:Site}) = true

struct LayerSite{S<:Site,L} <: Site
    id::S
    layer::L
end

site(x::LayerSite) = site(x.id)
layer(x::LayerSite) = x.layer

Base.show(io::IO, x::LayerSite) = print(io, "$(x.id) at $(x.layer)")
Base.show(io::IO, x::LayerSite{S,L}) where {S,L<:Symbol} = print(io, "$(x.id) at :$(x.layer)")
Base.show(io::IO, x::LayerSite{S,L}) where {S,L<:AbstractString} = print(io, "$(x.id) at \"$(x.layer)\"")

abstract type Link <: Tag end

islink(::T) where {T} = islink(T)
islink(::Type) = false
islink(::Type{<:Link}) = true

include("Site.jl")
include("Bond.jl")
include("Plug.jl")

# e.g. a `Bond` on a layer
struct LayerLink{Li<:Link,La} <: Link
    link::Li
    layer::La
end

bond(x::LayerLink) = bond(x.link)
layer(x::LayerLink) = x.layer

# e.g. a closed plug between two layers
struct InterLayerLink{S,IL} <: Link
    site::S
    cut::IL
end

site(x::InterLayerLink) = site(x.site)
layers(x::InterLayerLink) = x.cut

end # module QuantumTags
