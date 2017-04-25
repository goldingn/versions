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

  # check the status of the package, with warnings
  status <- package_status(pkgs)

  # if it's active, start with the current version, else initiate an empty
  # dataframe
  if (status == 'active') {
    current_df <- current_version(pkgs)
  } else {
    current_df <- data.frame(version = '',
                             date = Sys.Date(),
                             stringsAsFactors = FALSE)[0, ]
  }

  # check for the package on the most recent MRAN image
  archived <- package_in_archive(pkgs)

  # if it is archived, get the previous versions
  if (archived) {

    # scrape the versions in the package archive for most recent MRAN
    previous_df <- scrape_index_versions(pkgs)

  } else {

    # otherwise, make it a blank row
    previous_df <- current_df[0, ]

  }

  # append previous versions to the current version
  df <- rbind(current_df,
              previous_df)

  # add whether they were posted since the start of MRAN
  df$available <- as.Date(df$date) >= as.Date('2014-09-17')

  # also find the most recent version before the start of MRAN
  if (!all(df$available)) {

    first_available <- min(which(as.Date(df$date) <= as.Date('2014-09-17')))
    df$available[first_available] <- TRUE

  }

  # wrap into a list
  ans <- list()
  ans[[pkgs]] <- df

  ans

}
