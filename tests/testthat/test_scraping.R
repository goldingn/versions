context('scraping')

test_that('current_version handles valid, invalid and deprecated packages correctly', {

  skip_on_cran()

  null_df <- data.frame(version = NA,
                        date = as.character(NA),
                        stringsAsFactors = FALSE)

  # a package never on CRAN (no underscores allowed, so should be safe)
  invalid_version <- current_version('some_package')
  expect_identical(invalid_version, null_df)

  # a deprecated package
  deprecated_version <- current_version('rnbn')
  expect_identical(deprecated_version, null_df)

  # a valid package
  valid_version <- current_version('versions')

  # version number should be higher or equal to one we know about
  # (versions doesn't put patch numbers on CRAN,so this should be safe)
  scraped_version_number <- as.numeric(valid_version$version)
  target_version_number <- as.numeric("0.3")
  expect_gte(scraped_version_number, target_version_number)

  # date should be on or after one we know about
  scraped_datenum <- as.numeric(as.Date(valid_version$date))
  target_datenum <- as.numeric(as.Date("2016-09-01"))
  expect_gte(scraped_datenum, target_datenum)

})

test_that('package_in_archive finds a archived versions of versions', {

  skip_on_cran()

  # an invalid/non-archived package
  invalid_in <- package_in_archive('some_package')
  expect_false(invalid_in)

  # a valid and archived package
  valid_in <- package_in_archive('versions')
  expect_true(valid_in)

})
