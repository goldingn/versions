# utility functions for versions package

# read lines from a url more quickly and with a clearer error
# message on failure than readLines
url.lines <- function (url) {

  # create a tempfile
  file <- tempfile()

  # stick the html in there
  suppressWarnings(success <- download.file(url, file,
                           quiet = TRUE))

  # if it failed, issue a nice error
  if (success != 0) {
    stop(sprintf('URL does not appear to exist: %s',
                 url))
  }

  # get the lines, delete the file and return
  lines <- readLines(file)
  file.remove(file)
  return (lines)
}


# return the url for the latest date on an index page of dates
# (by default the MRAN snappshot index page)
latest.MRAN <- function(url = 'https://mran.revolutionanalytics.com/snapshot') {
  # get all full dates
  dates <- scrape.index.dates(url)

  # get latest
  max <- as.character(max(as.Date(dates)))

  # form the url and return
  ans <- paste(url, max, sep = '/')
  return (ans)

}


# list the dates in an index page file dates as subdirectories
scrape.index.dates <- function (url) {

  # get the lines
  lines <- url.lines(url)

  # keep only lines starting with hrefs
  lines <- lines[grep('^<a href="*', lines)]

  # take the sequence after the href that is between the quotes
  lines <- gsub('.*href=\"([^\"]+)\".*', '\\1', lines)

  # remove the trailing slash
  lines <- gsub('/$', '', lines)

  # remove any lines that aren't 10 characters long (a date only)
  lines <- lines[nchar(lines) == 10]

  # return list in reverse
  return (rev(lines))

}


# list the package versions in an index page
scrape.index.versions <- function (url, pkgs) {

  # get the lines
  lines <- url.lines(url)

  # keep only lines starting with hrefs
  lines <- lines[grep('^<a href="*', lines)]

  # take the sequence after the href that is between the quotes
  versions <- gsub('.*href=\"([^\"]+)\".*', '\\1', lines)

  # remove the leading package name
  versions <- gsub(sprintf('^%s_', pkgs),
                '', versions)

  # remove the trailing tarball extension
  versions <- gsub('.tar.gz$', '', versions)

  # match the sequence in number-letter-number format
  dates <- gsub('.*  ([0-9]+-[a-zA-Z]+-[0-9]+) .*', '\\1', lines)

  # convert dates to standard format
  dates <- as.Date(dates, format = '%d-%b-%Y')

  # get them in date order
  o <- order(dates, decreasing = TRUE)

  # create dataframe, reversing both
  df <- data.frame(version = versions[o],
                   date = as.character(dates[o]),
                   stringsAsFactors = FALSE)

  return (df)

}

# given packages name and required versions,
# return a date when it was live on CRAN
version2date <- function (pkgs, versions) {

  # vectorise by recursion
  if (length(pkgs) > 1) {
    ans <- sapply(pkgs,
                  version2date,
                  versions)

    return (ans)
  }

  # get available versions for the package
  df <- available.versions(pkgs)[[1]]

  # error if the version is not recognised
  if (!(versions %in% df$version)) {
    stop (sprintf('%s does not appear to be a valid version of %s.
                  Use available.packages("%s") to get valid versions',
                  versions,
                  pkgs,
                  pkgs))
  }

  # find the row corresponding to the version
  idx <- match(versions, df$version)

  # error if the version is recognised, but not available on MRAN
  if (!df$available[idx]) {
    stop (sprintf("%s is a valid version of %s, but was published before
2014-09-17 and can therefore not be downloaded from MRAN.
Try using devtools::install_version to install the package
from its source in the CRAN archives.",
                  versions,
                  pkgs))
  }

  # get a middling date

  # append today's date (note idx is one off now)
  dates <- c(Sys.Date(),
             as.Date(df$date))

  # get the mean of the publication date and subsequent publication date
  # (or today) as the target date for version installation
  date <- as.character(mean(dates[idx + 0:1]))

  # return this
  return (date)

}
