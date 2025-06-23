# QuantumTags.jl

This is a small foundational library that implements a tag system used to refer to quantum sites and related concepts.

## Decorator pattern

Instead of using abstract types and polymorphism through inheritance, QuantumTags.jl uses the [Decorator pattern](https://en.wikipedia.org/wiki/Decorator_pattern) . Check out [this post by refactoring.guru](https://refactoring.guru/design-patterns/decorator) if you want to dig more.

Roughly speaking, instead of creating new types, you extend the wrapper type (e.g. `Site`, `Link`) by incrementally adding tags to the type parameters of the wrapper type.

```julia
struct Shape{T}
    id::T
end

area(x::Shape) = area(x.id)

struct SquareTag{T}
    length::T
end

issquare(_) = false
issquare(::SquareTag) = true
issquare(x::Shape) = issquare(x.id)

area(x::SquareTag) = x.length^2

struct CircleTag{T}
    radius::T
end

iscircle(_) = false
iscircle(::CircleTag) = true
iscircle(x::Shape) = iscircle(x.id)

area(x::CircleTag) = pi * x.radius^2

struct ColorTag{D}
    id::D
    color::Symbol
end

iscircle(x::ColorTag) = iscircle(x.id)
issquare(x::ColorTag) = issquare(x.id)
area(x::ColorTag) = area(x.id)

color(::ColorTag) = nothing
color(x::ColorTag) = x.color
color(x::Shape) = color(x.id)
```

Then we can create our custom tag type in a constructive manner:

```julia
julia> x = Shape(ColorTag(CircleTag(2.0), :red))
Shape{ColorTag{CircleTag{Float64}}}(ColorTag{CircleTag{Float64}}(CircleTag{Float64}(2.0), :red))

julia> iscircle(x)
true

julia> issquare(x)
false

julia> area(x)
12.566370614359172

julia> color(x)
:red
```

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
