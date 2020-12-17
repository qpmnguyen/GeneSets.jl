using GeneSets
using Documenter

makedocs(;
    modules=[GeneSets],
    authors="Quang Nguyen",
    repo="https://github.com/qpmnguyen/GeneSets.jl/blob/{commit}{path}#L{line}",
    sitename="GeneSets.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://qpmnguyen.github.io/GeneSets.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/qpmnguyen/GeneSets.jl",
)
