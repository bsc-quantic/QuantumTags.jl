using Test
using QuantumTags

lane = CartesianSite(1)
@test Tuple(lane) == (1,)
@test CartesianIndex(lane) == CartesianIndex(1)
@test ndims(lane) == 1
@test issite(lane) == true

lane = CartesianSite(1, 2)
@test Tuple(lane) == (1, 2)
@test CartesianIndex(lane) == CartesianIndex((1, 2))
@test ndims(lane) == 2
@test issite(lane) == true

lane = site"1"
@test Tuple(lane) == (1,)
@test CartesianIndex(lane) == CartesianIndex(1)
@test ndims(lane) == 1
@test issite(lane) == true

lane = site"1,2"
@test Tuple(lane) == (1, 2)
@test CartesianIndex(lane) == CartesianIndex((1, 2))
@test ndims(lane) == 2
@test issite(lane) == true

@testset "isless" begin
    @test site"1" < site"2"
    @test site"1,2" < site"1,3"
    @test site"1,2" < site"2,1"

    @test !(site"2" < site"1")
    @test !(site"1,3" < site"1,2")
    @test !(site"2,1" < site"1,2")
end

@testset "is_site_equal" begin
    @test is_site_equal(site"1", site"1")
    @test !is_site_equal(site"1", site"2")
    @test is_site_equal(site"1,2", site"1,2")
    @test !is_site_equal(site"1,2", site"2,1")
    @test !is_site_equal(site"1,2", site"1")
end

@testset "arithmetic" begin
    # addition
    @test site"1" + 2 == site"3"
    @test site"1" + (2,) == site"3"
    @test 2 + site"1" == site"3"
    @test (2,) + site"1" == site"3"

    @test site"1,2" + (1, 1) == site"2,3"
    @test (1, 1) + site"1,2" == site"2,3"
    @test site"1,2" + site"1,1" == site"2,3"

    # subtraction
    @test site"3" - 2 == site"1"
    @test site"3" - (2,) == site"1"
    @test 3 - site"2" == site"1"
    @test (3,) - site"2" == site"1"

    @test site"2,3" - (1, 1) == site"1,2"
    @test (2, 3) - site"1,1" == site"1,2"
    @test site"2,3" - site"1,1" == site"1,2"
end
