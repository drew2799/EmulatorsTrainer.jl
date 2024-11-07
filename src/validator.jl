function evaluate_residuals(Directory, dict_file::String, pars_array::Array{String},
    get_ground_truth::Function, get_emu_prediction::Function, get_σ::Function, n_combs::Int,
    n_output_features::Int)
    my_values = zeros(n_combs, n_output_features)
    i = 0
    for (root, dirs, files) in walkdir(Directory)
        for file in files
            file_extension = file[findlast(isequal('.'),file):end]
            if file_extension == ".json"
                res = get_single_residuals(root, dict_file, pars_array,
                get_ground_truth, get_emu_prediction, get_σ)
                i += 1
                my_values[i, :] = res
            end
        end
    end
    return my_values
end

function evaluate_sorted_residuals(Directory, dict_file::String, pars_array::Array{String},
    get_ground_truth::Function, get_emu_prediction::Function, get_σ::Function,
    n_combs::Int, n_output_features::Int)
    residuals = evaluate_residuals(Directory, dict_file, pars_array,
    get_ground_truth, get_emu_prediction, get_σ, n_combs, n_output_features)
    return sort_residuals(residuals, n_output_features, n_combs)
end

function sort_residuals(residuals, n_output, n_elements)
    sorted_residuals = zeros(n_elements, n_output)
    for i in 1:n_output
        sorted_residuals[:,i] = sort(residuals[:,i])
    end
    final_residuals = zeros(3, n_output)

    final_residuals[1,:] = sorted_residuals[trunc(Int, (n_elements*0.68)),:]
    final_residuals[2,:] = sorted_residuals[trunc(Int, (n_elements*0.95)),:]
    final_residuals[3,:] = sorted_residuals[trunc(Int, (n_elements*0.99)),:]

    return final_residuals
end


function get_single_residuals(location, dict_file::String, pars_array::Array{String},
    get_ground_truth::Function, get_emu_prediction::Function, get_σ::Function)
    json_string = read(location*"/"*dict_file, String)
    cosmo_pars_test = JSON3.read(json_string)

    input_test = [cosmo_pars_test[param] for param in pars_array]

    obs_gt = get_ground_truth(location)

    obs_emu = get_emu_prediction(input_test)
    σ_obs = get_σ(location)

    res = abs.(obs_gt .- obs_emu)./σ_obs

    return res
end
