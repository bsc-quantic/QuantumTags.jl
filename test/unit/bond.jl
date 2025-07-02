using Test
using QuantumTags
using QuantumTags: sites, hassite

test_bond = Bond(site"1", site"2")
@test Pair(test_bond) == (site"1" => site"2")
@test Tuple(test_bond) == (site"1", site"2")
@test isbond(test_bond)
@test issetequal(sites(test_bond), (site"1", site"2"))
@test collect(test_bond) == [site"1", site"2"]
@test hassite(test_bond, site"1")
@test hassite(test_bond, site"2")

test_bond = bond"1-2"
@test Pair(test_bond) == (site"1" => site"2")
@test Tuple(test_bond) == (site"1", site"2")
@test isbond(test_bond)
@test issetequal(sites(test_bond), (site"1", site"2"))
@test collect(test_bond) == [site"1", site"2"]
@test hassite(test_bond, site"1")
@test hassite(test_bond, site"2")
@test issetequal(sites(test_bond), (site"1", site"2"))

test_bond = Bond(site"1,2", site"2,1")
@test Pair(test_bond) == (site"1,2" => site"2,1")
@test Tuple(test_bond) == (site"1,2", site"2,1")
@test isbond(test_bond)
@test issetequal(sites(test_bond), (site"1,2", site"2,1"))
@test collect(test_bond) == [site"1,2", site"2,1"]
@test hassite(test_bond, site"1,2")
@test hassite(test_bond, site"2,1")
@test issetequal(sites(test_bond), (site"1,2", site"2,1"))

test_bond = bond"(1,2)-(2,1)"
@test Pair(test_bond) == (site"1,2" => site"2,1")
@test Tuple(test_bond) == (site"1,2", site"2,1")
@test isbond(test_bond)
@test issetequal(sites(test_bond), (site"1,2", site"2,1"))
@test collect(test_bond) == [site"1,2", site"2,1"]
@test hassite(test_bond, site"1,2")
@test hassite(test_bond, site"2,1")
@test issetequal(sites(test_bond), (site"1,2", site"2,1"))
