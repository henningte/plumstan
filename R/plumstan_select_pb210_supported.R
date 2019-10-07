#'@importFrom Rdpack reprompt
NULL

#' Selects samples in a \code{plumstan_data_input} object to retain for estimating the supported \eqn{^{210}}Pb activity.
#'
#' \code{plumstan_select_pb210_supported} takes an object of class
#' \code{\link{plumstan_data_input}} and selects all rows to use in order
#' to estimate the supported \eqn{^{210}}Pb activity. This are all rows for
#' which \code{data_input$data_type == "ra226"} and for which
#' \code{data_input$data_type == "pb210" & data_input$depth_lower < d},
#' whereby \code{d} is a user-defined value for the lower depth of a section below
#' which all measured \eqn{^{210}}Pb activities are considered as supported
#' \eqn{^{210}}Pb activities.
#'
#' @param data_input An object of class \code{\link{plumstan_data_input}}
#' containing the measured \eqn{^{210}}Pb activities and optionally measured
#' \eqn{^{226}}Ra activities and ages inferred from \eqn{^{137}}Cs peaks from
#' which to construct the Bayesian age-depth model.
#' @param d A numeric value indicating the lower depth of a section below
#' which all measured \eqn{^{210}}Pb activities are considered as supported
#' \eqn{^{210}}Pb activities. I fset to \code{NULL}, only \eqn{^{226}}Ra activities
#' are used in order to estimate the supported \eqn{^{210}}Pb activity.
#' @return A logical vector with an element for each row in \code{data_input}
#' indicating if the corresponding values should be used in order to estimate the
#' supported \eqn{^{210}}Pb activity (\code{TRUE}) or not (\code{FALSE}).
#' @seealso .
#' @references
#' \insertAllCited{}
#' @examples #
#'
#' @export
plumstan_select_pb210_supported <- function(
  data_input,
  d = NULL
){

  # checks
  # todo

  # if d is NULL set it to the maximum depth_lower
  if(is.null(d)) {
    d <- max(data_input$depth_lower)
  }

  # get the index
  data_input$data_type == "ra226" | (data_input$data_type == "pb210" & data_input$depth_lower > d)

}
