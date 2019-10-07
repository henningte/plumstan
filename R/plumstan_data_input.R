#'@importFrom Rdpack reprompt
NULL

#' Creates an object of class \code{plumstan_data_input}
#'
#' \code{plumstan_data_input} is the constructor functions for objects of class
#' \code{plumstan_data_input}. It is constructed on order to handle the complete
#' measured \eqn{^{210}}Pb input depth profile based on which age-depth models
#' should be constructed.
#'
#' @param x A \code{data.frame} object with a row for each section and
#' data type (\eqn{^{210}}Pb or \eqn{^{226}}Ra activity or age inferred from
#' \eqn{^{137}}Cs data) and the following columns (in this
#' order):
#' \describe{
#'   \item{data_type}{The data type of the measurement for the current
#'     section. One of \code{c("pb210", "ra226" or "cs137_age")}.}
#'   \item{depth_lower}{The lower depth of the current section [cm].}
#'   \item{depth_upper}{The upper depth of the current section [cm].}
#'   \item{mass_density}{The mass density of the current section [g
#'     cm\eqn{^{-3}}].}
#'   \item{activity}{The measured activity of \eqn{^{210}}Pb (if
#'     \code{data_type = "pb210"}) or \eqn{^{226}}Ra (if
#'     \code{data_type = "ra226"}) [Bq kg\eqn{^{-1}}] or \code{NA}
#'     (if \code{data_type = "cs137"}).}
#'   \item{activity_sd}{The measurement error of the measured activity
#'     of \eqn{^{210}}Pb (if \code{data_type = "pb210"}) or \eqn{^{226}}Ra
#'     (if \code{data_type = "ra226"}) [Bq kg\eqn{^{-1}}] or \code{NA}
#'     (if \code{data_type = "cs137"}).}
#'   \item{cs137_age}{The age of a section as inferred from a
#'    \eqn{^{137}}Cs analysis if \code{data_type = "cs137"} (otherwise
#'    \code{NA}).}
#'   \item{cs137_age_sd}{The measurement error in the age estimate
#'     as inferred from a \eqn{^{137}}Cs analysis if
#'     \code{data_type = "cs137"} (otherwise \code{NA}). If data for
#'     \code{cs137_age} is available, but not for the corresponding error
#'     (as usually is the case), \code{cs137_age_sd} may be set to 1 in order
#'     to express high credibility in the \eqn{^{137}}Cs inferred age of
#'     the section [...].}
#' }
#' @return An object of class \code{plumstan_data_input}, that is a
#' \code{data.frame} object with a row for each section for which
#' \eqn{^{210}}Pb activities were measured and the following columns:
#' \describe{
#'   \item{data_type}{The data type of the measurement for the current
#'     section. One of \code{c("pb210", "ra226" or "cs137_age")}.}
#'   \item{depth_lower}{The lower depth of the current section [cm].}
#'   \item{depth_upper}{The upper depth of the current section [cm].}
#'   \item{mass_density}{The mass density of the current section [g
#'     cm\eqn{^{-3}}].}
#'   \item{activity}{The measured activity of \eqn{^{210}}Pb (if
#'     \code{data_type = "pb210"}) or \eqn{^{226}}Ra (if
#'     \code{data_type = "ra226"}) [Bq kg\eqn{^{-1}}] or \code{NA}
#'     (if \code{data_type = "cs137"}).}
#'   \item{activity_sd}{The measurement error of the measured activity
#'     of \eqn{^{210}}Pb (if \code{data_type = "pb210"}) or \eqn{^{226}}Ra
#'     (if \code{data_type = "ra226"}) [Bq kg\eqn{^{-1}}] or \code{NA}
#'     (if \code{data_type = "cs137"}).}
#'   \item{cs137_age}{The age of a section as inferred from a
#'    \eqn{^{137}}Cs analysis if \code{data_type = "cs137"} (otherwise
#'    \code{NA}).}
#'   \item{cs137_age_sd}{The measurement error in the age estimate
#'     as inferred from a \eqn{^{137}}Cs analysis if
#'     \code{data_type = "cs137"} (otherwise \code{NA}). If data for
#'     \code{cs137_age} is available, but not for the corresponding error
#'     (as usually is the case), \code{cs137_age_sd} may be set to 1 in order
#'     to express high credibility in the \eqn{^{137}}Cs inferred age of
#'     the section [...].}
#' }
#' @seealso .
#' @references
#' \insertAllCited{}
#' @examples #
#'
#' @export
plumstan_data_input <- function(
 x
){

  # checks
  # todo

  # construct the plumstan_data_input object
  structure(x[order(x$data_type, x$depth_lower, decreasing = TRUE),],
    class = c("plumstan_data_input", "data.frame")
    )

}
