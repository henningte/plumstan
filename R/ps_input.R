#' Creates an object of class \code{ps_input}
#'
#' \code{ps_input} is the constructor function for objects of class
#' \code{ps_input}. This class aims to provide a concise organisation of
#' various data sources needed to estimate age-depth profiles ((supported)
#' \eqn{^{210}}Pb activities, \eqn{^{226}}Ra activities, \eqn{^{137}}Cs activities
#' and ages).
#'
#' @param x A \code{data.frame} with a row for each section and
#' data type (\eqn{^{210}}Pb or \eqn{^{226}}Ra activity or age inferred from
#' \eqn{^{137}}Cs data) and the following columns (in this
#' order):
#' \describe{
#'   \item{type}{The data type of the measurement for the current
#'     section. One of \code{c("pb210", "ra226" or "cs137")}.}
#'   \item{supported}{A logical vector indicating supported
#'   \eqn{^{210}}Pb or \eqn{^{226}}Ra activities (\code{TRUE}) or not
#'   \code{FALSE}.}
#'   \item{depth_lower}{The lower depth of the current section [cm].}
#'   \item{depth_upper}{The upper depth of the current section [cm].}
#'   \item{mass_density}{The mass density of the current section [g
#'     cm\eqn{^{-3}}].}
#'   \item{activity}{The measured activity [Bq kg\eqn{^{-1}}] or
#'   \code{NA} if no values are available.}
#'   \item{activity_sd}{The measurement error of the measured activity
#'     [Bq kg\eqn{^{-1}}] or \code{NA} if no values are available.}
#'   \item{age}{The age of a section or \code{NA} if such information
#'     is not available.}
#'   \item{age_sd}{The measurement error in the age estimate or \code{NA}
#'   if such information is not available.}
#' }
#' @return An object of class \code{ps_input}, that is a
#' \code{data.frame} with a row for each section and
#' data type (\eqn{^{210}}Pb or \eqn{^{226}}Ra activity or age inferred from
#' \eqn{^{137}}Cs data) and the following columns (in this
#' order):
#' \describe{
#'   \item{type}{The data type of the measurement for the current
#'     section. One of \code{c("pb210", "ra226" or "cs137")}.}
#'   \item{supported}{A logical vector indicating supported
#'   \eqn{^{210}}Pb or \eqn{^{226}}Ra activities (\code{TRUE}) or not
#'   \code{FALSE}.}
#'   \item{depth_lower}{The lower depth of the current section [cm].}
#'   \item{depth_upper}{The upper depth of the current section [cm].}
#'   \item{mass_density}{The mass density of the current section [g
#'     cm\eqn{^{-3}}].}
#'   \item{activity}{The measured activity [Bq kg\eqn{^{-1}}] or
#'   \code{NA} if no values are available.}
#'   \item{activity_sd}{The measurement error of the measured activity
#'     [Bq kg\eqn{^{-1}}] or \code{NA} if no values are available.}
#'   \item{age}{The age of a section or \code{NA} if such information
#'     is not available.}
#'   \item{age_sd}{The measurement error in the age estimate or \code{NA}
#'   if such information is not available.}
#' }
#' @seealso .
#' @references
#' \insertAllCited{}
#' @examples #
#'
#' @export
ps_input <- function(x) {

  # checks
  if(!inherits(x, "data.frame")) {
    rlang::abort(paste0("`x` must be a data.frame, not ", class(x)[[1]], "."))
  }
  colnames_expected <- c("type", "supported", "depth_lower", "depth_upper", "mass_density", "activity", "activity_sd", "age", "age_sd")
  cond <- !colnames_expected %in% colnames(x)
  if(any(cond)) {
    rlang::abort(paste0("`x` must contain the following columns: ", colnames_expected, ". `x` does not contain column(s) ", colnames_expected[cond], "."))
  }
  numeric_expected_vars <- colnames_expected[-c(1, 2)]
  numeric_expected <- !purrr::map_lgl(x[, numeric_expected_vars], function(x) is.numeric(x) || is.integer(x))
  if(any(numeric_expected)) {
    message <-
      tibble::tibble(
        var = numeric_expected_vars,
        cond = purrr::map(x[, numeric_expected_vars], function(x) class(x)[[1]]),
        message = paste0("`", numeric_expected_vars, "` must be numeric, not ", cond, ".\n")
      )
    rlang::abort(message$message[numeric_expected])
  }

  # construct the ps_input object
  structure(x[order(x$type, x$supported, x$depth_lower, decreasing = TRUE), ],
    class = c("ps_input", "data.frame")
    )

}
