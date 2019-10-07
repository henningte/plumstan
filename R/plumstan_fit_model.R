#'@importFrom Rdpack reprompt
NULL

#' Fits a \code{Stan} model for \eqn{^{210}}Pb based age-depth profiles.
#'
#' \code{plumstan_fit_model} takes an object of class \code{\link{plumstan_model}}
#' and passes it to \code{\link[rstan]{sampling}} in order to do the MCMC
#' sampling.
#'
#' @param plumstan_model An object of class \code{\link{plumstan_model}}.
#' @param ... further parameters passed to \code{\link[rstan]{sampling}}.
#' @return An object of class \code{\link[rstan]{stanfit-class}}.
#' @seealso .
#' @references
#' \insertAllCited{}
#' @examples #
#'
#' @export
plumstan_fit_model <- function(
  plumstan_model,
  ...
){

  # check
  # is_plumstan_model(plumstan_model)

  # MCMC sampling
  rstan::sampling(stanmodels$plumstan_model,
                  data = plumstan_model$stan_data,
                  ...)

}
