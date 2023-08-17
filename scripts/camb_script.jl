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
pars.set_cosmology(H0   =CosmoDict["H0"],
                   ombh2=CosmoDict["ombh2"],
                   omch2=CosmoDict["omch2"],
                   mnu  =CosmoDict["mnu"],
                   omk  =CosmoDict["omk"],
                   tau  =CosmoDict["tau"],
                   Alens=CosmoDict["Alens"],
                   neutrino_hierarchy=CosmoDict["neutrino_hierarchy"],
                   num_massive_neutrinos=CosmoDict["num_massive_neutrinos"],
                  )

pars.InitPower.set_params(As=CosmoDict["As"],
                          ns=CosmoDict["ns"],
                          r=CosmoDict["r"])
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
clTT = totCL[:,0]
clEE = totCL[:,1]
clTE = totCL[:,3]
clPP = lens_potential[:,0]
