context('installing')

test_that('install.versions behaves as expected', {

  skip_on_cran()

  purge <- function (pkg) {
    details <- installed.packages(pkg)
    if (nrow(details) > 0)
      remove.packages(pkg)
  }

  # should error for an invalid package, starting with this message
  expect_error(install.versions('some_package', '0.1'),
               "'some_package' does not appear to be a valid package on CRAN")

  # should message but work for a deprecated package
  purge('rnbn')
  expect_message(install.versions('rnbn', '1.0.3'),
                 "package 'rnbn' has been removed from CRAN, but archived versions are still available")
  rnbn_version <- installed.versions('rnbn')
  expect_identical(rnbn_version, '1.0.3')

  # should just work for an active package (this test will become redundant if
  # asserthat is deprecated)
  purge('assertthat')

  install.versions('assertthat', '0.2.0')
  assertthat_version <- installed.versions('assertthat')
  expect_identical(assertthat_version, '0.2.0')

})

test_that('install.dates behaves as expected', {

  skip_on_cran()

  purge <- function (pkg) {
    details <- installed.packages(pkg)
    if (nrow(details) > 0)
      remove.packages(pkg)
  }

  # should error for an invalid package, starting with this message
  expect_error(install.dates('some_package', Sys.Date()),
               "'some_package' does not appear to be a valid package on CRAN")

  # should message and error for a deprecated package, if run on on a date after it was removed
  purge('rnbn')

  expect_warning(
    expect_message(install.dates('rnbn', '2017-04-26'),
                   "package 'rnbn' has been removed from CRAN, but archived versions are still available"),
    "^package ‘rnbn’ is not available")
  rnbn_version <- installed.versions('rnbn')
  expect_identical(rnbn_version, NA)

  # should message but work for a deprecated package, if run on on a date it was active
  purge('rnbn')

  expect_message(install.dates('rnbn', '2017-01-01'),
                 "package 'rnbn' has been removed from CRAN, but archived versions are still available")
  rnbn_version <- installed.versions('rnbn')
  expect_identical(rnbn_version, '1.0.3')


})

test_that('installed.versions returns an NA is a package is not installed', {

  skip_on_cran()

  purge <- function (pkg) {
    details <- installed.packages(pkg)
    if (nrow(details) > 0)
      remove.packages(pkg)
  }

  purge('rnbn')

  rnbn_version <- installed.versions('rnbn')
  expect_identical(rnbn_version, NA)

})
