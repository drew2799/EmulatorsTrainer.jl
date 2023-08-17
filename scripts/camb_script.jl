using Distributed
using NPZ
using ClusterManagers
using EmulatorsTrainer
using JSON3
using Random

addprocs_lsf(10)#this because I am using a lsf cluster. Use the appropriate one!
@everywhere begin
    using NPZ, EmulatorsTrainer, JSON3, Random, PyCall
    camb = pyimport("camb")

    pars = ["ln10As", "ns", "H0", "ombh2", "omch2", "tau"]
    lb = [2.5, 0.88, 40., 0.1933, 0.08, 0.02]
    ub = [3.5, 1.05, 100., 0.2533, 0.2, 0.12]


    n = 1000
    s = EmulatorsTrainer.create_training_dataset(n, lb, ub)

    root_dir = "/home/mbonici/test_emu"#this is tuned to my dir, use the right one for you!


    function camb_script(CosmoDict, root_path)
        rand_str = root_path*"/"*randstring(10)
        mkdir(rand_str)
        lmax = 10000

        # set_for_lmax
        lens_potential_accuracy = 8
        lens_margin = 2050

        # set_matter_power
        kmax = 10
        k_per_logint = 130
        nonlinear = True
        accurate_massive_neutrinos = True

        # set_accuracy
        AccuracyBoost = 2
        lSampleBoost = 2
        lAccuracyBoost = 2
        DoLateRadTruncation = False

        pars = camb.CAMBparams()
        pars.set_cosmology(H0 = round(CosmoDict["H0"]; sigdigits=6),
                        ombh2= round(CosmoDict["ombh2"]; sigdigits=6),
                        omch2= round(CosmoDict["omch2"]; sigdigits=6),
                        mnu  =0.06,
                        omk  =0.,
                        tau  = round(CosmoDict["tau"]; sigdigits=6),
                        Alens=1.,
                        neutrino_hierarchy="normal",
                        num_massive_neutrinos=1,
                        )

        pars.InitPower.set_params(As=round(exp(CosmoDict["ln10As"])*10^(-10); sigdigits=6),
                                ns=round(CosmoDict["ns"]; sigdigits=6),
                                r=0)
        pars.set_for_lmax(lmax,
                        lens_potential_accuracy=lens_potential_accuracy)

        pars.set_dark_energy(w=-1., wa=0., dark_energy_model="fluid")
        pars.WantTransfer = 1
        pars.NonLinear = model.NonLinear_both # Non-linear matter power & lensing, HMcode
        pars.Transfer.kmax = kmax
        pars.Transfer.k_per_logint = k_per_logint
        pars.Transfer.accurate_massive_neutrinos = accurate_massive_neutrinos

        pars.set_accuracy(AccuracyBoost=AccuracyBoost,
                        lSampleBoost=lSampleBoost,
                        lAccuracyBoost=lAccuracyBoost,
                        DoLateRadTruncation=DoLateRadTruncation)

        results = camb.get_results(pars)

        powers = results.get_cmb_power_spectra(pars, CMB_unit="muK")

        totCL=powers["total"]
        unlensedCL=powers["unlensed_scalar"]
        lens_potential=powers["lens_potential"]




        ll = np.arange(totCL.shape[0])
        len_l, _ = size(totCL)
        ll = Array(0:len_l)
        clTT = totCL[:,1]
        clEE = totCL[:,2]
        #clBB = totCL[:,3] @fbianchini? is this right?
        clTE = totCL[:,4]
        clPP = lens_potential[:,1]

        npzwrite(rand_str*"/cl_TT.npy", clTT)
        npzwrite(rand_str*"/cl_EE.npy", clEE)
        npzwrite(rand_str*"/cl_TE.npy", clTE)
        npzwrite(rand_str*"/cl_PP.npy", clPP)

        open(rand_str*"/capse_dict.json", "w") do io
            JSON3.write(io, CosmoDict)
        end

    end

end

EmulatorsTrainer.compute_dataset(s, pars, root_dir, test_script)

for i in workers()
	rmprocs(i)
end
