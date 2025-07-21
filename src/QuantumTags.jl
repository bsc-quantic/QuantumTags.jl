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

abstract type Link <: Tag end

islink(::T) where {T} = islink(T)
islink(::Type) = false
islink(::Type{<:Link}) = true

include("Site.jl")
include("Bond.jl")
include("Plug.jl")

end # module QuantumTags
