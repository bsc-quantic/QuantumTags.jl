using Test
using QuantumTags
using QuantumTags: site

s = SimplePlug(1)
@test site(s) == site"1"
@test isdual(s) == false

s = SimplePlug(1; isdual=true)
@test site(s) == site"1"
@test isdual(s) == true

s = SimplePlug(1, 2)
@test site(s) == site"1, 2"
@test isdual(s) == false

s = SimplePlug(1, 2; isdual=true)
@test site(s) == site"1, 2"
@test isdual(s) == true

s = plug"1"
@test site(s) == site"1"
@test isdual(s) == false

s = plug"1'"
@test site(s) == site"1"
@test isdual(s) == true

s = plug"1,2"
@test site(s) == site"1, 2"
@test isdual(s) == false

s = plug"1,2'"
@test site(s) == site"1, 2"
@test isdual(s) == true

s = adjoint(plug"1")
@test site(s) == site"1"
@test isdual(s) == true

s = adjoint(plug"1'")
@test site(s) == site"1"
@test isdual(s) == false

s = adjoint(plug"1,2")
@test site(s) == site"1, 2"
@test isdual(s) == true

s = adjoint(plug"1,2'")
@test site(s) == site"1, 2"
@test isdual(s) == false

@testset "is_plug_equal" begin
    @test is_plug_equal(plug"1", plug"1")
    @test !is_plug_equal(plug"1", plug"2")
    @test is_plug_equal(plug"1,2", plug"1,2")
    @test !is_plug_equal(plug"1,2", plug"2,1")
    @test !is_plug_equal(plug"1,2", plug"1")
end

@testset "site" begin
    @test is_site_equal(site(plug"1"), site"1")
    @test is_site_equal(site(plug"1"), site(plug"1"))
    @test is_site_equal(site(plug"1"), site(plug"1'"))

    @test is_site_equal(site(plug"1,2"), site"1,2")
    @test is_site_equal(site(plug"1,2"), site(plug"1,2"))
    @test is_site_equal(site(plug"1,2"), site(plug"1,2'"))

    @test !is_site_equal(site(plug"1"), site(plug"2"))
end
