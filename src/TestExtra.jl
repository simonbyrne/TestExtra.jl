module TestExtra
using Base.Test


# Nice output for
# - local
# - travis
# - appveyor
# - circleci

# Line numbers should correspond to the error location!
# - https://github.com/JuliaLang/julia/issues/23987#issuecomment-334164560
# - provide a link?


export runtests


function testfiles(dir=".")
    filter(f -> ismatch(r"^[^\.].*\.jl$",f) && !(f == "runtests.jl"), readdir(dir))
end

function testnworkers()
    if haskey(ENV,"JULIA_TEST_NWORKERS")
        parse(Int, ENV["JULIA_TEST_NWORKERS"])
    else
        Sys.CPU_CORES
    end
end



function runtests(tests::AbstractVector, nworkers::Int=testnworkers())
    @sync for p in 1:nworkers
        @async while !isempty(tests)
            test = shift!(tests)
            pid = addprocs(1)[1]
            try
                remotecall_fetch(Main.eval, pid, :(using Base.Test))
                remotecall_fetch(Main.eval, pid, quote
                                 @testset $test begin
                                     include($test)
                                 end
                                 end)
            finally
                rmprocs(pid)
            end
        end
    end
end

runtests(nworkers::Int=testnworkers()) = runtests(testfiles(), nworkers)

end # module
