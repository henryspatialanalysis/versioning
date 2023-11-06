## #######################################################################################
##
## Test some config basics using the example config file
##
## #######################################################################################

config_fp <- system.file("extdata", "example_config.yaml", package = "versioning")
config <- versioning::Config$new(config_fp)

# Test basic config operations
testthat::test_that("config$config_list is a list", {
  testthat::expect_type(config$config_list, 'list')
})
testthat::test_that("Settings retrieval works for both top-level and nested settings", {
  testthat::expect_equal(config$get('a'), 'foo')
  testthat::expect_equal(config$get('group_c', 'e'), FALSE)
})
testthat::test_that("Settings retrieval fails when the setting does not exist", {
  testthat::expect_error(config$get('g'))
})

# Test filepath retrieval
testthat::test_that("Non-versioned directory retrieval works", {
  testthat::expect_equal(
    config$get_dir_path('raw_data'),
    config$get('directories', 'raw_data', 'path')
  )
})
testthat::test_that("Versioned directory retrieval works", {
  testthat::expect_equal(
    config$get_dir_path('prepared_data'),
    file.path(
      config$get('directories', 'prepared_data', 'path'),
      config$get('versions', 'prepared_data')
    )
  )
})
testthat::test_that("File retrieval works when the directory and file are defined", {
  testthat::expect_equal(
    config$get_file_path('raw_data', 'a'),
    file.path(
      config$get_dir_path('raw_data'),
      config$get('directories', 'raw_data', 'files', 'a')
    )
  )
  testthat::expect_equal(
    config$get_file_path('prepared_data', 'prepared_table'),
    file.path(
      config$get_dir_path('prepared_data'),
      config$get('directories', 'prepared_data', 'files', 'prepared_table')
    )
  )
})

# Test updating versions
config_v2 <- versioning::Config$new(config_fp, versions = list(prepared_data = 'v2'))
testthat::test_that("A Config object's versions can be updated on loading", {
  testthat::expect_equal(config_v2$get('versions', 'prepared_data'), 'v2')
  testthat::expect_equal(
    config_v2$get_dir_path('prepared_data'),
    file.path(config$get("directories", "prepared_data", "path"), "v2")
  )  
})
