using Test
using QuantumTags
using QuantumTags: NamedSite

x = NamedSite("a")
@test issite(x) == true
@test string(x) == "a"

x = NamedSite(:a)
@test issite(x) == true
@test string(x) == "a"

@testset "is_site_equal" begin
    @test is_site_equal(NamedSite("a"), NamedSite("a"))
    @test !is_site_equal(NamedSite("a"), NamedSite("b"))
    @test is_site_equal(NamedSite(:a), NamedSite(:a))
    @test !is_site_equal(NamedSite(:a), NamedSite(:b))
    @test !is_site_equal(NamedSite(:a), NamedSite("a"))
end
