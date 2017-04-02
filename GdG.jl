@enum enum_atomType TER=1 NonTER=2

abstract PTR
type conc <: PTR left::PTR ; right::PTR end
type union <: PTR left::PTR ; right::PTR end
type star <: PTR stare::PTR end
type un <: PTR une::PTR end
type atom <: PTR COD::Symbol ; action::Int ; atomType::enum_atomType end	

function GenForet()
	A1 = conc(star(conc(conc(conc(atom(:N, 0, NonTER), atom(:->, 0, TER)),atom(:E, 0, NonTER)), atom(Symbol(",") , 1, TER))),atom(Symbol(";"),0,TER))
	A2 = atom(:IDNTER, 2, TER)
	A3 = conc(atom(:T, 0, NonTER), star(conc(atom(:+, 0 , TER), atom(:T, 3, NonTER))))
	A4 = conc(atom(:F, 0, NonTER), star(conc(atom(:., 0, TER), atom(:F, 4, NonTER))))
	A5 = union(	atom(:IDNTER, 5, TER), union(atom(:ELTER, 5, TER), union(conc( conc(	atom(Symbol("("), 0, TER),
	atom(:E, 0, NonTER)), atom(Symbol(")"), 0, TER)),union(	conc(	conc(	atom(Symbol("["), 0, TER),
	atom(:E, 0, NonTER)), atom(Symbol("]"), 6, TER)), conc(conc(atom(Symbol("(/"), 0, TER),
	atom(:E, 0, NonTER)), atom(Symbol("/)"), 7, TER))))))
	return [A1, A2, A3, A4, A5]
end

function ptrToString(p::PTR)
	res = "$(typeof(p))"
	isa(p, atom) && (res = "$res ( $(p.COD) | $(p.action) | $(p.atomType) )")
	return res
end

function print_arbre(p, depth = 0)
	offset = ""
	for i = 1:depth
		offset = "$offset|-"
	end
	println("$offset>$(ptrToString(p))")
	if isa(p, conc) || isa(p, union)
		print_arbre(p.left, depth+1)
		print_arbre(p.right, depth+1)
	elseif isa(p, star)
		print_arbre(p.stare, depth+1)
	elseif isa(p, un)
		print_arbre(p.une, depth+1)
	end		
end

# for i in GenForet
#     print_arbre(i)
#     println("\n-------------------------------------------\n")
# end