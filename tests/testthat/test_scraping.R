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

test_that('package_status behaves as expected', {

  skip_on_cran()

  # an invalid package should error
  expect_error(package_status('some_package'),
               "'some_package' does not appear to be a valid package on CRAN")

  # a valid, but deprecated package should give a message and return 'deprecated'
  expect_message(deprecated_status <- package_status('rnbn'),
               "package 'rnbn' has been removed from CRAN, but archived versions are still available")
  expect_identical(deprecated_status, 'deprecated')

  # a valid and current package should quietly return 'active'
  active_status <- package_status('versions')
  expect_identical(active_status, 'active')

})

test_that('version_to_date behaves as expected', {

  skip_on_cran()

  # the first and a recent version of a valid package should return the correct
  # date
  versions_0.1_date <- version_to_date('versions', '0.1')
  expect_identical(versions_0.1_date, '2015-09-19')

  versions_0.3_date <- version_to_date('versions', '0.3')
  expect_identical(versions_0.3_date, '2016-09-02')

  # should also work when vectorised
  versions_0.1_0.3_date <- version_to_date(c('versions', 'versions'),
                                           c('0.1', '0.3'))
  expect_identical(versions_0.1_0.3_date, c(versions = '2015-09-19',
                                            versions = '2016-09-02'))

  # an invalid version should error, starting with this message
  expect_error(version_to_date('versions', '0.15'),
               "^0.15 does not appear to be a valid version of 'versions'")

  # an invalid package should error
  expect_error(version_to_date('some_package', '0.1'),
               "'some_package' does not appear to be a valid package on CRAN")

  # a package archived pre-MRAN should error, starting with this message
  expect_error(version_to_date('survey', '3.30-2'),
               "^3.30-2 is a valid version of 'survey', but was published before 2014-09-17 so cannot be downloaded from MRAN")

  # a package active pre-MRAN and archived post-MRAN should have the MRAN start date
  survey_3.30_3_date <- version_to_date('survey', '3.30-3')
  expect_equal(survey_3.30_3_date, '2014-09-17')
  # (actually uploaded '2014-08-15')

})
