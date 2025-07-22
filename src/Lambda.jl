struct LambdaSite{B<:Bond} <: Site
    bond::B
end

# required for set-like equivalence of `Bond` to work on dictionaries
Base.isequal(s1::LambdaSite, s2::LambdaSite) = isequal(s1.bond, s2.bond)
Base.hash(s::LambdaSite, h::UInt) = hash(s.bond, h) ⊻ hash("LambdaSite", h)

bond(s::LambdaSite) = bond(s.bond)
sites(s::LambdaSite) = sites(bond(s))

dispatch_site_constructor(b::Bond) = LambdaSite(b)

macro lambda_str(str)
    bondexpr = esc(Expr(:macrocall, Symbol("@bond_str"), __source__, str))
    :(LambdaSite($bondexpr))
end

Base.show(io::IO, x::LambdaSite) = print(io, "site<$(x.bond)>")
