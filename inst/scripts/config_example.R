## #######################################################################################
##
## TEST THE CONFIG FILE I/O USING A SIMPLE EXAMPLE
##
## #######################################################################################

library(data.table); library(glue)
devtools::load_all()

example_config_fp <- "inst/extdata/example_config.yaml"
example_input_file <- "inst/extdata/example_input_file.csv"

config <- versioning::Config$new(config_list = example_config_fp)

# Create directories
dir.create(config$get_dir_path('raw_data'), recursive = T)
dir.create(config$get_dir_path('prepared_data'), recursive = T)

# Copy the example input file to the raw data folder
file.copy(example_input_file, config$get_file_path('raw_data', 'a'))

# Read that same table from file
dt <- config$read('raw_data', 'a')

# Write a prepared table and a summary to file
dt[, value := value**2 ]
config$write(dt, 'prepared_data', 'prepared_table')
config$write(
  glue::glue("The prepared table has {nrow(dt)} rows and {ncol(dt)} columns."),
  'prepared_data',
  'summary_text'
)
list.files(config$get_dir_path('prepared_data')) # Should show both files exist

# Confirm that the table was actually saved correctly
check_path <- config$get_file_path('prepared_data', 'prepared_table')
check_dt <- data.table::fread(check_path)
knitr::kable(check_dt)

# Write the config to the prepared data file as 'config.yaml'
config$write_self('prepared_data')
list.files(config$get_dir_path('prepared_data')) # Should now include 'config.yaml'

# Test a custom "v2" config
config_v2 <- versioning::Config$new(
  config_list = example_config_fp,
  versions = list(prepared_data = 'v2')
)
config_v2$get_dir_path('prepared_data') # Should end in ".../v2"
