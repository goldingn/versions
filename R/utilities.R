# utility functions for versions package

# read lines from a url with a clearer error message on failure
url.lines <- function (url) {
  lines <- tryCatch(
    suppressWarnings(readLines(url)),
    error = function (cond) {
      stop (sprintf('URL does not appear to exist: %s',
                    url))
    })
  return(lines)
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


# list the dates in an index page
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
  lines <- gsub('.*href=\"([^\"]+)\".*', '\\1', lines)

  # remove the leading package name
  lines <- gsub(sprintf('^%s_', pkgs),
                '', lines)

  # remove the trailing tarball extension
  lines <- gsub('.tar.gz$', '', lines)

  # return list in reverse
  return (rev(lines))

}
