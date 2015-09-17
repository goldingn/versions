#' available.versions
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
#' @examples
#'
#' \dontrun{
#'
#' # available versions of checkpoint
#' available.versions('checkpoint')
#'
#' # available versions of checkpoint and devtools
#' available.versions(c('checkpoint', 'devtools'))
#'
#' }
#'
available.versions <- function (pkgs) {

  # vectorise by recursion
  if (length(pkgs) > 1) {
    ans <- lapply(pkgs,
                  available.versions)

    # remove a level of listing
    ans <- lapply(ans, '[[', 1)

    names(ans) <- pkgs

    return (ans)
  }

  # get most recent MRAN image URL
  archive_url <- sprintf('%s/src/contrib/Archive/%s',
                         latest.MRAN(),
                         pkgs)

  # scrape the versions therein
  previous_df <- scrape.index.versions(archive_url,
                                   pkgs)

  # get the current version
  current_df <- current.version(pkgs)

  # append the current version
  df <- rbind(current_df,
              previous_df)

  # add whether they are on MRAN
  df$available <- as.Date(df$date) >= as.Date('2014-09-17')

  # wrap into a list
  ans <- list()

  ans[[pkgs]] <- df

  return(ans)

}
