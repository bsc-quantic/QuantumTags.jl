module QuantumTags

export Site, @site, @site_str, is_site_equal, issite
export CartesianSite, NamedSite
export Bond, @bond, @bond_str, is_bond_equal, isbond
export SimpleBond
export Plug, @plug, @plug_str, is_plug_equal, isplug
export SimplePlug
export isdual, isinput, isoutput
export LayerSite, LayerLink, layer, layers

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
is_site_equal(a::LayerSite, b::LayerSite) = is_site_equal(a.id, b.id) && a.layer == b.layer

Base.isequal(a::LayerSite, b::LayerSite) = isequal(a.id, b.id) && isequal(a.layer, b.layer)
Base.show(io::IO, x::LayerSite) = print(io, "$(x.id) at $(repr(x.layer))")

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

Base.isequal(a::LayerLink, b::LayerLink) = isequal(a.link, b.link) && isequal(a.layer, b.layer)
Base.show(io::IO, x::LayerLink) = print(io, "$(x.link) at $(repr(x.layer))")

# e.g. a closed plug between two layers
struct InterLayerLink{S,IL} <: Link
    site::S
    cut::IL
end

site(x::InterLayerLink) = site(x.site)
layers(x::InterLayerLink) = x.cut

Base.isequal(a::InterLayerLink, b::InterLayerLink) = isequal(a.site, b.site) && isequal(a.cut, b.cut)
Base.show(io::IO, x::InterLayerLink) = print(io, "$(x.site) at $(x.cut)")

end # module QuantumTags
