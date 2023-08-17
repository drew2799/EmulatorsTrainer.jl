module EmulatorsTrainer

using DataFrames
using Distributions
using Distributed
using JSON3
using NPZ
using QuasiMonteCarlo
using Random

include("trainer.jl")
include("farmer.jl")

end # module EmulatorsTrainer
