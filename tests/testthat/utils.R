# subset to the first (bottom) three versions available
first_three <- function (df) {
  idx <- nrow(df) - 3:1 + 1
  df[idx, ]
}

# remove package if it's installed
purge <- function (pkg) {
  version <- installed.versions(pkg)
  if (!is.na(version))
    remove.packages(pkg)
}
