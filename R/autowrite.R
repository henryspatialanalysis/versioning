#' Get the list of file writing functions
#' 
#' @description Constructs a list of all file-reading functions based on extension
#' 
#' @return Named list where the names are file extensions, and the values are functions
#'   that read a file. All functions have ... arguments that can be used to extend the
#'   basic function.
#' 
#' @seealso [autoread()] [get_file_reading_functions()]
#' 
#' @importFrom data.table fwrite
#' @importFrom sf st_write
#' @importFrom terra writeRaster
#' @importFrom yaml write_yaml
#' @export
get_file_writing_functions <- function(){
  # Base list
  funs <- list(
    csv = function(x, file, ...) data.table::fwrite(x = x, file = file, ...),
    rda = function(x, file, ...) save(x, file = file, ...),
    rds = function(x, file, ...) saveRDS(object = x, file = file, ...),
    shp = function(x, file, ...) sf::st_write(obj = x, dsn = file, ..., append = FALSE),
    tif = function(x, file, ...){
      terra::writeRaster(x = x, filename = file, ..., overwrite = TRUE)
    },
    txt = function(x, file, ...) writeLines(text = x, con = file, ...),
    yaml = function(x, file, ...) yaml::write_yaml(x = x, file = file, ...)
  )

  # Duplicates
  funs$geojson <- funs$shp
  funs$geotiff <- funs$tif
  funs$rdata <- funs$rda
  funs$yml <- funs$yaml

  # Return
  return(funs)
} 

#' Auto-write to file
#' 
#' @description Automatically write an object to a file based on extension
#' 
#' @param x Object to be saved
#' @param file Full path to save the object to
#' @param ... Other arguments to be passed to the particular saving function
#'
#' @seealso [get_file_writing_functions()] [autoread()]
#'  
#' @return Invisibly passes TRUE if the file saves successfully
#' 
#' @importFrom tools file_ext
#' @importFrom assertthat assert_that
#' @export
autowrite <- function(x, file, ...){
  # Check file extension and whether the save directory exists
  save_dir <- dirname(file)
  assertthat::assert_that(
    dir.exists(save_dir),
    msg = paste("Save directory", save_dir, "does not exist.")
  )
  assertthat::assert_that(
    length(file) == 1,
    msg = "autowrite takes one 'file' argument at a time."
  )
  # Check that extension is valid
  ext <- tolower(tools::file_ext(file))
  assertthat::assert_that(ext != "", msg = paste("Output file", file, "has no extension."))

  # Get the file-reading function, failing if there is no match for the extension
  file_writing_functions <- get_file_writing_functions()
  write_fun <- pull_from_list(x = file_writing_functions, ext)

  # Save the file
  write_fun(x = x, file = file, ...)

  # If file saves successfully, invisibly return TRUE
  invisible(TRUE)
}
