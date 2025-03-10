#' Get the list of file reading functions
#'
#' @description Constructs a list of all file-reading functions based on extension
#'
#' @return Named list where the names are file extensions, and the values are functions
#'   that read a file. All functions have ... arguments that can be used to extend the
#'   basic function.
#'
#' @seealso [autoread()] [get_file_writing_functions()]
#'
#' @importFrom yaml read_yaml
#' @export
get_file_reading_functions <- function(){
  # Base list
  funs <- list(
    csv = function(file, ...){
      require_namespace_or_stop('data.table')
      data.table::fread(input = file, ...)
    },
    dbf = function(file, ...){
      require_namespace_or_stop('foreign')
      foreign::read.dbf(file = file, ...)
    },
    dta = function(file, ...){
      require_namespace_or_stop('haven')
      haven::read_dta(file = file, ...)
    },
    rda = function(file, ...) get(load(file = file, ...)),
    rds = function(file, ...) readRDS(file = file, ...),
    shp = function(file, ...){
      require_namespace_or_stop('sf')
      sf::st_read(dsn = file, ...)
    },
    tif = function(file, ...){
      require_namespace_or_stop('terra')
      terra::rast(x = file, ...)
    },
    txt = function(file, ...) readLines(con = file, ...),
    xls = function(file, ...){
      require_namespace_or_stop('readxl')
      readxl::read_excel(path = file, ...)
    },
    yaml = function(file, ...) yaml::read_yaml(file = file, ...)
  )

  # Other driver options for sf
  other_sf_exts <- c(
    "e00", "fgb", "gdb", "geojson", "geojsonseq", "gml", "gpkg", "gps", "gpx", "gtm",
    "gxt", "jml", "kml", "map", "mdb", "ods", "osm", "pbf", "sqlite", "vdv"
  )
  for(ext in other_sf_exts) funs[[ext]] <- funs$shp
  # Other driver options for terra
  other_terra_exts <- c('geotiff', 'nc')
  for(ext in other_terra_exts) funs[[ext]] <- funs$tif
  # Other driver options for data.table
  other_dt_exts <- c("tsv", "gz", "bz2")
  for(ext in other_dt_exts) funs[[ext]] <- funs$csv
  # Other duplicates
  funs$rdata <- funs$rda
  funs$xlsx <- funs$xls
  funs$yml <- funs$yaml

  # Return
  return(funs)
}

#' Auto-read from file
#'
#' @description Automatically read a file based on extension
#'
#' @param file Full path to be read
#' @param ... Other arguments to be passed to the particular loading function
#'
#' @seealso [get_file_reading_functions()] [autowrite()]
#'
#' @return The object loaded by the file
#'
#' @importFrom tools file_ext
#' @importFrom assertthat assert_that
#' @export
autoread <- function(file, ...){
  # Check file extension and whether file exists
  assertthat::assert_that(
    file.exists(file),
    msg = paste("Input file", file, "does not exist.")
  )
  assertthat::assert_that(
    !dir.exists(file),
    msg = paste("Input file", file, "must not be a directory.")
  )
  assertthat::assert_that(
    length(file) == 1,
    msg = "autoread takes one 'file' argument at a time."
  )
  # Check that extension is valid
  ext <- tolower(tools::file_ext(file))
  assertthat::assert_that(ext != "", msg = paste("File", file, "has no extension."))

  # Get the file-reading function, failing if there's no match for the extension
  file_reading_functions <- get_file_reading_functions()
  read_fun <- pull_from_list(x = file_reading_functions, ext)

  # Read the file and return
  output <- read_fun(file = file, ...)
  return(output)
}
