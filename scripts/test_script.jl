using Distributed
using NPZ
using ClusterManagers
using EmulatorsTrainer
using JSON3

addprocs_lsf(10)#this because I am using a lsf cluster. USe the appropriate one!

@everywhere begin
    using NPZ, EmulatorsTrainer, JSON3

    pars = ["a", "b", "c"]
    lb = [0., 0., 0.]
    ub = [1., 1., 1.]
    n = 1000
    s = EmulatorsTrainer.create_training_dataset(n, lb, ub)

    root_dir = "/home/mbonici/test_emu"

    function test_script(my_dict::Dict, root_path)
        a = my_dict["a"]
        b = my_dict["b"]
        c = my_dict["c"]
        x = Array(LinRange(0,10,100))
        y = a .* x .^ 2 .+ b .* x .+ c
        npzwrite(root_path*"/result.npy")
        open(root_path*"/dict.json", "w") do io
            JSON3.write(io, my_dict)
        end
    end
end

EmulatorsTrainer.compute_dataset(s, pars, root_dir, test_script)
