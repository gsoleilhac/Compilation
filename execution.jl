@enum Instructions LDA=1 LDV=2 LDC=3 JMP=4 JIF=5 JSR=6 RSR=7 SUP=8 SUPE=9 INF=10 INFE=11 EQ=12 DIFF=13 AND=14 OR=15 NOT=16 ADD=17 SUB=18 DIV=19 MULT=20 NEG=21 INC=22 DEC=23 RD=24 RDLN=25 WRT=26 WRTLN=27 AFF=28 STOP=29

function execute()
    while Pcode[co] != STOP
        interpret(Pcode[co])
    end
end

function interpret(x::Instructions)
    global spx, co
    if print_execution
        print(x)
        if x in [LDA, LDV, LDC, JMP, JIF]
            print(" ",Pcode[co+1])
        end
        println()
    end



    if x==LDA
        spx += 1
        Pilex[spx] = Pcode[co+1]
        co += 2
    elseif x==LDV
        spx += 1
        Pilex[spx] = Pilex[Pcode[co+1]]
        co += 2
    elseif x==LDC
        spx += 1
        Pilex[spx] = Pcode[co+1]
        co += 2
    elseif x==JMP
        co = Pcode[co+1]
    elseif x==JIF
        if Pilex[spx]
            co += 2
        else
            co = Pcode[co+1]
        end
        spx-= 1
    elseif x==JSR

    elseif x==RSR

    elseif x==SUP
        Pilex[spx-1] = Pilex[spx-1] > Pilex[spx]
        spx -= 1
        co += 1
    elseif x==SUPE
        Pilex[spx-1] = Pilex[spx-1] >= Pilex[spx]
        spx -= 1
        co += 1
    elseif x==INF
        Pilex[spx-1] = Pilex[spx-1] < Pilex[spx]
        spx -= 1
        co += 1
    elseif x==INFE
        Pilex[spx-1] = Pilex[spx-1] <= Pilex[spx]
        spx -= 1
        co += 1
    elseif x==EQ
        Pilex[spx-1] = Pilex[spx-1] == Pilex[spx]
        spx -= 1
        co += 1
    elseif x==DIFF
        Pilex[spx-1] = Pilex[spx-1] != Pilex[spx]
        spx -= 1
        co += 1
    elseif x==AND
        Pilex[spx-1] = Pilex[spx-1] && Pilex[spx]
        spx -= 1
        co += 1
    elseif x==OR
        Pilex[spx-1] = Pilex[spx-1] || Pilex[spx]
        spx -= 1
        co += 1
    elseif x==NOT
        Pilex[spx] = !Pilex[spx]
        co += 1
    elseif x==ADD
        Pilex[spx-1] += Pilex[spx]
        spx -= 1
        co += 1
    elseif x==SUB 
        Pilex[spx-1] -= Pilex[spx]
        spx -= 1
        co += 1
    elseif x==DIV
        Pilex[spx-1] = Pilex[spx-1] / Pilex[spx]
        spx -= 1
        co += 1
    elseif x==MULT
        Pilex[spx-1] = Pilex[spx-1] * Pilex[spx]
        spx -= 1
        co += 1
    elseif x==NEG
        Pilex[spx] *= -1
        co += 1
    elseif x==INC
        Pilex[Pilex[spx]] += 1
        spx -= 1
        co += 1
    elseif x==DEC
        Pilex[Pilex[spx]] -= 1
        spx -= 1
        co += 1
    elseif x==RD

    elseif x==RDLN
        print(">")
        val = parse(Int,readline())
        Pilex[spx+1] = val
        spx += 1
        co += 1
    elseif x==WRT
        print(Pilex[spx])
        spx-=1
        co += 1
    elseif x==WRTLN
        println(Pilex[spx])
        spx-=1
        co += 1
    elseif x==AFF
        Pilex[Pilex[spx-1]] = Pilex[spx]
        spx -= 2
        co += 1
    elseif x==STOP
        return 0
    end

    print_execution && println(Pilex[1:spx])
end