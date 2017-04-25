# utility functions for versions package

# read lines from a url more quickly and with a clearer error
# message on failure than readLines
url_lines <- function (url) {

  # create a tempfile
  file <- tempfile()

  # stick the html in there
  suppressWarnings(success <- download.file(url, file,
                                            quiet = TRUE))

  # if it failed, issue a nice error
  if (success != 0)
    stop ('URL does not appear to exist: ', url)

  # get the lines, delete the file and return
  lines <- readLines(file, encoding = "UTF-8")
  file.remove(file)
  lines

}


# return the url for the latest date on an index page of dates
# (by default the MRAN snappshot index page)
latest_mran <- function (url = 'https://mran.revolutionanalytics.com/snapshot') {

  # get all full dates
  dates <- scrape_index_dates(url)

  # get latest
  max <- as.character(max(as.Date(dates)))

  # form the url and return
  paste(url, max, sep = '/')

}

# list the dates in an index page file dates as subdirectories
scrape_index_dates <- function (url) {

  # get the lines
  lines <- url_lines(url)

  # keep only lines starting with hrefs
  lines <- grep('^<a href="*',
                lines,
                value = TRUE)

  # take the sequence after the href that is between the quotes
  lines <- gsub('.*href=\"([^\"]+)\".*',
                '\\1',
                lines)

  # remove the trailing slash
  lines <- gsub('/$',
                '',
                lines)

  # remove any lines that aren't 10 characters long (a date only)
  lines <- lines[nchar(lines) == 10]

  # return list in reverse
  rev(lines)

}


# list the package versions in an index page
scrape_index_versions <- function (pkgs) {

  url <- sprintf('%s/src/contrib/Archive/%s',
                             latest_mran(),
                             pkgs)
  # get the lines
  lines <- url_lines(url)

  # keep only lines starting with hrefs
  lines <- grep('^<a href="*',
                lines,
                value = TRUE)

  # take the sequence after the href that is between the quotes
  versions <- gsub('.*href=\"([^\"]+)\".*',
                   '\\1',
                   lines)

  # remove the leading package name
  versions <- gsub(sprintf('^%s_', pkgs),
                   '', versions)

  # remove the trailing tarball extension
  versions <- gsub('.tar.gz$',
                   '',
                   versions)

  # match the sequence in number-letter-number format
  dates <- gsub('.*  ([0-9]+-[a-zA-Z]+-[0-9]+) .*',
                '\\1',
                lines)

  # convert dates to standard format
  dates <- as.Date(dates, format = '%d-%b-%Y')

  # get them in date order
  o <- order(dates, decreasing = TRUE)

  # create dataframe, reversing both
  data.frame(version = versions[o],
             date = as.character(dates[o]),
             stringsAsFactors = FALSE)

}


# given a package name see if the package is present in the latest MRAN snapshot
# and return a scalar logical
package_in_archive <- function (pkg) {

  url <- paste0(latest_mran(), '/src/contrib/Archive')

  # get the lines
  lines <- url_lines(url)

  # keep only lines starting with hrefs
  lines <- grep('^<a href="*',
                lines,
                value = TRUE)

  # take the sequence after the href that is between the quotes
  items <- gsub('.*href=\"([^\"]+)\".*',
                '\\1',
                lines)

  # expected directory name
  dir <- paste0(pkg, '/')

  # search for the expected package directory
  dir %in% items

}


# given packages name and required versions,
# return a date when it was live on CRAN
version_to_date <- function (pkgs, versions) {

  # vectorise by recursion
  if (length(pkgs) > 1) {

    ans <- mapply(version_to_date,
                  pkgs,
                  versions)

    return (ans)

  }

  # get available versions for the package
  df <- available.versions(pkgs)[[1]]

  # error if the version is not recognised
  if (!(versions %in% df$version)) {
    stop (versions,
          " does not appear to be a valid version of '",
          pkgs,
          "'.\nUse available.versions('",
          pkgs,
          "') to get valid versions")
  }

  # find the row corresponding to the version
  idx <- match(versions, df$version)

  # error if the version is recognised, but not available on MRAN
  if (!df$available[idx]) {
    stop (versions,
          " is a valid version of '",
          pkgs,
          "', but was published before 2014-09-17 so cannot be downloaded",
          " from MRAN.\nTry using devtools::install_version to install the",
          " package from source in the CRAN archives")
  }

  # get the day *after* this version first appeared on CRAN, to use as the MRAN
  # snapshot date (in case of atime difference issue)
  date <- as.Date(df$date[idx]) + 1

  # make sure this wasn't before the MRAN start date
  # we already checked it's available, so this must be before it was superceded
  date <- max(date, as.Date('2014-09-17'))

  as.character(date)

}


# get current version of package
current_version <- function (pkg) {

  # get all current contributed packages in latest MRAN
  url <- paste0(latest_mran(), '/src/contrib')

  # get the lines
  lines <- url_lines(url)

  # keep only lines starting with hrefs
  lines <- grep('^<a href="*',
                lines,
                value = TRUE)

  # take the sequence after the href that is between the quotes
  tarballs <- gsub('.*href=\"([^\"]+)\".*',
                   '\\1',
                   lines)

  # match the sequence in number-letter-number format
  dates <- gsub('.*  ([0-9]+-[a-zA-Z]+-[0-9]+) .*',
                '\\1',
                lines)

  # convert dates to standard format
  dates <- as.Date(dates, format = '%d-%b-%Y')

  # get the ones matching the package
  idx <- grep(sprintf('^%s_.*.tar.gz$', pkg),
              tarballs)

  if (length(idx) == 1) {
    # if this provided exactly one match, it's the current package
    # so scrape the version and get the date

    versions <- tarballs[idx]

    # remove the leading package name
    versions <- gsub(sprintf('^%s_', pkg),
                     '',
                     versions)

    # remove the trailing tarball extension
    versions <- gsub('.tar.gz$',
                     '',
                     versions)

    dates <- dates[idx]

  } else {

    # otherwise return NAs
    versions <- dates <- NA

  }

  # return dataframe with these
  data.frame(version = versions,
             date = as.character(dates),
             stringsAsFactors = FALSE)

}

# check the status of a package (active or deprecated).
# give a message if it's deprecated and error if it's missing
package_status <- function (pkg) {

  # is there a version in the current snapshot?
  current_df <- current_version(pkg)
  active <- !is.na(current_df$version[1])

  # is there an archived version?
  archived <- package_in_archive(pkg)

  if (active) {

    # it's curently hosted on CRAN
    return ('active')

  } else {

    if (archived) {

      # it's been removed from CRAN, but archived versions are still available
      message("package '", pkg, "' has been removed from CRAN, but archived versions are still available")
      return ('deprecated')

    } else {

      # otherwise it was never on CRAN
      stop ("'", pkg, "' does not appear to be a valid package on CRAN")

    }

  }

}
