# EmulatorsTrainer.jl

`EmulatorsTrainer.jl` is a `Julia` package designed to train the emulators of the [CosmologicalEmulators](https://github.com/CosmologicalEmulators) GitHub organization.

## Structure

In order to train and validate an emulator, there are three major steps:

- **Dataset creation**. You need to create a dataset of ground-truth prediction (in most of our application, this relies on Boltzmann solvers or Perturbation Theory calculations)
- **Emulators training**. After creating the training datasets, we need to actually train the emulators.
- **Emulators validation**. The last step is the emulator validation, in order to assess the accuracy of the trained emulator.

`EmulatorsTrainer.jl` provides utilities for each of this three steps.

### Dataset creation

According to the emulator you are training (`Bora.jl`, `Capse.jl`, `Effort.jl`, etc...), specific dependencies and commands are going to be used. The design principle behind `EmulatorsTrainer.jl` is that it will contain only functions independent of the specific emulators to be trained. There will be no `CAMB`, `CLASS`, `pybird`, `velocileptors` dependencies. This is an intentional choice: the user has to write its own functions to compute the ground-truth.

In order to use the dataset creation feature, you need to write a function that computes your observables and stores it locally. The function object should receive two positional arguments as input, the dictionary with the value of the parameters and the root where to store the results of the computation.



!!! tip "Examples"
    Although we do not incorporate anything specific in this package, we have a gallery with some working examples.

!!! warning "Again on examples"
    We have not yet released any example. We plan to release a bunch of them in the near future.

As usual it is easier to show things, rather than explain them.

In this example, we are gonna show how to create the dataset for training `Capse.jl`. Let us start importing the relevant packages.

```julia
using Distributed
using NPZ
using ClusterManagers
using EmulatorsTrainer
using JSON3
using Random
```

Using [`ClusterManagers.jl`](https://github.com/JuliaParallel/ClusterManagers.jl) we can add some processes that we are gonna use to create the training dataset

```julia
addprocs_lsf(100; bsub_flags=`-q medium -n 2 -M 6094`)
```

!!! warning "Process creation"
    The previous command is specific for my computing farm (an LSF facility) with the resources required for my specific needs. Modify this command as appropriate for your use case!

After adding the processes, create a `begin`-`end` quote, such as the the following

```julia
@everywhere begin
    using NPZ, EmulatorsTrainer, JSON3, Random, PyCall
    camb = pyimport("camb")
    pars = ["ln10As", "ns", "H0", "ombh2", "omch2", "tau"]
    lb = [2.5, 0.88, 40., 0.1933, 0.08, 0.02]
    ub = [3.5, 1.05, 100., 0.2533, 0.2, 0.12]


    n = 1000
    s = EmulatorsTrainer.create_training_dataset(n, lb, ub)

    root_dir = "/path/where/save/computed/stuff"

    function camb_script(CosmoDict, root_path)
        rand_str = root_path*"/"*randstring(10)
        mkdir(rand_str)

        stuff = camb_compute(...)

        npzwrite(rand_str*"/stuff.npy", stuff)

        open(rand_str*"/capse_dict.json", "w") do io
            JSON3.write(io, CosmoDict)
        end
    end
end
```

What is done in this block?

- We import again the necessary modules, such that they are available to the loaded processes
- We import camb as well, using `PyCall`
- We create the combination of input cosmological parameters, after setting the lower and the upper bounds (`lb` and `ub`)
- We define the `camb_script` method, which takes as input the dictionary with the input cosmological parameters, computes `stuff` using `CAMB` and store both the dictionary and `stuff` in a generated subfolder

After this, the last missing command is

```julia
EmulatorsTrainer.compute_dataset(s, pars, root_dir, camb_script)
```

This command will execute `camb_script` for each combination of input cosmological parameters, using the available processes.

### Emulators training

### Emulators validation

## Authors

- Marco Bonici, INAF - Institute of Space Astrophysics and Cosmic Physics (IASF), Milano
- Federico Bianchini, PostDoctoral researcher at Stanford

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

### License

`EmulatorsTrainer.jl` is licensed under the MIT "Expat" license; see
[LICENSE](https://github.com/CosmologicalEmulators/EmulatorsTrainer.jl/blob/main/LICENSE) for
the full license text.
