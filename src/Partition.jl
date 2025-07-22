abstract type Partition <: Tag end

ispartition(::T) where {T} = ispartition(T)
ispartition(::Type) = false
ispartition(::Type{<:Partition}) = true

partition(x::Partition) = x

is_partition_equal(a, b) = isequal(partition(a), partition(b))

struct Layer{T} <: Partition
    id::T
end

Layer(x::Layer) = x

islayer(::T) where {T} = islayer(T)
islayer(::Type) = false
islayer(::Type{<:Layer}) = true

layer(x::Layer) = x
layers(x::Layer) = (x,)

is_layer_equal(a, b) = isequal(layer(a), layer(b))

Base.show(io::IO, x::Layer) = print(io, "layer<$(x.id)>")
Base.show(io::IO, x::Layer{Symbol}) = print(io, "layer<:$(x.id)>")
Base.show(io::IO, x::Layer{<:AbstractString}) = print(io, "layer<\"$(x.id)\">")

struct InterLayer{A<:Layer,B<:Layer} <: Partition
    src::A
    dst::B
end

InterLayer(x::InterLayer) = x
InterLayer(x::Tuple) = InterLayer(Layer.(x)...)
InterLayer(x::Pair) = InterLayer(Layer(first(x)), Layer(last(x)))
InterLayer(src, dst) = InterLayer(Layer(src), Layer(dst))

isinterlayer(::T) where {T} = isinterlayer(T)
isinterlayer(::Type) = false
isinterlayer(::Type{<:InterLayer}) = true

interlayer(x::InterLayer) = x
layers(x::InterLayer) = (x.src, x.dst)

is_interlayer_equal(a, b) = isequal(interlayer(a), interlayer(b))

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
