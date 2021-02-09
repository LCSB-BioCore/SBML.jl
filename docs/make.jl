using Documenter, SBML

makedocs(modules = [SBML],
    clean = false,
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        canonical = "https://lcsb-biocore.github.io/DistributedData.jl/stable/"),
    sitename = "SBML.jl",
    authors = "The developers of SBML.jl",
    linkcheck = !("skiplinks" in ARGS),
    pages = [
        "Documentation" => "index.md",
    ],
)

deploydocs(
    repo = "github.com/LCSB-BioCore/SBML.jl.git",
    target = "build",
    branch = "gh-pages",
    push_preview = true
)
