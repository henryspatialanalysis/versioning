## #######################################################################################
##
## Basic test for the autoread function using the example CSV input file
##
## #######################################################################################

example_input_fp <- system.file(
  'extdata', 'example_input_file.csv', package = 'versioning'
)
dt <- versioning::autoread(example_input_fp)

testthat::test_that("Autoread reads a CSV file as a data.table", {
  testthat::expect_true(inherits(dt, 'data.table'))
})
