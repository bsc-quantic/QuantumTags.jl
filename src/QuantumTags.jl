module QuantumTags

export Site, @site, @site_str, is_site_equal, issite
export CartesianSite, NamedSite
export Bond, @bond, @bond_str, is_bond_equal, isbond
export SimpleBond
export Plug, @plug, @plug_str, is_plug_equal, isplug
export SimplePlug
export isdual, isinput, isoutput
export Layer, InterLayer, layer, layers, LayerSite, LayerBond, InterLayerBond

abstract type Tag end

# TODO checkout whether this is a good idea
Base.copy(x::Tag) = x

abstract type Site <: Tag end

issite(::T) where {T} = issite(T)
issite(::Type) = false
issite(::Type{<:Site}) = true

abstract type Link <: Tag end

islink(::T) where {T} = islink(T)
islink(::Type) = false
islink(::Type{<:Link}) = true

include("Site.jl")
include("Bond.jl")
include("Plug.jl")

abstract type Partition <: Tag end

ispartition(::Tag) = false
ispartition(::Type{<:Tag}) = false
ispartition(::Partition) = true
ispartition(::Type{<:Partition}) = true

partition(x::Partition) = x

struct Layer{T} <: Partition
    id::T
end

layer(x::Layer) = x
layers(x::Layer) = (x,)
layers(x::Bond) = (layer(x.src), layer(x.dst))

Base.show(io::IO, x::Layer) = print(io, "layer<$(x.id)>")
Base.show(io::IO, x::Layer{Symbol}) = print(io, "layer<:$(x.id)>")
Base.show(io::IO, x::Layer{<:AbstractString}) = print(io, "layer<\"$(x.id)\">")

struct InterLayer{A<:Layer,B<:Layer} <: Partition
    src::A
    dst::B
end

layers(x::InterLayer) = (x.src, x.dst)

Base.show(io::IO, x::InterLayer) = print(io, "interlayer<$(x.src) ⟷ $(x.dst)>")

# set-like equivalence for `InterLayer`
function Base.hash(x::InterLayer, h::UInt)
    hv = hashs_seed
    hv ⊻= hash(x.src)
    hv ⊻= hash(x.dst)
    hash(hv, h)
end

function Base.isequal(a::InterLayer, b::InterLayer)
    isequal(a.src, b.src) && isequal(a.dst, b.dst) || isequal(a.src, b.dst) && isequal(a.dst, b.src)
end

struct LayerSite{S<:Site,L<:Layer} <: Site
    id::S
    layer::L
end

LayerSite(id::S, layer::T) where {S<:Site,T} = LayerSite{S,Layer{T}}(id, Layer(layer))

site(x::LayerSite) = site(x.id)
layer(x::LayerSite) = layer(partition(x))
partition(x::LayerSite) = x.layer

is_site_equal(a::LayerSite, b::LayerSite) = is_site_equal(a.id, b.id)
is_layer_equal(a::LayerSite, b::LayerSite) = isequal(a.layer, b.layer)

# partition(x::Bond{<:LayerSite}) = sites()

Base.isequal(a::LayerSite, b::LayerSite) = is_site_equal(a, b)
Base.show(io::IO, x::LayerSite) = print(io, "$(x.id) at $(repr(layer(x)))")

struct LayerLink{L<:Link,P<:Partition} <: Link
    id::L
    partition::P
end

LayerLink(id::L, layer::T) where {L<:Link,T} = LayerLink{L,Layer{T}}(id, Layer(layer))

function sites(x::LayerLink)
    LayerSite.(sites(x.id),)
end
bond(x::LayerLink) = bond(x.id)
partition(x::LayerLink) = x.partition
layer(x::LayerLink) = layer(partition(x))

isbond(x::LayerLink) = isbond(x.id)
isplug(x::LayerLink) = isplug(x.id)

Base.isequal(a::LayerLink, b::LayerLink) = isequal(a.id, b.id) && isequal(partition(a), partition(b))
Base.show(io::IO, x::LayerLink) = print(io, "$(x.id) at $(repr(partition(x)))")

# e.g. a closed plug between two same sites on different layers
# TODO should we use this or a `Bond{LayerSite}`; i.e. a bond between 2 sites on layer?
struct InterLayerLink{S,IL} <: Link
    site::S
    cut::IL
end

site(x::InterLayerLink) = site(x.site)
layers(x::InterLayerLink) = x.cut

Base.isequal(a::InterLayerLink, b::InterLayerLink) = isequal(a.site, b.site) && isequal(a.cut, b.cut)
Base.show(io::IO, x::InterLayerLink) = print(io, "$(x.site) at $(x.cut)")

end # module QuantumTags
