using Documenter, SBML

makedocs(
    modules = [SBML],
    clean = false,
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        canonical = "https://lcsb-biocore.github.io/SBML.jl/stable/",
    ),
    sitename = "SBML.jl",
    authors = "The developers of SBML.jl",
    linkcheck = !("skiplinks" in ARGS),
    pages = ["Home" => "index.md", "Reference" => "functions.md"],
    strict = [:missing_docs, :cross_references],
)

deploydocs(
    repo = "github.com/LCSB-BioCore/SBML.jl.git",
    target = "build",
    branch = "gh-pages",
    push_preview = false,
)
