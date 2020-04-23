data{

  // number samples with measured 210Pb activities
  int<lower=1> data_chronology_n;

  // number of samples representing supported 210Pb activities
  int<lower=1> data_supported_n;

  // number of linear increments with fixed length
  int<lower=1> increments_n;

  // measured 210Pb activities and errors
  real data_chronology_y[data_chronology_n];
  real<lower = 0> data_chronology_y_sd[data_chronology_n];
  real data_supported_y[data_supported_n];
  real<lower = 0> data_supported_y_sd[data_supported_n];

  // depth of the lower boundary of each sample
  real<lower = 0> data_chronology_depth_lower[data_chronology_n];

  // mass densities of each sample [g/cm^3]
  real<lower = 0> data_chronology_density[data_chronology_n];
  vector[data_supported_n] data_supported_density;

  // thickness of each linear increment
  real<lower = 0> increments_thickness[increments_n];
  real<lower = 0> increments_depth_upper[increments_n];

  // index for each target depth indicating the first deeper linear increment
  int<lower = 1>  index_depth_increments_lower[data_chronology_n];

  // index for each target depth indicating the first shallower linear increment
  int<lower = 1>  index_depth_increments_upper[data_chronology_n];

  // 210Pb decay rate
  real lambda;

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

  real<lower = 0> phi; // atmospheric 210Pb supply rate
  real<lower = 0, upper = 1> omega; // memory value of the autoregressive process
  real data_supported_alpha; // supported 210Pb activity
  real<lower = 0> alpha[increments_n]; // the depth accumulation rate solely from the current linear increment

  }
transformed parameters {

  real<lower = 0> m[increments_n]; // the depth accumulation rates to model for each linear increment
  real p_tot[data_chronology_n]; // the total 210Pb activity
  vector[data_chronology_n + 1] t; // peat ages the model should compute

  // compute the depth accumulation rates [yr/cm]
  m[1] = alpha[1];
  for(k in 2:increments_n){
  	m[k] = omega * m[k-1] + (1 - omega) * alpha[k];
  }

  // first peat age (at surface) is 0
  t[data_chronology_n+1] = 0;

  // compute the peat ages
  for(i in 1:data_chronology_n){

  	// compute the peat age for each target depth
  	if(index_depth_increments_lower[i] == increments_n){

  		t[i] = (data_chronology_depth_lower[i] - increments_depth_upper[index_depth_increments_lower[i]]) * m[index_depth_increments_lower[i]];

  	} else {

  		t[i] = dot_product(m[(index_depth_increments_lower[i]+1):index_depth_increments_upper[i]], increments_thickness[(index_depth_increments_lower[i]+1):index_depth_increments_upper[i]]) + (data_chronology_depth_lower[i] - increments_depth_upper[index_depth_increments_lower[i]]) * m[index_depth_increments_lower[i]];

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
  	p_tot_artificial[n] = dot_product(m[n:increments_n], increments_thickness[n:increments_n]);
  }

  // compute ages for each artificial section
  for(n in 1:increments_n){
    t_artificial[n] = dot_product(m[n:increments_n], increments_thickness[n:increments_n]);
  }

  // compute the deviance
  dev = dev + (-2)*normal_lcdf( data_chronology_y | p_tot, data_chronology_y_sd );

  // compute the log-likelihood
  for (n in 1:data_chronology_n) {
  	log_lik[n] = normal_lpdf(p_tot_measured[n] | p_tot[n], data_chronology_y_sd[n]);
  }
}
