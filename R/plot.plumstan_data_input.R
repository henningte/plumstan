#'@importFrom Rdpack reprompt
NULL

#' Plots objects of class \code{plumstan_data_input}
#'
#' \code{plot.plumstan_data_input} plots a measured depth profile of
#' \eqn{^{210}}Pb activities along with the corresponding measurement
#' errors and, if available, measured \eqn{^{226}}Ra activities. The
#' plot may be used to assess if background \eqn{^{210}}Pb activities
#' are reached in order to split the data for age-depth modeling into
#' sections of the profile used to estimate the supported \eqn{^{210}}Pb
#' activity (assumed constant over time) and to estimate the age-depth
#' model.
#'
#' @param x An object of class \code{\link{plumstan_data_input}}.
#' @param ... Further parameters (will be ignored).
#' @return An object of class \code{\link[ggplot2]{ggplot}}.
#' @seealso .
#' @references
#' \insertAllCited{}
#' @examples #
#'
#' @export
plot.plumstan_data_input <- function(
  x,
  ...
){

  # checks
  # todo

  # plot
  ggplot2::ggplot(data = x,
                  mapping = ggplot2::aes(x = depth_lower)) +
    ggplot2::geom_point(mapping = ggplot2::aes(y = activity,
                                      colour = data_type)) +
    ggplot2::geom_errorbar(mapping = ggplot2::aes(ymin = activity - activity_sd,
                                         ymax = activity + activity_sd,
                                         colour = data_type)) +
    ggplot2::labs(x = "Lower depth of section [cm]",
         y = expression(Activities~"["*Bq~kg^{-1}*"]"))

}
