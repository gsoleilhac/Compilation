
const GPL = "S -> 'begin'.DeclarVar.[Instr].'end'#25,
DeclarVar -> 'int'.DeclarVar2,
DeclarVar2 -> 'IDENT'#1.[','.'IDENT'#1].';',
AFFouINCouDEC -> 'IDENT'#2.AFFouINCouDEC2,
AFFouINCouDEC2 -> '='#3.Expr#4 + 
                    '++'#28 + 
                    '--'#29,
AFF -> 'IDENT'#2.'='#3.Expr#4,
Instr -> AFFouINCouDEC.';' + 
        'println'.'('.Expr.')'.';'#6 +
        'while'#7.Cond#8.'{'.Instr.[Instr].'}'#9 +
        'if'.Cond#22.'{'.[Instr].'}'.Else#24 + 
        'for'.'('.AFF.';'#7.Cond.';'#32.AFFouINCouDEC.')'#31.'{'.[Instr].'}'#30,
Else -> (/'else'#23.'{'.[Instr].'}'/),
Expr -> Expr2.Exprprime,
Exprprime -> '+'.Expr2#10.Exprprime +
              ['-'.Expr2#11.Exprprime],
Expr2 -> Expr3.Expr2prime,
Expr2prime -> '*'.Expr3#12.Expr2prime +
            ['/'.Expr3#13.Expr2prime],
Expr3 -> 'IDENT'#14 + 
        'NUMBER'#15 +
        'input()'#27 +
        '('.Expr.')', 
Cond -> Cond2.Condprime,
Condprime -> ['||'.Cond2#33.Condprime],
Cond2 -> Cond3.Cond2prime,
Cond2prime -> ['&&'.Cond3#34.Cond2prime],
Cond3 -> Expr.CondSymbol.Expr#16 + '['.Cond.']' + '!'.'['.Cond.']'#35,
CondSymbol -> '>'#17 + '>='#18 + '<'#19 + '<='#20 + '=='#21,;"



function GPL_Action(act::Int)::Void

    print_analyse_gpl && println("ACTION : ",act)
    
    global co

    symbol,varname = get(scanItGPL)
    if act == 1
        varname in DicoVar && error("Variable déja déclarée")
        push!(DicoVar, varname)
        global spx += 1
    elseif act == 2
        Pcode[co+1] = LDA
        Pcode[co+2] = findfirst(DicoVar, varname)
        co+=2
    elseif act == 3
        push!(pileExt, AFF)
    elseif act == 4
        Pcode[co+1] = pop!(pileExt)
        co+=1
    elseif act == 5
        Pcode[co+1] = LDV
        Pcode[co+2] = findfirst(DicoVar, varname)
        co+=2
    elseif act == 6
        Pcode[co+1] = WRTLN
        co+=1
    elseif act == 7
        push!(pileExt, co+1)
    elseif act == 8
        Pcode[co+1] = JIF
        push!(pileExt, co+2)
        co+=2
    elseif act == 9
        Pcode[co+1] = JMP
        adresseJIF = pop!(pileExt)
        Pcode[co+2] = pop!(pileExt)
        co+=2
        Pcode[adresseJIF] = co+1
    elseif act == 10
        Pcode[co+1] = ADD
        co+=1
    elseif act == 11
        Pcode[co+1] = SUB
        co+=1
    elseif act == 12
        Pcode[co+1] = MULT
        co+=1
    elseif act == 13
        Pcode[co+1] = DIV
        co+=1
    elseif act == 14
        Pcode[co+1] = LDV
        Pcode[co+2] = findfirst(DicoVar, varname)
        co+=2
    elseif act == 15
        Pcode[co+1] = LDC
        Pcode[co+2] = parse(Int, varname)
        co+=2
    elseif act == 16
        Pcode[co+1] = pop!(pileExt)
        co+=1
    elseif act == 17
        push!(pileExt, SUP)
    elseif act == 18
        push!(pileExt, SUPE)
    elseif act == 19
        push!(pileExt, INF)
    elseif act == 20
        push!(pileExt, INFE)
    elseif act == 21
        push!(pileExt, EQ)
    elseif act == 22
        Pcode[co+1] = JIF
        co+=2
        push!(pileExt, co)
    elseif act == 23
        Pcode[co+1] = JMP
        co+=2
        Pcode[pop!(pileExt)] = co+1
        push!(pileExt, co)
    elseif act == 24
        Pcode[pop!(pileExt)] = co+1
    elseif act == 25
        Pcode[co+1] = STOP
    elseif act == 26
        Pcode[co+1] = pop!(pileExt)
        co+=1
    elseif act == 27
        Pcode[co+1] = RDLN
        co+=1
    elseif act == 28
        Pcode[co+1] = INC
        co+=1
    elseif act == 29
        Pcode[co+1] = DEC
        co+=1
    elseif act == 30
        Pcode[co+1] = JMP
        at_JIF = pop!(pileExt)
        Pcode[co+2] = at_JIF + 3
        co += 2
        Pcode[at_JIF] = co + 1
    elseif act == 31
        Pcode[co+1] = JMP
        at_JMP = pop!(pileExt)
        TMP = pop!(pileExt)
        Pcode[co+2] = pop!(pileExt)
        co += 2
        Pcode[at_JMP] = co + 1
        push!(pileExt, TMP)
    elseif act == 32
        Pcode[co+1] = JIF
        Pcode[co+3] = JMP
        push!(pileExt, co+2)
        push!(pileExt, co+4)
        co += 4
    elseif act == 33
        Pcode[co+1] = OR
        co += 1
    elseif act == 34
        Pcode[co+1] = AND
        co += 1
     elseif act == 35
        Pcode[co+1] = NOT
        co += 1
    end
    return
end

