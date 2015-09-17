#' install.dates
#'
#' Install the Latest Package Version as of a Specific Date from the MRAN Server
#'
#' @description Download and install the latest versions of packages hosted on
#'  CRAN as of a specific date from the MRAN server.
#'
#' @param pkgs character vector of the names of packages that should be
#'  downloaded and installed
#'
#' @param dates character or Date vector of the dates for which to install the
#' latest versions of \code{pkgs}. If this has the same length as \code{pkgs}
#'  versions will correspond to those packages. If this has length one
#'  the same version will be used for all packages. If it has any other
#'  length an error will be thrown.
#'
#' @param lib character vector giving the library directories where to
#'  install the packages. Recycled as needed. If missing, defaults to the
#'  first element of \code{\link{.libPaths}()}.
#'
#' @param \dots other arguments to be passed to \code{\link{install.packages}}.
#'  The arguments \code{repos} and \code{contriburl} (at least) will
#'  be ignored as the function uses the MRAN server to retrieve package versions.
#'
#' @export
#' @name install.dates
install.dates <- function (pkgs,
                           dates,
                           lib,
                           ...) {

  if (!inherits(verions, c('character', 'Date'))) {
    stop ('dates must be a vector of class character or Date')
  }

  if (length(versions) == 1) {
    rep(dates, length(pkgs))
  }

  if (length(dates) != length(pkgs)) {
    stop ('dates must be have either length one, or the same length as pkgs')
  }

  if (inherits(dates, 'Date')) {
    # coerce dates to character

  }

  install.packages(pkgs, lib, ...)

}
