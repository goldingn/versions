Sys.setenv("R_TESTS" = "")
library(testthat)
library(versions)

test_check("versions")
