context('available.packages')

test_that('available.packages behaves as expected', {

  skip_on_cran()

  # subset to the first (bottom) three versions available
  first_three <- function (df) {
    idx <- nrow(df) - 3:1 + 1
    df[idx, ]
  }

  # should error for an invalid package
  expect_error(available.versions('some_package'),
               "'some_package' does not appear to be a valid package on CRAN")

  # should message for a deprecated package but return the correct information
  expect_message(deprecated_list <- available.versions('rnbn'),
                 "package 'rnbn' has been removed from CRAN, but archived versions are still available")
  deprecated_df <- deprecated_list$rnbn

  # the versions we know about
  target_deprecated_df <- data.frame(version = c('1.1.2', '1.0.3', '1.0.0'),
                                 date = c('2017-01-12', '2016-12-05', '2014-07-22'),
                                 available = rep(TRUE, 3),
                                 stringsAsFactors = FALSE)

  # compare only the versions we know about
  expect_identical(first_three(deprecated_df),
                   target_deprecated_df)


  # should work on an active package
  active_list <- available.versions('versions')
  active_df <- active_list$versions

  # the versions we know about
  target_active_df <- data.frame(version = c('0.3', '0.2', '0.1'),
                                 date = c('2016-09-01', '2016-02-17', '2015-09-18'),
                                 available = rep(TRUE, 3),
                                 stringsAsFactors = FALSE)

  # compare only the versions we know about
  expect_identical(first_three(active_df),
                   target_active_df)

  # should also work when vectorised on active packages
  expect_message(vectorized_list <- available.versions(c('versions', 'rnbn')),
                 "package 'rnbn' has been removed from CRAN, but archived versions are still available")

  target_vectorized_list <- list(versions = target_active_df,
                                 rnbn = target_deprecated_df)

  # subset to first three versions
  vectorized_list_sub <- lapply(vectorized_list, first_three)
  expect_identical(vectorized_list_sub,
                   target_vectorized_list)

})

test_that('available.packages handles packages active when MRAN went live', {

  skip_on_cran()

  # packages that were active when MRAN went live (on 2014-09-17) should be
  # available. See: https://github.com/goldingn/versions/issues/10
  survey_list <- available.versions("survey")

  survey_df <- survey_list$survey
  idx <- which(survey_df$version == "3.30-3")
  expect_equal(survey_df$date[idx], "2014-08-15")
  expect_true(survey_df$available[idx])

})
