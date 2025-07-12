using Test
using QuantumTags

_site = LayerSite(site"1", :ket)
@test site(_site) == site"1"
@test layer(_site) == :ket
@test issite(_site)

_site = LayerSite(site"1,2", "bra")
@test site(_site) == site"1,2"
@test layer(_site) == "bra"
@test issite(_site)

@test is_site_equal(LayerSite(site"1", :ket), LayerSite(site"1", :ket))
