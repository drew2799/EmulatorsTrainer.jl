# EmulatorsTrainer.jl

`EmulatorsTrainer.jl` is a `Julia` package designed to train the emulators of the [CosmologicalEmulators](https://github.com/CosmologicalEmulators) GitHub organization.

## Structure

In order to train and validate an emulator, there are three major steps:

- **Dataset creation**. You need to create a dataset of ground-truth prediction (in most of our application, this relies on Boltzmann solvers or Perturbation Theory calculations)
- **Emulators Trainings**. After creating the training datasets, we need to actually train the emulators.
- **Emulators validation**. The last step is the emulator validation, in order to assess the accuracy of the trained emulator.

### Authors

- Marco Bonici, INAF - Institute of Space Astrophysics and Cosmic Physics (IASF), Milano
- Federico Bianchini, PostDoctoral researcher at Stanford

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

### License

`EmulatorsTrainer.jl` is licensed under the MIT "Expat" license; see
[LICENSE](https://github.com/CosmologicalEmulators/Effort.jl/blob/main/LICENSE) for
the full license text.
