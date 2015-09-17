#' installed.versions
#'
#' List the Versions of Packages Installed in a Specified Library
#'
#' @description List the installed versions of packages in a library directory
#'
#' @param pkgs character vector of the names of packages for which to query the
#'  installed versions
#'
#' @param lib character vector of length one giving the library directory
#'  containing the packages to query. If missing, defaults to the
#'  first element of \code{\link{.libPaths}()}.
#'
#' @return a named character vector of version numbers corresponding to
#' \code{pkgs}, with names giving the package names. If a packakge could not be
#' found in \code{lib}, an NA will be returned.
#'
#' @export
#' @name installed.versions
installed.versions <- function (pkgs,
                                lib) {

  if (missing(lib) || is.null(lib)) {
    lib <- .libPaths()[1L]
    if (length(.libPaths()) > 1L)
      message(sprintf(ngettext(length(pkgs), "Installing package into %s\n(as %s is unspecified)",
                               "Installing packages into %s\n(as %s is unspecified)"),
                      sQuote(lib), sQuote("lib")), domain = NA)
  }


  # vectorise by recursion
  if (length(pkgs) > 1) {
    ans <- sapply(pkgs,
                  installed.versions,
                  lib)

    return (ans)
  }

  # get path to package description
  desc_path <- sprintf('%s/%s/DESCRIPTION',
                       lib,
                       pkgs)

  # check it exists
  if (!file.exists(desc_path)) {

    warning (sprintf('package %s is not in the specified library, returning NA',
                     pkg))
    return(NA)

  } else {

    lines <- readLines(desc_path)
    vers_line <- lines[grep('^Version: *', lines)]
    vers <- gsub('Version: ', '', vers_line)

    return (vers)

  }


}
