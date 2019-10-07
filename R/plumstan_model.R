#'@importFrom Rdpack reprompt
NULL

#' Creates an object of class \code{plumstan_model}
#'
#' \code{plumstan_model} is the constructor functions for objects of class
#' \code{plumstan_model}. It is designed predominantly for internal use in
#' \code{\link{plumstan_get_model}} and contains all data needed to fit a
#' Bayesian age-depth model with \code{Stan}.
#'
#' @param data_chronology See \code{\link{plumstan_get_model}}.
#' @param data_supported See \code{\link{plumstan_get_model}}.
#' @param data_cs See \code{\link{plumstan_get_model}}.
#' @param sections A \code{data.frame} as constructed by \code{\link{plumstan_get_model}}
#' with a row fir each artificial section created for the age-depth model and
#' three columns:
#' \describe{
#'    \item{id}{an id for each section.}
#'    \item{depth_lower}{The lower depth of the current section [cm].}
#'    \item{depth_upper}{The upper depth of the current section [cm].}
#' }
#' @param stan_data A \code{list} with all data needed for the \code{Stan} model
#' given by \code{stan_model}.
#' @param stan_model A compiled \code{Stan} model (\code{\link[rstan]{stanfit-class}})
#' in order to construct the age-depth model based on the data in
#' \code{stan_data}.
#' @return An object of class \code{plumstan_model}, that is a list with the
#' following elements:
#' \describe{
#'   \item{data_input}{an object of class \code{\link{plumstan_data_input}}.}
#'   \item{data_input_index}{A factor with an element for each row in \code{
#'   data} and three levels: \code{"data_chronology_pb210"} if the data should be used
#'   to construct the age-depth model from measured \eqn{^{210}}Pb activities,
#'   \code{"data_supported_pb210"} if the data should be used to estimate the
#'   supported \eqn{^{210}}Pb activity and \code{"data_chronology_cs137"} if the
#'   data should be used to construct the age-depth model from known ages of
#'   \eqn{^{137}}Cs peaks.}
#'   \item{sections}{a \code{data.frame} with a row for each artificial section
#'   constructed and three columns:
#'   \describe{
#'     \item{id}{an id for each section.}
#'     \item{depth_lower}{The lower depth of the current section [cm].}
#'     \item{depth_upper}{The upper depth of the current section [cm].}
#'   }}
#'   \item{stan_data}{a list containing the data needed for the \code{Stan} model.}
#'   \item{stan_model}{The compiled \code{Stan} model
#'   (\code{\link[rstan]{stanfit-class}}).}
#' }
#' @seealso .
#' @references
#' \insertAllCited{}
#' @examples #
#'
#' @export
plumstan_model <- function(
  data_input,
  data_input_index,
  sections,
  stan_data,
  stan_model
){

  # construct the plumstan_model object
  structure(list(
    data_input = data_input,
    data_input_index = data_input_index,
    sections = sections,
    stan_data = stan_data,
    stan_model = if(any(data_input_index == "data_chronology_cs137")) {
      stanmodels$plumstan_model
    } else {
      stanmodels$plumstan_model_cs
    }
    ),
    class = c("plumstan_model", "list"))

}
