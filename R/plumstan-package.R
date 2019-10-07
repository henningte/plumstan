#'@importFrom Rdpack reprompt
NULL

#' The 'plumstan' package.
#'
#' @description \code{plumstan} provides functions in order to
#' compute age-depth models for sediment cores based on measured
#' \eqn{^{210}}Pb activities using a Bayesian statistical
#' framework developed and implemented in the R package \code{plum}
#' by \insertCite{AquinoLopez.2018;textual}{plumstan}. In contrast to
#' \code{plum}, \code{plumstan} relies on the programming language \code{Stan}
#' \insertCite{Carpenter.2017}{plumstan} (via its R
#' implementation \code{rstan} \insertCite{StanDevelopmentTeam.2019}{plumstan}) in
#' order to perform the Bayesian calculations. This has the
#' advantage that the Bayesian model can directly be integrated
#' into more complex models including project specific data and
#' modified and resulting models can be handled using the functions of
#' the \code{rstan} package or packages built upon this.
#'
#' @docType package
#' @name plumstan-package
#' @aliases plumstan
#' @useDynLib plumstan, .registration = TRUE
#' @import methods
#' @import Rcpp
#' @importFrom rstan sampling
#'
#' @references
#'   \insertAllCited{}
#'
NULL
