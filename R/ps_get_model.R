#' Creates a Stan model for \eqn{^{210}}Pb based age-depth profiles.
#'
#' \code{ps_get_model} takes data of measured \eqn{^{210}}Pb activity
#' depth profiles and measured supported \eqn{^{210}}Pb activities as input
#' and constructs a Stan model that represents a Bayesian age-depth
#' model.
#'
#' The Bayesian statistical framework and algorithm are derived from
#' \insertCite{AquinoLopez.2018;textual}{plumstan}, the corresponding R package
#' \href{https://github.com/maquinolopez/Plum}{\code{Plum}} and implemented
#' in \href{https://github.com/stan-dev/rstan}{\code{Stan} (respectively
#' \code{rstan})} \insertCite{Carpenter.2017, StanDevelopmentTeam.2019}{plumstan}.
#'
#' @param data_input An object of class \code{\link{ps_input}}
#' containing the measured \eqn{^{210}}Pb activities and optionally measured
#' \eqn{^{226}}Ra activities and ages inferred from \eqn{^{137}}Cs peaks from
#' which to construct the Bayesian age-depth model. Rows have to be ordered
#' in with decreasing values of \code{data_input$depth_lower}.
#' @param thickness A numeric value representing the thickness of the
#' artifial sections for which to construct the sediment accumulation
#' model [cm].
#' @param prior_supplyrate_alpha A numeric value representing the shape parameter
#' of the Gamma prior distribution for the atmospheric \eqn{^{210}}Pb supply rate
#' [Bq/kg]. The default value is chosen as reported by
#' \insertCite{AquinoLopez.2018;textual}{plumstan} and implemented in \code{Plum}.
#' @param prior_supplyrate_beta A numeric value representing the rate parameter
#' of the Gamma prior distribution for the atmospheric \eqn{^{210}}Pb supply rate
#' [Bq/kg]. The default value is chosen as reported by
#' \insertCite{AquinoLopez.2018;textual}{plumstan} and implemented in \code{Plum}.
#' @param prior_omega_alpha A numeric value representing the shape parameter
#' of the beta prior distribution for the depth accumulation rate memory
#' parameter \eqn{\omega}. The default value is chosen as reported by
#' \insertCite{AquinoLopez.2018;textual}{plumstan} and implemented in \code{Plum}.
#' @param prior_omega_beta A numeric value representing the rate parameter
#' of the beta prior distribution for the depth accumulation rate memory
#' parameter \eqn{\omega}. The default value is chosen as reported by
#' \insertCite{AquinoLopez.2018;textual}{plumstan} and implemented in \code{Plum}.
#' @param prior_dar_alpha A numeric value representing the shape parameter
#' of the Gamma prior distribution for the depth accumulation rate
#' [yr/cm]. The default value is chosen as reported by
#' \insertCite{AquinoLopez.2018;textual}{plumstan} and implemented in \code{Plum}.
#' @param prior_dar_beta A numeric value representing the rate parameter
#' of the Gamma prior distribution for the depth accumulation rate
#' [yr/cm]. The default value is chosen as reported by
#' \insertCite{AquinoLopez.2018;textual}{plumstan} and implemented in \code{Plum}.
#' @param prior_supported_pb210_alpha A numeric value representing the shape parameter
#' of the Gamma prior distribution for the auported \eqn{^{210}}Pb activity
#' [Bq/kg]. The default value is chosen as reported by
#' \insertCite{AquinoLopez.2018;textual}{plumstan} and implemented in \code{Plum}.
#' @param prior_supported_pb210_beta A numeric value representing the rate parameter
#' of the Gamma prior distribution for the auported \eqn{^{210}}Pb activity
#' [Bq/kg]. The default value is chosen as reported by
#' \insertCite{AquinoLopez.2018;textual}{plumstan} and implemented in \code{Plum}.
#' @return An object of class \code{\link{ps_model}}.
#' @seealso .
#' @references
#' \insertAllCited{}
#' @examples #
#'
#' @export
ps_get_model <- function(
  data_input,
  thickness = 1,
  prior_supplyrate_alpha = 2,
  prior_supplyrate_beta = prior_supplyrate_alpha/50,
  prior_omega_alpha = 4,
  prior_omega_beta = (prior_omega_alpha - 0.4 * prior_omega_alpha)/0.4,
  prior_dar_alpha = 1.5,
  prior_dar_beta = prior_dar_alpha/15,
  prior_supported_pb210_alpha = 2,
  prior_supported_pb210_beta = prior_supported_pb210_alpha/10
){

  # define data_input_index
  data_input_index <- factor(levels = c("data_chronology_pb210", "data_supported_pb210", "data_chronology_cs137"))
  data_input_index[data_input$type == "pb210" & !data_input$supported] <- "data_chronology_pb210"
  data_input_index[data_input$type == "pb210" & data_input$supported] <- "data_supported_pb210"
  data_input_index[data_input$type == "cs137"] <- "data_chronology_cs137"

  # split data_input and remove measurement_type column
  data_chronology <- data_input[data_input_index == "data_chronology_pb210",-match(c("type", "supported"), colnames(data_input))]
  data_supported <- data_input[data_input_index == "data_supported_pb210", -1]
  if(any(data_input_index == "data_chronology_cs137")) {
    data_cs <- data_input[data_input_index == "data_chronology_cs137",-1]
  } else {
    data_cs <- NULL
  }

  # compute the depth range for the age-depth-model (adm)
  depth_range <- range(c(data_chronology$depth_lower, data_cs$depth_lower))

  # construct boundaries of linear increments with equal thickness
  increment_boundaries <- 0
  increment_boundaries_max <- max(increment_boundaries)
  while(increment_boundaries_max < depth_range[2]){
    increment_boundaries <-
      c(increment_boundaries,
        increment_boundaries_max + thickness)
    increment_boundaries_max <- max(increment_boundaries)
  }
  increment_boundaries <- rev(increment_boundaries)

  # construct data.frame with increment boundaries
  data_increments <-
    data.frame(depth_lower = increment_boundaries[-length(increment_boundaries)],
               depth_upper = increment_boundaries[-1],
               stringsAsFactors = FALSE)

  # get the number of linear increments
  increment_sections_number <- nrow(data_increments)

  # define two indices representing the maximum linear increment and the first increment with a shallower upper boundary than the target depth
  index_depth_increments <- data.frame(
    upper = increment_sections_number,
    lower = sapply(data_chronology$depth_lower, function(x){
      max(which(data_increments$depth_lower >= x))
    }),
    lower_stump = sapply(data_chronology$depth_upper, function(x){
      ifelse(x == 0, increment_sections_number,  min(which(data_increments$depth_lower <= x)))
    }),
    stringsAsFactors = FALSE
  )

  # add the same indices for data_cs
  if(!is.null(data_cs)) {
    index_depth_increments_cs <- data.frame(
      upper = increment_sections_number,
      lower = sapply(data_cs$depth_lower, function(x){
        max(which(data_increments$depth_lower >= x))
      }),
      lower_stump = sapply(data_cs$depth_upper, function(x){
        ifelse(x == 0, increment_sections_number,  min(which(data_increments$depth_lower <= x)))
      }),
      stringsAsFactors = FALSE
    )
    index_depth_increments <-
      rbind(index_depth_increments,
            index_depth_increments_cs)
  }

  # construct the data to pass to Stan
  stan_data <- list(
    data_chronology_n = nrow(data_chronology), # number of samples for the adm
    data_supported_n = nrow(data_supported), # number of samples to estimate supported 210Pb activity
    increments_n = increment_sections_number, # number of linear increments
    data_chronology_y = data_chronology[,4] * data_chronology[,3] * 10, # 210Pb activity
    data_chronology_y_sd = data_chronology[,5] * data_chronology[,3] * 10, # 210Pb activity sd
    data_supported_y = array(data_supported[,4]), # 210Pb activity
    data_supported_y_sd = array(data_supported[,5]), # 210Pb activity sd
    data_chronology_depth_lower = data_chronology[,1], # target depths
    data_chronology_depth_upper = data_chronology[,2], # target depths
    data_chronology_density = data_chronology[,3], # sediment mass density
    data_supported_density = array(data_supported[,3]), # sediment mass density
    increments_thickness = rep(thickness, increment_sections_number), # thickness of increments
    index_depth_increments_lower = index_depth_increments$lower, # index for deeper increment boundary
    index_depth_increments_upper = index_depth_increments$upper, # index for upper increment boundary
    increments_depth_upper = data_increments$depth_upper,
    data_chronology_depth_multiplier = (data_chronology$depth_lower - data_chronology$depth_upper)/2,
    index_depth_increments_stump_lower = index_depth_increments$lower_stump,
    lambda = 0.03114, # 210Pb decay constant
    prior_phi_alpha = prior_supplyrate_alpha,
    prior_phi_beta = prior_supplyrate_beta,
    prior_omega_alpha = prior_omega_alpha,
    prior_omega_beta = prior_omega_beta,
    prior_alpha_alpha = prior_dar_alpha,
    prior_alpha_beta = prior_dar_beta,
    prior_data_supported_alpha = prior_supported_pb210_alpha,
    prior_data_supported_beta = prior_supported_pb210_beta
  )

  # add data on 137Cs dates if supplied
  if(!is.null(data_cs)){
    stan_data$data_cs_n <- nrow(data_cs)
    stan_data$data_cs_age <- array(data_cs[,3])
    stan_data$data_cs_age_sd <- array(rep(1, nrow(data_cs)))
    stan_data$data_cs_index <- array(c((stan_data$data_chronology_n + 2):(stan_data$data_chronology_n + 1 + stan_data$data_cs_n)))
    stan_data$data_chronology_depth = c(data_chronology[,1], data_cs[,1])
    data_chronology_depth_multiplier = c((data_chronology$depth_lower - data_chronology$depth_upper)/2, (data_cs$depth_lower - data_cs$depth_upper)/2)
  }

  # create sections data.frame
  sections <-
    data.frame(
      id = seq_len(increment_sections_number),
      depth_lower = data_increments$depth_lower,
      depth_upper = data_increments$depth_upper,
      stringsAsFactors = FALSE
    )

  # construct the plumstan_model object
  ps_model(
    data_input = data_input,
    data_input_index = data_input_index,
    sections = sections,
    stan_data = stan_data,
    stan_model =
      if(is.null(data_cs)) {
        stanmodels$plumstan_model
      } else {
        stanmodels$plumstan_model_cs
      }
  )

}
