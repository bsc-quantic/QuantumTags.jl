using Test
using QuantumTags
using QuantumTags: site, bond, Layer, InterLayer, ispartition, partition

_layer = Layer(:ket)
@test ispartition(_layer)
@test partition(_layer) == _layer
@test layer(_layer) == _layer

_ilayer = InterLayer(Layer(:ket), Layer(:bra))
@test ispartition(_ilayer)
@test partition(_ilayer) == _ilayer
@test layers(_ilayer) == (_ilayer.src, _ilayer.dst)

# `LayerSite`
_site = LayerSite(site"1", :ket)
@test site(_site) == site"1"
@test layer(_site) == Layer(:ket)
@test issite(_site)

_site = LayerSite(site"1,2", "bra")
@test site(_site) == site"1,2"
@test layer(_site) == Layer("bra")
@test issite(_site)

@test is_site_equal(LayerSite(site"1", :ket), LayerSite(site"1", :ket))
@test is_site_equal(LayerSite(site"1", :ket), LayerSite(site"1", :not_ket))
@test !is_site_equal(LayerSite(site"1", :ket), LayerSite(site"2", :ket))
@test !is_site_equal(LayerSite(site"1", :ket), LayerSite(site"2", :not_ket))

# `LayerLink`
_link = LayerLink(bond"1-2", :ket)
@test bond(_link) == bond"1-2"
@test layer(_link) == Layer(:ket)

_link = LayerLink(bond"1-2", "bra")
@test bond(_link) == bond"1-2"
@test layer(_link) == Layer("bra")

_link = LayerLink(bond"1-2", 1)
@test bond(_link) == bond"1-2"
@test layer(_link) == Layer(1)

# @test is_bond_equal(LayerLink(bond"1-2", :ket), LayerLink(bond"1-2", :ket))
@test isequal(LayerLink(bond"1-2", :ket), LayerLink(bond"1-2", :ket))
@test isequal(LayerLink(bond"1-2", :ket), LayerLink(bond"2-1", :ket))
@test !isequal(LayerLink(bond"1-2", :ket), LayerLink(bond"1-2", :not_ket))
