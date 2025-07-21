abstract type Partition <: Tag end

ispartition(::T) where {T} = ispartition(T)
ispartition(::Type) = false
ispartition(::Type{<:Partition}) = true

partition(x::Partition) = x

struct Layer{T} <: Partition
    id::T
end

layer(x::Layer) = x
layers(x::Layer) = (x,)

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
