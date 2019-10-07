data{

    // number samples with measured 210Pb activities
    int<lower=1> data_chronology_n;

    // number of samples representing supported 210Pb activities
    int<lower=1> data_supported_n;

    // number of linear increments with fixed length
    int<lower=1> increments_n;

    // number of 137Cs samples
    int<lower=1> data_cs_n;

    // measured 210Pb activities and errors
    real data_chronology_y[data_chronology_n];
    real<lower = 0> data_chronology_y_sd[data_chronology_n];
    real data_supported_y[data_supported_n];
    real<lower = 0> data_supported_y_sd[data_supported_n];

    // depth of the lower boundary of each sample
    real<lower = 0> data_chronology_depth[data_chronology_n + data_cs_n];

    // mass densities of each sample [g/cm^3]
    real<lower = 0> data_chronology_density[data_chronology_n];
    vector[data_supported_n] data_supported_density;

    // thickness of each linear increment
    real<lower = 0> increments_thickness[increments_n];
    real<lower = 0> increments_depth_upper[increments_n];

    // index for each target depth indicating the first deeper linear increment
    int<lower = 1>  index_depth_increments_lower[data_chronology_n + data_cs_n];

    // index for each target depth indicating the first shallower linear increment
    int<lower = 1>  index_depth_increments_upper[data_chronology_n + data_cs_n];

    // 210Pb decay rate
    real lambda;

    // age of 137Cs peak
    real<lower = 0> data_cs_age[data_cs_n];

    // sd of 137Cs age
    real<lower = 0> data_cs_age_sd[data_cs_n];

    // index for age vector 137Cs entries
    int<lower = 1> data_cs_index[data_cs_n];

    // prior parameters
    real prior_phi_alpha;
    real prior_phi_beta;
    real prior_omega_alpha;
    real prior_omega_beta;
    real prior_alpha_alpha;
    real prior_alpha_beta;
    real prior_data_supported_alpha;
    real prior_data_supported_beta;

}
parameters{

    // a real value representing the modeled atmospheric 210Pb supply rate
    real<lower = 0> phi;

    // a real value representing the modeled memory value of the autoregressive process
    real<lower = 0, upper = 1> omega;

    // a real value representing the modeled supported 210Pb activity
    real data_supported_alpha;

    // a vector with the depth accumulation rate solely from the current linear increment
    real<lower = 0> alpha[increments_n];

    }
transformed parameters {

    // a vector with the depth accumulation rates to model for each linear increment
    real<lower = 0> m[increments_n];

    // a vector storing the total 210Pb activity
    real p_tot[data_chronology_n];

    // peat ages the model should compute
    vector[data_chronology_n + 1 + data_cs_n] t;

    // compute the depth accumulation rates [yr/cm]
    m[1] = alpha[1];
    	for(k in 2:increments_n){
    m[k] = omega * m[k-1] + (1 - omega) * alpha[k];
    }

    // first peat age (at surface) is 0
    t[data_chronology_n + 1] = 0;

    // add 137Cs dates to t
    for(i in 1:data_cs_n){
    	t[data_cs_index[i]] = data_cs_age[i];
    }

    // compute the peat ages
    for(i in 1:(data_chronology_n + data_cs_n)){

    	// compute the peat age for each target depth
    	if(index_depth_increments_lower[i] == increments_n){

    		t[i] = (data_chronology_depth[i] - increments_depth_upper[index_depth_increments_lower[i]]) * m[index_depth_increments_lower[i]];

    	} else {

    		t[i] = dot_product(m[(index_depth_increments_lower[i]+1):index_depth_increments_upper[i]], increments_thickness[(index_depth_increments_lower[i]+1):index_depth_increments_upper[i]]) + (data_chronology_depth[i] - increments_depth_upper[index_depth_increments_lower[i]]) * m[index_depth_increments_lower[i]];

    	}

    }

    // compute the total 210Pb activity
    for(i in 1:data_chronology_n){

    	p_tot[i] = mean(data_supported_alpha * data_supported_density) * 10 + (phi/lambda) * (exp(-lambda * t[i+1]) - exp(-lambda * t[i]));

    }

    }
model{

    // priors

    // prior for the 210Pb atmospheric supply rate (is assumed constant)
    phi ~ gamma(prior_phi_alpha, prior_phi_beta);

    // prior for the supported 210Pb activity (is assumed constant)
    data_supported_alpha ~ gamma(prior_data_supported_alpha, prior_data_supported_beta);

    // prior for the memory parameter of the autoregressive process
    omega ~ beta(prior_omega_alpha, prior_omega_beta);

    // prior for the depth accumulation rate [yr/cm]
    alpha ~ gamma(prior_alpha_alpha, prior_alpha_beta);

    // compute the response of the model
    data_cs_age ~ normal(t[data_cs_index], data_cs_age_sd);
    data_supported_y ~ normal(data_supported_alpha, data_supported_y_sd);
    data_chronology_y ~ normal(p_tot, data_chronology_y_sd);

    }
generated quantities{

    // predicted values for each target depth
  vector[data_chronology_n] p_tot_measured;

  // predicted values for each depth of the artificial sections
  vector[increments_n] p_tot_artificial;

  // estimated ages for each artificial section
  vector[increments_n] t_artificial;

  // log-likelihhod of the model
  vector[data_chronology_n] log_lik;

  // deviance
  real dev;
  dev = 0;

  // compute predicted values for target depth
  for(n in 1:data_chronology_n){
  	p_tot_measured[n] = normal_rng(p_tot[n], data_chronology_y_sd[n]);
  }

  // compute predicted values for linear increments
  for(n in 1:increments_n){
  	p_tot_artificial[n] = dot_product(m[1:n], increments_thickness[1:n]);
  }

  // compute ages for each artificial section
  for(n in 1:increments_n){
    t_artificial[n] = dot_product(m[1:n], increments_thickness[1:n]);
  }

  // compute the deviance
  dev = dev + (-2)*normal_lcdf( data_chronology_y | p_tot, data_chronology_y_sd );

  // compute the log-likelihood
  for (n in 1:data_chronology_n) {
  	log_lik[n] = normal_lpdf(p_tot_measured[n] | p_tot[n], data_chronology_y_sd[n]);
  }

}
