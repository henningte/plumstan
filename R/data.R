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
#' @format A \code{data.frame} with 33 rows and 8 variables. Each row contains
#' information on one measurement for one depth section of the depth profile.
#' The column variables are:
#' \describe{
#'   \item{data_type}{The data type of the measurement for the current
#'     section. One of \code{c("pb210", "ra226" or "cs137_age")}. In this
#'     case, only \eqn{^{210}}Pb activities were measured and therefore this
#'     column contains only \code{"pb210"}.}
#'   \item{depth_lower}{The lower depth of the current section [cm].}
#'   \item{depth_upper}{The upper depth of the current section [cm].}
#'   \item{mass_density}{The mass density of the current section [g
#'     cm\eqn{^{-3}}].}
#'   \item{activity}{The measured activity of \eqn{^{210}}Pb for the
#'   current section.}
#'   \item{activity_sd}{The measurement error of the measured activity
#'     of \eqn{^{210}}Pb for the current section.}
#'   \item{cs137_age}{The age of a section as inferred from a
#'    \eqn{^{137}}Cs analysis. Since such data is not available and all
#'    rows correspond to \eqn{^{210}}Pb activity measurements, this is
#'    \code{NA}.}
#'   \item{cs137_age_sd}{The measurement error in the age estimate
#'     as inferred from a \eqn{^{137}}Cs analysis. Since such data is not
#'     available and all rows correspond to \eqn{^{210}}Pb activity
#'     measurements, this is \code{NA}.}
#' }
"plumstan_sample_data"
