using Test
using QuantumTags

@testset "Unit" verbose = true begin
    @testset "CartesianSite" include("unit/cartesian_site.jl")
    @testset "NamedSite" include("unit/named_site.jl")
    @testset "MultiSite" include("unit/multi_site.jl")
    @testset "Plug" include("unit/plug.jl")
    @testset "Bond" include("unit/bond.jl")
end
