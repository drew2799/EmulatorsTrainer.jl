function create_training_dataset(n::Int, lb::Array, ub::Array)
    return QuasiMonteCarlo.sample(n, lb, ub, LatinHypercubeSample())
end

function create_training_dict(training_matrix::Matrix, idx_comb::Int, params::Array{String})
    return Dict([(value, training_matrix[idx_par, idx_comb])
    for (idx_par, value) in enumerate(params)])
end

function compute_dataset(training_matrix::Matrix, params::Array{String}, root_dir::String, script_func::Function)
    n_pars, n_combs = size(training_matrix)
    mkdir(root_dir)
    @sync @distributed for idx in 1:n_combs
        train_dict = create_training_dict(training_matrix, idx, params)
        script_func(train_dict, root_dir)
    end
end
