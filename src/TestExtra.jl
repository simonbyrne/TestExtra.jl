module TestExtra
using Base.Test

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

function runtests(tests::AbstractVector, nworkers::Int=testnworkers(); verbose=true)
    verbose && println("Testing with $nworkers workers")
    @testset "TOTAL" begin
        mts = Base.Test.get_testset()
        @sync for p in 1:nworkers
            @async while !isempty(tests)
                Base.Test.push_testset(mts)
                test = shift!(tests)
                verbose && println("Running $test")
                pid = addprocs(1)[1]
                try
                    remotecall_fetch(Main.eval, pid, :(using Base.Test))
                    rts = remotecall_fetch(Main.eval, pid, quote
                                     ts = Base.Test.DefaultTestSet($test)
                                     Base.Test.push_testset(ts)
                                     Base.Test.get_testset()
                                     try
                                         include($test)
                                     catch err
                                         Base.Test.record(ts, Error(:nontest_error, :(), err, Base.Test.catch_backtrace()))
                                     end
                                     Base.Test.pop_testset()
                                     ts
                    end)
                    Base.Test.finish(rts)
                finally
                    rmprocs(pid)
                end
            end
        end
    end
end

runtests(nworkers::Int=testnworkers(); kwargs...) = runtests(testfiles(), nworkers; kwargs...)

end # module
