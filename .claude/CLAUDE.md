# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`versioning` is an **R package** that parses YAML config files to simplify versioned data pipeline management. It provides a `Config` R6 class for accessing config values and dispatching file reads/writes based on extension.

## Common Commands

```bash
make build        # Build the package tarball
make install      # Build and install locally
make build-docs   # Regenerate man pages from roxygen2 comments (devtools::document())
make check        # Run CRAN check (devtools::check(cran = TRUE))
```

Run tests (in an R session):
```r
devtools::test()                              # All tests
testthat::test_file("tests/testthat/test-example_config.R")  # Single file
```

## Documentation

Docs are built with **pkgdown** and auto-deployed to GitHub Pages on push to `main` via `.github/workflows/pkgdown.yml`.

- When adding a new exported function or class, add a `@export` roxygen tag and run `make build-docs` to regenerate `NAMESPACE` and `man/` files.
- The pkgdown reference page layout is configured in `_pkgdown.yml` — update it when adding new public symbols.
- Package version is in `DESCRIPTION`; update it when releasing.

## Architecture

### Core Components

**[R/Config.R](R/Config.R)** — The main `Config` R6 class. Loaded from a YAML file with two special top-level keys:
- `directories`: named list of directory definitions, each with `path`, optional `versioned: true`, and a `files` map of logical names to filenames.
- `versions`: current version strings for each versioned directory.

Key methods: `$get(...)` for arbitrary config values, `$get_dir_path(dir)` for resolving directory paths (inserting version if versioned), `$get_file_path(dir, file)` for full file paths, `$read(dir, file)` and `$write(x, dir, file)` for dispatched I/O.

**[R/autoread.R](R/autoread.R) / [R/autowrite.R](R/autowrite.R)** — Dispatcher functions that route file I/O to the appropriate reader/writer based on file extension. `get_file_reading_functions()` and `get_file_writing_functions()` return the extension→function maps. Supported formats: csv, rds, rda, yaml, txt, shp, tif, xls/xlsx, dta, dbf, and additional sf/terra spatial drivers.

**[R/utilities.R](R/utilities.R)** — `pull_from_list(x, ..., fail_if_null)` for safe nested list indexing with informative errors.

**[R/misc.R](R/misc.R)** — Internal helpers: `qstop()` (stop without call context), `require_namespace_or_stop(pkg)` (lazy-load optional packages).

### Dependency Strategy

Core imports: `R6`, `assertthat`, `glue`, `yaml`. Heavy optional packages (`data.table`, `sf`, `terra`, `readxl`, `haven`, `foreign`) are listed under `Suggests:` and loaded lazily via `require_namespace_or_stop()` only when the relevant file format is used.
