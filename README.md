# versioning

An R package for versioned file I/O using a configuration file.

* _[Read the docs](https://henryspatialanalysis.github.io/versioning/)_
* _Available on [CRAN](https://cran.r-project.org/package=versioning)_
* _This is the R implementation of the versioning package; this same package is implemented in Python, and can be viewed on [GitHub](http://github.com/henryspatialanalysis/config-versioned/) and [PyPI](https://pypi.org/project/config-versioned/)._


## Overview

R data pipelines commonly require reading and writing data to versioned directories. Each
directory might correspond to one step of a multi-step process, where that version
corresponds to particular settings for that step and a chain of previous steps that each
have their own respective versions.

The **versioning** package simplifies management of project settings and file I/O by
combining them in a single `Config` object, backed by YAML configuration files that are
loaded from and saved to each versioned folder.


## Installation

```r
install.packages('versioning')
```


## Config File Format

The package uses YAML files for configuration. Settings can be any mix of scalar values,
lists, and nested groups. Two top-level keys have special meaning: `directories` and
`versions`.

```yaml
# Arbitrary settings
a: 'foo'
b: ['bar', 'baz']
group_c:
  d: 1e5
  e: false

# Directory definitions
directories:
  raw_data:
    versioned: FALSE          # no versioned sub-directory
    path: '~/project/raw_data'
    files:
      a: 'example_input_file.csv'
  prepared_data:
    versioned: TRUE           # paths include a version sub-directory
    path: '~/project/prepared_data'
    files:
      prepared_table: 'example_prepared_table.csv'
      summary_text: 'summary_of_rows.txt'

# Current version for each versioned directory
versions:
  prepared_data: 'v1'
```

Each entry in `directories` contains:

| Field | Type | Description |
|---|---|---|
| `versioned` | logical | Whether paths include a version sub-directory (e.g. `.../v1/`) |
| `path` | character | Base path to the directory |
| `files` | list | Named file references within the directory |

When `versioned: TRUE`, `config$get_dir_path('prepared_data')` returns
`~/project/prepared_data/v1` (appending the version from `versions$prepared_data`).


## Quick Start

```r
library(versioning)

# Load the example config bundled with the package
example_config_fp <- system.file('extdata', 'example_config.yaml', package = 'versioning')
config <- Config$new(config_list = example_config_fp)

# Print the full config
print(config)

# Access settings (throws an error if the key doesn't exist)
config$get('a')             #> [1] "foo"
config$get('group_c', 'd') #> [1] 1e+05

# Point directories at temporary folders for this example
config$config_list$directories$raw_data$path <- tempdir()
config$config_list$directories$prepared_data$path <- tempdir()

# Get directory and file paths
config$get_dir_path('prepared_data')      # <tempdir>/v1  (versioned)
config$get_file_path('raw_data', 'a')     # <tempdir>/example_input_file.csv

# Copy the bundled input file into the raw_data directory
file.copy(
  from = system.file('extdata', 'example_input_file.csv', package = 'versioning'),
  to   = config$get_file_path('raw_data', 'a')
)

# Read and write files (format inferred from extension)
df <- config$read(dir_name = 'raw_data', file_name = 'a')
config$write(df, dir_name = 'prepared_data', file_name = 'prepared_table')

# Save the config itself to the prepared_data directory as config.yaml
config$write_self(dir_name = 'prepared_data')
```


## Overriding Versions Programmatically

You can override specific versions at load time without editing the YAML file. This is
useful for passing versions as command-line arguments to a script:

```r
# Load config but change the "prepared_data" version to "v2"
config_v2 <- Config$new(
  config_list = 'path/to/config.yaml',
  versions = list(prepared_data = 'v2')
)
config_v2$get_dir_path('prepared_data')  # ~/project/prepared_data/v2
```


## Supported File Formats

`config$read()` and `config$write()` dispatch on file extension via `autoread()` and
`autowrite()`. Supported formats:

| Operation | Extensions |
|---|---|
| Read | `csv`, `dbf`, `dta`, `rda`, `rds`, `shp`, `tif` / `geotiff`, `txt`, `xls` / `xlsx`, `yaml` / `yml` |
| Write | `csv`, `rda`, `rds`, `shp`, `tif` / `geotiff`, `txt`, `yaml` / `yml` |

Required packages for each format are loaded on demand (e.g. **data.table** for CSV,
**sf** for shapefiles, **terra** for rasters).


## Further Reading

- Vignette: `vignette('versioning', package = 'versioning')`
- Config class reference: `help(Config, package = 'versioning')`
