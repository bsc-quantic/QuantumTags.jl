using Test
using QuantumTags
using QuantumTags: site, bond, ispartition, partition, islayer, isinterlayer, interlayer

_layer = Layer(:ket)
@test ispartition(_layer)
@test partition(_layer) == _layer
@test islayer(_layer)
@test layer(_layer) == _layer

_ilayer = InterLayer(Layer(:ket), Layer(:bra))
@test ispartition(_ilayer)
@test partition(_ilayer) == _ilayer
@test isinterlayer(_ilayer)
@test interlayer(_ilayer) == _ilayer
@test layers(_ilayer) == (_ilayer.src, _ilayer.dst)

# `LayerSite`
_site = LayerSite(site"1", :ket)
@test issite(_site)
@test site(_site) == site"1"
@test layer(_site) == Layer(:ket)

_site = LayerSite(site"1,2", "bra")
@test issite(_site)
@test site(_site) == site"1,2"
@test layer(_site) == Layer("bra")

@test is_site_equal(LayerSite(site"1", :ket), LayerSite(site"1", :ket))
@test is_site_equal(LayerSite(site"1", :ket), LayerSite(site"1", :not_ket))
@test !is_site_equal(LayerSite(site"1", :ket), LayerSite(site"2", :ket))
@test !is_site_equal(LayerSite(site"1", :ket), LayerSite(site"2", :not_ket))

# `LayerBond`
_bond = LayerBond(bond"1-2", :ket)
@test bond(_bond) == bond"1-2"
@test layer(_bond) == Layer(:ket)

_bond = LayerBond(bond"1-2", "bra")
@test bond(_bond) == bond"1-2"
@test layer(_bond) == Layer("bra")

_bond = LayerBond(bond"1-2", 1)
@test bond(_bond) == bond"1-2"
@test layer(_bond) == Layer(1)

@test isequal(LayerBond(bond"1-2", :ket), LayerBond(bond"1-2", :ket))
@test isequal(LayerBond(bond"1-2", :ket), LayerBond(bond"2-1", :ket))
@test !isequal(LayerBond(bond"1-2", :ket), LayerBond(bond"1-2", :not_ket))

@test is_bond_equal(LayerBond(bond"1-2", :ket), LayerBond(bond"1-2", :ket))
@test is_bond_equal(LayerBond(bond"1-2", :ket), LayerBond(bond"1-2", :bra))
@test !is_bond_equal(LayerBond(bond"1-2", :ket), LayerBond(bond"2-3", :ket))

# `InterLayerBond`
_inter_bond = InterLayerBond(site"1", :ket => :bra)
@test site(_inter_bond) == site"1"
@test sites(_inter_bond) == (LayerSite(site"1", :ket), LayerSite(site"1", :bra))
@test layers(_inter_bond) == (Layer(:ket), Layer(:bra))

# `LayerPlug`
_plug = LayerPlug(plug"1", :ket)
@test isplug(_plug)
@test plug(_plug) == plug"1"
@test site(_plug) == site"1"
@test partition(_plug) == layer(_plug) == Layer(:ket)
@test adjoint(_plug) == LayerPlug(plug"1'", :ket)
@test reverse(_plug) == LayerPlug(plug"1'", :ket)

_plug = LayerPlug(plug"1'", :ket)
@test isplug(_plug)
@test plug(_plug) == plug"1'"
@test site(_plug) == site"1"
@test partition(_plug) == layer(_plug) == Layer(:ket)
@test adjoint(_plug) == LayerPlug(plug"1", :ket)
@test reverse(_plug) == LayerPlug(plug"1", :ket)
