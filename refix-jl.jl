using Printf
using Random

mutable struct State
    try_consume   :: String
    write_success :: String
    write_failure :: String
    jump_success  :: Int64
end
include("print.jl")

function state_from(s)
    s = split(s)
    State(s[1],s[2],s[3],parse(Int64,s[4]))
end

function random_word(alph,l)
    string(join(rand(alph,l)))
end

function random_state(alph,max_len,con_len)
    try_consume = random_word(alph,rand(1:con_len))
    @label try_again
    s = random_word(alph,rand(1:max_len))
    f = random_word(alph,rand(1:max_len))
    if startswith(s,f) || startswith(f,s) @goto try_again end
    State(try_consume,s,f, rand(1:9))
end

function random_key(n, alph, max_len,con_len)
    f = State[]
    for i in 1:n push!(f, random_state(alph, max_len,con_len)) end
    for i in eachindex(alph)
        f[i].try_consume = alph[i:i]
    end
    g = Random.randperm(n)
    for i in eachindex(f)
        f[i].jump_success = g[i]
    end
    f
end


      
function key()
    f = State[]
    push!(f,state_from("  OO |   O   3"))
    push!(f,state_from("  O  |O  O   2"))
    push!(f,state_from("  |  O   |   4"))
    push!(f,state_from("  || |O  O|  1"))
    f
end
function print_state(s)
    @printf("%-4s %-4s %-4s %-4d\n", s.try_consume,s.write_success,s.write_failure,s.jump_success)
end

function print_key(f)
    for s in f print_state(s) end
    println()
end

function shift_f(f,s)
    g = Int64[]
    for i in 1:length(f)
        push!(g,f[i].jump_success)
    end
    g = circshift(g,s)
    for i in 1:length(f)
        f[i].jump_success = g[i]
    end
end
    


function encode(p,q,alph)
    f = deepcopy(q)
    c = ""
    s = 1
    while length(p) > 0
        if startswith(p, f[s].try_consume)
            l = length(f[s].try_consume)
            c *= f[s].write_success
            L = length(f[s].write_success)
            p = p[l+1:end] 
            s = mod1(s+ f[s].jump_success,length(f))
            #print_key(f)
            #@printf("shifted by %d\n",s)
        else
            c *= f[s].write_failure
            L = length(f[s].write_failure)
            s = mod1(s + 1,length(f))
            
        end
        shift_f(f,s+1)
        #@printf("%d   p  == %s\n",s,p)     
    end
    c
end

function decode(c,q,alph)
    f = deepcopy(q)
    p = ""
    s = 1
    while length(c) > 0
        if startswith(c, f[s].write_success)
            l = length(f[s].write_success)
            c = c[l+1:end]
            p *= f[s].try_consume
            L = length(f[s].try_consume)
            s = mod1( s + f[s].jump_success, length(f))
            #@printf("shifted by %d\n",L)
        elseif startswith(c, f[s].write_failure)
            l = length(f[s].write_failure)
            c = c[l+1:end]
            s = mod1(s + 1,length(f))
        end
        shift_f(f,s+1)
        #@printf("%d   p  == %s\n",s,p)     
    end
    p
end
     
        
        

function demo()
    alph = "O|"
    con_len = 1
    #alph = "abcdefghijklmnopqrstuvwxyz"
    f = random_key(23,alph,1, con_len)
    print_key(f)
    for i in 1:15
        p = random_word(alph,rand(2:7))
        c = encode(p,f,alph)
        c = reverse(c)
        c = encode(c,f,alph)
        c = reverse(c)     
        print(white(),"f( ",red())
        @printf("%-10s",p)
        print(white()," ) = ",yellow(), c, "\n")
        d = reverse(c)
        d = decode(d,f,alph)
        d = reverse(d)
        d = decode(d,f,alph)
        if p != d @printf("\nERROR\n") end
        #@printf("d = %s\n",d)
    end
    
end








