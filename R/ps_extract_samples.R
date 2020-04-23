#' Creates an object of class \code{ps_input_data}
#'
#' \code{ps_extract_samples} extracts samples from a fitted
#' \code{\link[rstan]{stanfit}} object and stored them in a
#' \code{data.frame}
#'
#' @param x An object of class \code{\link[rstan]{stanfit}} fitted with
#' \code{\link{ps_fit_model}}.
#' @param ps_model The corresponding \code{\link{ps_model}}
#' object.
#' @return A \code{data.frame} object with a row for each combination
#' of an iter of the MCMC sampling AND each depth section (measured or
#' constructed artificially) and the following columns:
#' \describe{
#'   \item{iter}{An integer representing the iter of the MCMC.}
#'   \item{depth_profile}{A factor with two levels: \code{measured}
#'   if the corresponding section relates to a section of the measured
#'   depth profile and \code{artificial} if the corresponding section
#'   relates to a section of the artificially constructed depth profile
#'   used to model age-depth relations.}
#'   \item{depth_lower}{A numeric value representing the lower depth
#'   of the current section and MCMC iter.}
#'   \item{depth_upper}{A numeric value representing the upper depth
#'   of the current section and MCMC iter.}
#'   \item{age}{A numeric value representing the sampled age value for
#'   the current section and MCMC iter.}
#'   \item{depth_accumulation_rate}{A numeric value representing the sampled
#'   depth accumulation [yr/cm] value for the current section and MCMC
#'   iter. If \code{depth_profile == "measured"}, this is \code{NA} (may
#'   be implemented in the future).}
#'   \item{depth_accumulation_rate_alpha}{A numeric value representing the
#'   sampled depth accumulation [yr/cm] value for the current section
#'   and MCMC iter that is not related to the depth_accumulation of the
#'   previous section. If \code{depth_profile == "measured"}, this is
#'   \code{NA} since aggregation makes on sense here.}
#'   \item{pb210_tot}{A numeric value representing the sampled total
#'   \eqn{^{210}}Pb activity for the current section and MCMC iter.}
#'   \item{pb210_supported}{A numeric value representing the sampled
#'   supported \eqn{^{210}}Pb activity for the current section and
#'   MCMC iter.}
#'   \item{omega}{A numeric value representing the sampled
#'   memory parameter of the depth accumulation rates for the current
#'   section and MCMC iter.}
#' }
#' @seealso .
#' @references
#' \insertAllCited{}
#' @examples #
#'
#' @export
ps_extract_samples <- function(
  x,
  ps_model
){

  # checks
  # todo

  # extract the parameters from x
  x_parameters <- as.data.frame(rstan::extract(x, inc_warmup = FALSE))

  # extract the age values for the measured profile
  age_measured <- x_parameters[,stringr::str_detect(colnames(x_parameters), "^t\\.")]

  # extract the age values for the artificial profile
  age_artificial <- x_parameters[,stringr::str_detect(colnames(x_parameters), "^t_artificial\\.")]

  # etxtract the depth accumulation rates for the artificial profile
  depth_accumulation_rate_artificial <- x_parameters[,stringr::str_detect(colnames(x_parameters), "^m\\.")]

  # etxtract the intrinsic depth accumulation rates for the artificial profile
  depth_accumulation_alpha_artificial <- x_parameters[,stringr::str_detect(colnames(x_parameters), "^alpha\\.")]

  # extract the memory parameter
  omega <- x_parameters[,stringr::str_detect(colnames(x_parameters), "omega")]

  # extract the total 210Pb activity for the measured profile
  pb210_tot_measured <- x_parameters[,stringr::str_detect(colnames(x_parameters), "^p_tot_measured\\.")]

  # extract the total 210Pb activity for the artificial profile
  pb210_tot_artificial <- x_parameters[,stringr::str_detect(colnames(x_parameters), "^p_tot_artificial\\.")]

  # extract the supported 210Pb activity
  pb210_supported <- x_parameters[,stringr::str_detect(colnames(x_parameters), "data_supported_alpha")]

  # extract the supply rate of 210Pb
  pb210_supply <- x_parameters[,stringr::str_detect(colnames(x_parameters), "phi")]

  # get: number of MCMC iterations, number of measured sections, number of artificial sections
  n_iter <- nrow(x_parameters)
  n_sections_measured <- ncol(age_measured)-1
  n_sections_artificial <- ncol(age_artificial)

  # define the data type
  data_type <- as.character(ps_model$data_input_index[ps_model$data_input_index %in% c("data_chronology_pb210", "data_chronology_cs137")])
  data_type[data_type == "data_chronology_pb210"] <- "pb210"
  data_type[data_type == "data_chronology_cs137"] <- "cs137_age"

  # create the data.frame
  data.frame(
    iter = rep(seq_len(n_iter),
               n_sections_measured + n_sections_artificial),
    data_type = c(rep(data_type, each = n_iter),
                  rep(NA, n_iter * n_sections_artificial)),
    depth_profile = as.factor(
      c(rep("measured",
            n_sections_measured * n_iter),
        rep("artificial",
            n_sections_artificial * n_iter))),
    depth_lower = c(
      rep(ps_model$data_input$depth_lower[ps_model$data_input_index %in% c("data_chronology_pb210", "data_chronology_cs137")], each = n_iter),
      rep(ps_model$sections$depth_lower, each = n_iter)
    ),
    depth_upper = c(
      rep(ps_model$data_input$depth_upper[ps_model$data_input_index %in% c("data_chronology_pb210", "data_chronology_cs137")], each = n_iter),
      rep(ps_model$sections$depth_upper, each = n_iter)
    ),
    age = c(unlist(age_measured[,-1]),
            unlist(age_artificial)),
    depth_accumulation_rate = c(rep(NA, n_sections_measured * n_iter),
                                unlist(depth_accumulation_rate_artificial)),
    depth_accumulation_rate_alpha = c(
      rep(NA, n_iter * n_sections_measured),
      unlist(depth_accumulation_alpha_artificial)
    ),
    pb210_tot = c(unlist(pb210_tot_measured),
                  unlist(pb210_tot_artificial)),
    pb210_supported = rep(unlist(pb210_supported), n_sections_measured + n_sections_artificial),
    omega = rep(omega, n_sections_measured + n_sections_artificial),
    stringsAsFactors = FALSE
  )

}
