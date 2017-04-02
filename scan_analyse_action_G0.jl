const symbol_dict = Dict(
    "->" => (:->, 0, NonTER, "->"),
    "." => (:., 0, NonTER, "."),
    ";" => (Symbol(";"), 0, NonTER, ";"),
    "," => (Symbol(","), 0, NonTER, ","),
    "+" => (Symbol("+"), 0, NonTER, "+"),
    "(" => (Symbol("("), 0, NonTER, "("),
    ")" => (Symbol(")"), 0, NonTER, ")"),
    "[" => (Symbol("["), 0, NonTER, "["),
    "]" => (Symbol("]"), 0, NonTER, "]"),
    "(/" => (Symbol("(/"), 0, NonTER, "(/"),
    "/)" => (Symbol("/)"), 0, NonTER, "/)"),
)

function scan_G0(ln::String)::Array{Tuple{Symbol, Int, enum_atomType, String}, 1}

    # !!! Si on laisse passer un "\n" ici ça fait planter l'analyse (interprété comme un non terminal) ... !!!
    ln = replace(ln, '\n', "")

    cpt = 1
    N = length(ln)
    res = Array{Tuple{Symbol, Int, enum_atomType, String}, 1}(0)
    buffer = ""
    while cpt <= N
        buffer = ""
        if ln[cpt] == ' '#on ignore les espaces
            cpt += 1
        elseif ln[cpt] == ''' #SI TERMINAL (entre quotes)
            cpt += 1
            while cpt <= N && ln[cpt] != '''
                #opérateur de concaténation : *, 
                #pas défini pour String*Char donc il faut faire attention :
                #"abc"[1] = 'a' // Char
                #"abc"[1:1] "a" // String
                buffer *= ln[cpt:cpt] 
                cpt += 1
            end
            cpt += 1 #on passe le ' de fin
            action = "0"
            if cpt <= N && ln[cpt] == '#' #si on lit une action
                cpt+= 1
                while cpt <= N && isnumber(ln[cpt])
                    action *= ln[cpt:cpt]
                    cpt += 1
                end
            end
            push!(res, (:ELTER, parse(Int,action), TER, buffer))
        elseif any(x-> x[1] == ln[cpt], collect(keys(symbol_dict))) #Si une clé dans le dictionnaire des Non-Terminaux commence par le caractere lu
            while(cpt <= N && any(x-> searchindex(x, buffer*ln[cpt:cpt]) == 1, collect(keys(symbol_dict)))) #Tant qu'une clé du dico match le buffer+le prochain caractere
                buffer *= ln[cpt:cpt] 
                cpt += 1
            end
            !haskey(symbol_dict, buffer) && error("Symbole $buffer non reconnu (index $cpt)")
            push!(res, symbol_dict[buffer])
        else 
           
            #On est en train de lire un String non quoté, donc une règle
            #Ca sera donc un Non-Terminal
            while cpt <= N && (isalpha(ln[cpt]) || isnumber(ln[cpt]))
                buffer = buffer*ln[cpt:cpt]
                cpt += 1
            end
            action = "0"
            if cpt <= N && ln[cpt] == '#'
                cpt+= 1
                while cpt <= N && isnumber(ln[cpt])
                    action *= ln[cpt:cpt]
                    cpt += 1
                end
            end
            push!(res, (:IDNTER , parse(Int,action), NonTER, buffer))
        end
    end
    return res
end


type scanIterator
    data::Array{Tuple{Symbol, Int, enum_atomType, String}}
    cpt::Int
end
scanIterator(data) = scanIterator(data,1) #Constructeur


function next(scanIt::scanIterator)
    scanIt.cpt += 1
end

function get(scanIt::scanIterator)::Tuple{Symbol, Int, enum_atomType, String}
    length(scanIt.data) < scanIt.cpt && error("scan terminé")
    return scanIt.data[scanIt.cpt]
end


function analyse(p::PTR)::Bool
    if isa(p, conc)
        return analyse(p.left) && analyse(p.right)
    elseif isa(p, union)
        return analyse(p.left) || analyse(p.right)
    elseif isa(p,star)
        while analyse(p.stare) end
        return true
    elseif isa(p,un)
        analyse(p.une)
        return true
    elseif isa(p, atom)
        if p.atomType == TER
            symbole,action,AType,str = get(scanIt) #Tuple(Symbol, action::Int, TER/NonTER, String)
            if p.COD == symbole 
                if p.action != 0
                    G0_Action(p.action)
                end
                next(scanIt)
                return true
            else 
                return false
            end
        else
            if !(p.COD in Dict_NT)
                error("Don't know any rule for Non-Terminal symbol $(p.COD)")
            end
            numero_regle = findfirst(Dict_NT,p.COD)
            if analyse(A[numero_regle])
                if p.action != 0
                    G0_Action(p.action)
                end
                return true
            else
                return false
            end
        end
    end
end

#Convention Julia : les fonctions modifiant les paramètres finissent par un "!"
function Recherche!(dict::Array{Symbol,1}, symbole::Symbol ; skip_5_first=false)::Symbol #Skip_5_first permet de réutiliser les symboles :S,:N etc... dans la GPL
                                                        #sinon :N pointerait vers A[1] et non pas la nouvelle règle
    if (skip_5_first && !(symbole in dict[6:end])) || (!skip_5_first && !(symbole in dict))
        push!(dict, symbole)
    end
    return symbole
    
end

function G0_Action(act::Int)::Void
    #Non il n'y a pas de switch dans julia
    if act == 1
        T1 = pop!(Pile) ; T2 = pop!(Pile) ; push!(A, T1)
    elseif act == 2
        symbole,action,AType,str = get(scanIt) #Tuple(Symbol, action::Int, TER/NonTER, String)
        push!(Pile, atom(Recherche!(Dict_NT,Symbol(str), skip_5_first=true), action, AType))
    elseif act == 3
        T1 = pop!(Pile) ; T2 = pop!(Pile) ; push!(Pile, union(T2, T1))
    elseif act == 4
        T1 = pop!(Pile) ; T2 = pop!(Pile) ; push!(Pile, conc(T2, T1))
    elseif act == 5
        symbole,action,AType,str = get(scanIt)
        if AType == TER
            push!(Pile, atom(Recherche!(Dict_T,Symbol(str)), action, AType))
        else
            push!(Pile, atom(Symbol(str), action, AType))
        end
    elseif act == 6
        T1 = pop!(Pile) ; push!(Pile, star(T1))
    elseif act == 7
        T1 = pop!(Pile) ; push!(Pile, un(T1))
    else
        error("action inconnue")
    end
    return
end