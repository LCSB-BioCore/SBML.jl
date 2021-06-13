using DataFrames, CSV
using DifferentialEquations

using SBML

CONVERSION_OPTIONS = Dict("promoteLocalParameters" => nothing,
                              "expandFunctionDefinitions" => nothing,
                              "expandInitialAssignments" => nothing)

function setup_settings_txt(fn)
    ls = readlines(fn)
    spls = split.(ls, ": ")
    filter!(x->length(x) == 2, spls)
    Dict(map(x -> x[1] => Meta.parse(x[2]), spls))
end

function lower_one(fn, df; verbose=false)
    expected_errs = ["SBML files with rules are not supported",
                     "Cannot separate bidirectional kineticLaw",
                     "Model contains no reactions."]
    
    k = 0
    n_dvs = 0
    n_ps = 0
    atol = false
    rtol = false
    err = ""

    case_no = basename(fn)
    sbml_fn = joinpath(fn,case_no*"-sbml-l3v2.xml")
    settings_fn = joinpath(fn,case_no*"-settings.txt")
    results_fn = joinpath(fn,case_no*"-results.csv")
    try
        ml = readSBML(sbml_fn;conversion_options=CONVERSION_OPTIONS)
        k = 1
        rs = SBML.ReactionSystem(ml)
        k = 2
        sys = SBML.ODESystem(ml)
        n_dvs = length(states(sys))
        n_ps = length(parameters(sys))
        k = 3
        settings = setup_settings_txt(settings_fn)
        results = CSV.read(results_fn, DataFrame)
        ts = LinRange(settings["start"], settings["duration"], settings["steps"])
        prob = ODEProblem(sys, Pair[], (settings["start"], Float64(settings["duration"])); saveat=ts)
        k = 4
        sol = solve(prob, Tsit5())
        k = 5
        solm = Array(sol)'
        m = Matrix(results[1:end-1, 2:end])
        isapprox(solm, m; atol=1e-4) ? atol = true : atol = false
        isapprox(solm, m; rtol=1e-2) ? rtol = true : rtol = false
    catch e
        verbose && @info fn => e
        err = string(e)
        if sum([occursin(e, err) for e in expected_errs]) > 0
            err = "Expected error: "*err
        end
        if length(err) > 1000 # cutoff since I got ArgumentError: row size (9088174) too large 
            err = err[1:1000]
        end
    finally
        push!(df, (fn, k, n_dvs, n_ps, atol, rtol, err))
        verbose && printstyled("$fn done with a code $k\n"; color=:green)
    end
end

function lower_fns(fns; write_fn=nothing)
    df = DataFrame(file=String[], retcode=Int[], n_dvs=Int[], n_ps=Int[], atol=Bool[], rtol=Bool[], error=String[])
    for fn in fns
        lower_one(fn, df)
    end
    write_fn !== nothing && CSV.write(write_fn, df)
    df
end

function get_sbml_suite_fns(;repo_path=joinpath("..","..","SBMLBioModelsRepository.jl","data","sbml-test-suite","cases","semantic"))
    fns = filter(isdir, readdir(joinpath(repo_path); join=true))
    fns
end

suite_fns = get_sbml_suite_fns()
println(length(suite_fns))
suite_df = lower_fns(suite_fns; write_fn=joinpath("test", "logs", "test_suite_res.csv"))
