#' \eqn{^{210}}Pb activity measurements of a sediment depth profile.
#'
#' A \code{data.frame} containing a real measured sample \eqn{^{210}}Pb
#' sediment depth profile from which sediment ages can be derived. See the
#' source section for the original source of the data. The data was
#' restructured to match the requirements of this package.
#'
#' @source
#' The complete data is derived from \insertCite{AquinoLopez.2018}{plumstan}
#' and was restructured to match the requirements of this package. The original
#' article containing the data can be downloaded from
#' \url{https://link.springer.com/article/10.1007\%2Fs13253-018-0328-7} and is
#' distributed under the Creative Commons Attribution 4.0 International
#' License (\url{http://creativecommons.org/licenses/by/4.0/}).
#'
#' @references
#' \insertAllCited{}
#'
#' @format A \code{\link{ps_input}} object (\code{data.frame}) with 33 rows
#' and 8 variables. Each row contains information on one measurement for one
#' depth section of the depth profile. See \code{\link{ps_input}} for information
#' on the variables.
"ps_sample_data"
