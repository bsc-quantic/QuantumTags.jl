# QuantumTags.jl

This is a small foundational library that implements a tag system used to refer to quantum sites and related concepts.

## Tag types

### `Site` tag

A wrapper type / tag representing a site in a lattice.

#### `CartesianSite`

A `Site` backed by a `NTuple{N,Int}`.

```julia
julia> CartesianSite(1)
site<(1,)>

julia> CartesianSite(2,3)
site<(2, 3)>
```

There is the `@site_str` macro for easier creation of `CartesianSite`s.

```julia
julia> site"1"
site<(1,)>

julia> site"2,3"
site<(2, 3)>
```

#### `NamedSite`

A `Site` backed by a `AbstractString` or `Symbol` as identifier.

```julia
julia> NamedSite("auxiliary")
site<"auxiliary">

julia> NamedSite(:tmp)
site<:tmp>
```

### `Bond` tag

A tag representing a bond between two `Site`s.

```julia
julia> Bond(site"1", site"2")
bond<site<(1,)> ⟷ site<(2,)>>

julia> Bond(NamedSite(:tmp), NamedSite(:q0))
bond<site<:tmp> ⟷ site<:q0>>
```

There is the `@bond_str` macro for easier creation of `Bond`s containing `CartesianSite`s.

```julia
julia> bond"1,2-3,4"
bond<site<(1, 2)> ⟷ site<(3, 4)>>
```

### `Plug` tag

A tag representing a physical, open link from which a `Site` attaches to operators.

```julia
julia> Plug(site"1")
plug<site<(1,)>>

julia> Plug(site"1"; isdual=true)
plug<site<(1,)>'>

julia> Plug(site"1")'
plug<site<(1,)>'>
```

There is the `@plug_str` macro for easier creation of `Plug`s containing a `CartesianSite`.

```julia
julia> plug"1"
plug<site<(1,)>>

julia> plug"1'"
plug<site<(1,)>'>
```
