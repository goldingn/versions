#' available.versions
#'
#' List All Versions of Packages and Those Available to Install From MRAN
#'
#' @description List all of the past versions of the named packages ever
#'  uploaded to CRAN (and therefore in the CRAN source archives), their
#'  publication dates and whether they can be installed from MRAN via
#'  \code{\link{install.versions}} or \code{\link{install.dates}}.
#'
#' @param pkgs character vector of the names of packages for which to query
#' available versions
#'
#' @return a list of dataframes, each giving the versions and publication dates
#'  for the corresponding elements of \code{pkgs} as well as whether they can be
#'  installed from MRAN
#'
#' @export
#' @name available.versions
available.versions <- function (pkgs) {

  # vectorise by recursion
  if (length(pkgs) > 1) {
    ans <- lapply(pkgs,
                  available.versions)

    # remove a level of listing
    ans <- lapply(ans, '[[', 1)

    return (ans)
  }

  # get most recent MRAN image URL
  archive_url <- sprintf('%s/src/contrib/Archive/%s',
                         latest.MRAN(),
                         pkgs)

  # scrape the versions therein
  version <- scrape.index.versions(archive_url,
                                   pkgs)

  # return a dataframe
  df <- data.frame(version = version)

  # wrap into a list
  ans <- list()

  ans[[pkgs]] <- df

  return(ans)

}
