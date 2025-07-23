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

# NOTE taken from `set.jl`: this is like `hash` method for `AbstractSet`
const hashs_seed = UInt === UInt64 ? 0x852ada37cfe8e0ce : 0xcfe8e0ce
function Base.hash(b::Bond, h::UInt)
    hv = hashs_seed
    for _site in sites(b)
        hv ⊻= hash(_site)
    end
    hash(hv, h)
end

is_bond_equal(a, b) = isequal(bond(a), bond(b))
Base.isequal(a::Bond, b::Bond) = is_bond_equal(a, b)

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

function Base.show(io::IO, x::Bond)
    print(io, "bond<")
    print(io, join(sites(x), " ⟷ "))
    print(io, ">")
end

dispatch_bond_constructor(a, b) = SimpleBond(a, b)

function _bond_expr(expr)
    if !(Meta.isexpr(expr, :call) && expr.args[1] == :-)
        throw(
            ArgumentError(
                "Bond string must be in the form 'src-dst', where src and dst are site strings acceptable for @site_str.",
            ),
        )
    end

    src, dst = expr.args[2:end]
    src_expr = _site_expr(src)
    dst_expr = _site_expr(dst)
    return :(dispatch_bond_constructor($src_expr, $dst_expr))
end

"""
    bond"i-j"
    bond"(i,j,...)-(k,l,...)"

Constructs a [`SimpleBond`](@ref) object.
[`Site`](@ref)s are given as a comma-separated list of integers, and source and destination sites are separated by a `-`.
"""
macro bond_str(str)
    expr = Meta.parse(str)
    _bond_expr(expr)
end

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

hassite(bond::SimpleBond, x) = is_site_equal(bond.sites[1], x) || is_site_equal(bond.sites[2], x)
sites(bond::SimpleBond) = site.(bond.sites)

function is_bond_equal(a::SimpleBond, b::SimpleBond)
    s1a, s2a = sites(a)
    s1b, s2b = sites(b)
    isequal(s1a, s1b) && isequal(s2a, s2b) || isequal(s1a, s2b) && isequal(s2a, s1b)
end

struct LayerBond{B<:Bond,L<:Layer} <: Bond
    bond::B
    layer::L
end

LayerBond(bond, layer) = LayerBond(bond, Layer(layer))

sites(x::LayerBond) = LayerSite.(sites(x.bond), (x.layer,))
bond(x::LayerBond) = bond(x.bond)
partition(x::LayerBond) = layer(x)
layer(x::LayerBond) = layer(x.layer)

isbond(x::LayerBond) = isbond(x.bond)

Base.isequal(a::LayerBond, b::LayerBond) = isequal(a.bond, b.bond) && isequal(partition(a), partition(b))

# e.g. a closed plug between two same sites on different layers
struct InterLayerBond{S<:Site,IL<:InterLayer} <: Bond
    site::S
    cut::IL
end

InterLayerBond(site::S, cut::C) where {S<:Site,C} = InterLayerBond(site, InterLayer(cut))

site(x::InterLayerBond) = site(x.site)
sites(x::InterLayerBond) = LayerSite.((site(x),), layers(x.cut))
interlayer(x::InterLayerBond) = x.cut
layers(x::InterLayerBond) = layers(x.cut)

Base.isequal(a::InterLayerBond, b::InterLayerBond) = isequal(a.site, b.site) && isequal(a.cut, b.cut)
