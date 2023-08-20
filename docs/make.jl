using Documenter
using EmulatorsTrainer

ENV["GKSwstype"] = "100"

push!(LOAD_PATH,"../src/")

makedocs(
    modules = [EmulatorsTrainer],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true",
    sidebar_sitename=true),
    sitename = "EmulatorsTrainer.jl",
    authors  = "Marco Bonici",
    pages = [
        "Home" => "index.md",
    ]
)

deploydocs(
    repo = "github.com/CosmologicalEmulators/EmulatorsTrainer.jl.git",
    devbranch = "develop"
)
