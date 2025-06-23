# using Test
# using QuantumTags
# using QuantumTags: NamedSite, MultiSite

# x = MultiSite(site"1")
# @test issite(x) == true

# x = MultiSite(site"1", site"2")
# @test issite(x) == true

# x = MultiSite(NamedSite(:a))
# @test issite(x) == true

# x = MultiSite(site"1", NamedSite(:a))
# @test issite(x) == true

# @testset "is_site_equal" begin
#     @test is_site_equal(MultiSite(site"1"), MultiSite(site"1"))
#     @test is_site_equal(MultiSite(site"1", site"2"), MultiSite(site"1", site"2"))
#     @test is_site_equal(MultiSite(:a), MultiSite(:a))
#     @test_broken is_site_equal(MultiSite(site"1", site"2"), MultiSite(site"2", site"1"))

#     @test !is_site_equal(MultiSite(site"1"), MultiSite(site"2"))
#     @test !is_site_equal(MultiSite(site"1", site"2"), MultiSite(site"1", site"3"))
#     @test !is_site_equal(MultiSite(:a), MultiSite(:b))
# end
