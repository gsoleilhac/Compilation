include("GdG.jl")
include("execution.jl")
include("GPL_GPLAction.jl") #defines GPL and GPL_Action
include("scan_analyse_action_G0.jl")
include("scan_analyse_GPL.jl")

print_analyse_gpl = true
print_execution = true

spx = 0
co = 0

const Pilex = Array{Union{Int, Bool}}(500)
const Pcode = Array{Union{Instructions, Int}}(500)
const pileExt= Array{Union{Instructions, Int}}(0)
const DicoVar = String[]

const A = GenForet()
const Dict_NT = [:S,:N,:E,:T,:F]
const Dict_T = Array{Symbol,1}(0)
const Pile = Vector{PTR}(0)

const scanIt = scanIterator(scan_G0(GPL))


print("\nanalyseG0 : ")
if !analyse(A[1]) println("fail") ; exit() end
println("ok\n")



# for i=6:length(A)
#     println(Dict_NT[i])
#     print_arbre(A[i])
#     println()
# end

if length(ARGS) != 1 println("missing filename") ; exit() end


program = readstring(ARGS[1])
const  scanItGPL = scanIteratorGPL(scan_GPL(program))

println(program,'\n')

print("\nanalyseGPL : ")
if !analyseGPL(A[6]) println("fail") ; exit() end
println("ok")

println("\nPcode : \n",Pcode[1:co],"\n")

println("Exécution : ")

co = 1
execute()
