# const symbol_dictGPL = ["<","<=",">",">=","=","==","&&", "||",",",";"]



function scan_GPL(ln::String)
    Dict_T_GPL = map(x -> string(x), Dict_T)
    ln = replace(ln, '\n', "")
    ln = replace(ln, '\t', "")
    cpt = 1
    N = length(ln)
    res = []
    buffer = ""
    while cpt <= N
        buffer = ""
        if ln[cpt] == ' ' #on ignore les espaces
            cpt += 1
        elseif any(x-> x[1] == ln[cpt], Dict_T_GPL) #Si une clé dans le dictionnaire des Terminaux commence par le caractere lu
            while(cpt <= N && any(x-> searchindex(x, buffer*ln[cpt:cpt]) == 1, Dict_T_GPL)) #Tant qu'une clé du dico match le buffer+le prochain caractere
                buffer *= ln[cpt:cpt] 
                cpt += 1
            end
            if (buffer in Dict_T_GPL)
                push!(res, (Symbol(buffer), buffer))
            else #ça commençait comme un des symboles mais en fait non !
                if isalpha(buffer)
                     while cpt <= N && isalpha(ln[cpt])
                        buffer *= ln[cpt:cpt] 
                        cpt += 1
                    end
                    push!(res, (:IDENT, buffer))
                else
                    error("Symbole non reconnu ($buffer)")
                end
            end
        elseif isalpha(ln[cpt]) #si c'est un caractere
            while cpt <= N && isalpha(ln[cpt])
                buffer *= ln[cpt:cpt] 
                cpt += 1
            end
            push!(res, (:IDENT, buffer))
        elseif isnumber(ln[cpt])
            while cpt <= N && isnumber(ln[cpt])
                buffer = buffer*ln[cpt:cpt]
                cpt += 1
            end
            push!(res, (:NUMBER, buffer))
        else 
            error("Caractere $(Int(ln[cpt])) non reconnu")
        end
    end
    return res
end

type scanIteratorGPL
    data::Array{Tuple{Symbol,String}}
    cpt::Int
end
scanIteratorGPL(data) = scanIteratorGPL(data,1) #Constructeur


function next(scanIt::scanIteratorGPL)
    scanIt.cpt += 1
end

function get(scanIt::scanIteratorGPL)

    length(scanIt.data) < scanIt.cpt && error("scan terminé")
    return scanIt.data[scanIt.cpt]
end


function analyseGPL(p::PTR,os="")::Bool

    isa(p, atom) && println("$os$p")
    !isa(p, atom) && println("$os$(ptrToString(p))")

    if isa(p, conc)
        return analyseGPL(p.left,os*"-|") && analyseGPL(p.right,os*"-|")
    elseif isa(p, union)
        return analyseGPL(p.left,os*"-|") || analyseGPL(p.right,os*"-|")
    elseif isa(p,star)
        while analyseGPL(p.stare,os*"-|") end
        return true
    elseif isa(p,un)
        analyseGPL(p.une,os*"-|")
        return true
    elseif isa(p, atom)
        if p.atomType == TER
            symbole,str = get(scanItGPL)
            println("SCANNER : ",symbole," - ",str)
            if p.COD == symbole
                println("true")
                if p.action != 0
                    GPL_Action(p.action)
                end
                next(scanItGPL)
                return true
            else 
                println("false")
                return false
            end
        else
            if !(p.COD in Dict_NT)
                error("Don't know any rule for Non-Terminal symbol $(p)")
            end
            numero_regle = findlast(Dict_NT,p.COD)
            # println(p.COD)
            # println("rule : ",numero_regle)
            # println()
            if analyseGPL(A[numero_regle],os*"-|")
                if p.action != 0
                    GPL_Action(p.action)
                end
                return true
            else
                return false
            end
        end
    end
end