#' Fits a \code{Stan} model for \eqn{^{210}}Pb based age-depth profiles.
#'
#' \code{ps_fit_model} takes an object of class \code{\link{ps_model}}
#' and passes it to \code{\link[rstan]{sampling}} in order to do the MCMC
#' sampling.
#'
#' @param ps_model An object of class \code{\link{ps_model}}.
#' @param ... further parameters passed to \code{\link[rstan]{sampling}}.
#' @return An object of class \code{\link[rstan]{stanfit-class}}.
#' @seealso .
#' @references
#' \insertAllCited{}
#' @examples #
#'
#' @export
ps_fit_model <- function(
  ps_model,
  ...
){

  # check
  # is_ps_model(ps_model)

  # MCMC sampling
  rstan::sampling(stanmodels$plumstan_model,
                  data = ps_model$stan_data,
                  ...)

}
