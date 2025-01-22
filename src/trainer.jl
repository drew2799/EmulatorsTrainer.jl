function add_observable_df!(df::DataFrames.DataFrame, location::String, param_file::String,
    observable_file::String, first_idx::Int, last_idx::Int, get_tuple::Function)
    json_string = read(location*param_file, String)
    cosmo_pars = JSON3.read(json_string)

    observable = npzread(location*observable_file, "r")[first_idx:last_idx]
  
    if !any(isnan.(observable))
        observable_filtered = get_tuple(cosmo_pars, observable)
        push!(df, observable_filtered)
    else
        @warn "File with NaN at "*location
    end
  
    processed_observable = get_tuple(cosmo_pars, observable)
    push!(df, processed_observable)
    return nothing
end

function add_observable_df!(df::DataFrames.DataFrame, location::String, param_file::String,
    observable_file::String, get_tuple::Function)
    json_string = read(location*param_file, String)
    cosmo_pars = JSON3.read(json_string)

    observable = npzread(location*observable_file, "r")
    processed_observable = get_tuple(cosmo_pars, observable)
    push!(df, processed_observable)
    return nothing
end

function load_df_directory!(df::DataFrames.DataFrame, Directory,
    add_observable_df!::Function)
    for (root, dirs, files) in walkdir(Directory)
        for file in files
            file_extension = file[findlast(isequal('.'),file):end]
            if file_extension == ".json"
                add_observable_df!(df, root)
            end
        end
    end
end

function extract_input_output_df(df, n_input_features::Int, n_output_features::Int)
    array_df = Matrix(df)#convert df to matrix
    #TODO check wether this can be done WITHOUT n_input and n_output
    array_input = transpose(Array(array_df[:,1:n_input_features]))#6 as the number of input features
    array_output = zeros(n_output_features, length(array_input[1,:]))#2499 as the number of output features
    for element in 1:length(array_input[1,:])
        array_output[:,element] = array_df[element,n_input_features+1]
    end
    return array_input, array_output
end

function get_minmax_in(df, array_pars_in)
    #TODO check wether this can work on array_input
    in_MinMax = zeros(length(array_pars_in),2)
    for (idx, key) in enumerate(array_pars_in)
        in_MinMax[idx,1] = minimum(df[!,key])
        in_MinMax[idx,2] = maximum(df[!,key])
    end
    return in_MinMax
end

function get_minmax_out(array_out, n_output_features)
    out_MinMax = zeros(n_output_features,2)

    #this 3 is related to the number of selected features
    for i in 1:n_output_features
        out_MinMax[i, 1] = minimum(array_out[i,:])
        out_MinMax[i, 2] = maximum(array_out[i,:])
    end
    return out_MinMax
end

function maximin_df!(df, in_MinMax, out_MinMax)
    n_input_features, _ = size(in_MinMax)
    for i in 1:n_input_features
        df[!,i] .-= in_MinMax[i,1]
        df[!,i] ./= (in_MinMax[i,2]-in_MinMax[i,1])
    end
    for i in 1:nrow(df)
        df[!,"observable"][i] .-= out_MinMax[:,1]
        df[!,"observable"][i] ./= (out_MinMax[:,2]-out_MinMax[:,1])
    end
end

function splitdf(df, pct)
    @assert 0 <= pct <= 1
    ids = collect(axes(df, 1))
    shuffle!(ids)
    sel = ids .<= nrow(df) .* pct
    return view(df, sel, :), view(df, .!sel, :)
end

function traintest_split(df, test)
    te, tr = splitdf(df, test)
    return tr, te
end

function getdata(df, n_input_features::Int, n_output_features::Int)
    ENV["DATADEPS_ALWAYS_ACCEPT"] = "true"

    train_df, test_df = traintest_split(df, 0.2)

    xtrain, ytrain = extract_input_output_df(train_df, n_input_features, n_output_features)
    xtest, ytest = extract_input_output_df(test_df, n_input_features, n_output_features)

    return Float64.(xtrain), Float64.(ytrain), Float64.(xtest), Float64.(ytest)
end
