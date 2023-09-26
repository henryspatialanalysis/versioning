#' R6 Class representing a configuration object
#' 
#' @details
#' The special sublist `directories` is structured to contain three items for each
#' directory name:
#'   - `versioned`: a T/F value specifying whether the directory is versioned
#'   - `path`: the full path to the top level of that directory.
#'   - `files`: A named list referencing file paths within that directory.
#' 
#' If the directory is versioned, a version must be set in the `versions` sublist of the
#' config list. `versions` is itself a named list where each key corresponds to a
#' versioned folder in `directories` and the value gives the particular folder version
#' (for example, a timestamp) that corresponds to the particular run.
#' 
#' @importFrom assertthat assert_that
#' @importFrom R6 R6Class
#' @importFrom utils str
#' @export
Config <- R6::R6Class(
  "Config",
  public = list(
    #' @field config_list The list representation of the Config object
    config_list = NULL,

    #' @description Create a new Config object
    #' 
    #' @param config_list either a list or a filepath to a YAML file containing that list
    #' @param versions (default NULL) A named list containing versions for versioned
    #'   directories. If passed, used to define or update items in `config_list$versions`.
    initialize = function(config_list, versions = NULL){
      # If `config_list` is a character vector, assume it is a filepath and read
      if(inherits(config_list, 'character')) config_list <- autoread(config_list)
      # Check that the config list is a list
      assertthat::assert_that(inherits(config_list, 'list'))

      # If custom versions have been passed, add them to config_list$versions
      if(length(versions) > 0){
        assertthat::assert_that(inherits(versions, 'list'))
        update_versions <- names(versions)
        assertthat::assert_that(
          !is.null(update_versions),
          msg = 'If passed, `versions` must be a named list.'
        )
        # Make sure that config_list$versions exists and is a list
        if(!inherits(config_list$versions, 'list')) config_list$versions <- list()
        for(update_v in update_versions){
          config_list$versions[[update_v]] <- versions[[update_v]]
        }
      }

      self$config_list <- config_list

      invisible(self)
    },

    #' @description Print the list representation of the Config object
    print = function(){
      utils::str(self$config_list)
      invisible(self)
    },

    #' @description Get a subset of the `config_list`
    #' 
    #' @details If no parameters are passed, returns the entire config_list
    #' 
    #' @param ... Nested indices (character or numeric) down the config list
    #' 
    #' @seealso [pull_from_list()]
    #' 
    #' @return A subset of the list. If the item is NULL or missing, returns an error
    get = function(...){
      return(pull_from_list(self$config_list, ...))
    },

    #' @description Construct a directory path from the config object
    #' 
    #' @details
    #' Works differently for versioned and non-versioned directories. See the class 
    #' description for more information.
    #' 
    #' @param dir_name Directory name
    #' @param custom_version (character, default NULL) A custom version that will be
    #'   applied to this folder, rather than pulling from `config_list$versions[[dir]]`.
    #'   Only applies to versioned folders.
    #' @param fail_if_does_not_exist (logical, default FALSE) should this method return an
    #'   error if the directory in question does not already exist?
    #' 
    #' @return The full path to the directory
    get_dir_path = function(
      dir_name, custom_version = NULL, fail_if_does_not_exist = FALSE
    ){
      dir_info <- self$get('directories', dir_name)
      versioned <- pull_from_list(dir_info, 'versioned')
      dir_base_path <- pull_from_list(dir_info, 'path')
      # Check that the version is a boolean value
      assertthat::assert_that(is.logical(versioned))
      assertthat::assert_that(length(versioned) == 1)

      # Get the directory path
      if(versioned){
        # If this directory is versioned, the full path is ({base path}/{version})
        if(!is.null(custom_version)){
          assertthat::assert_that(length(custom_version) == 1)
          dir_version <- custom_version
        } else {
          dir_version <- self$get('versions', dir_name)
        }
        dir_path <- file.path(dir_base_path, dir_version)
      } else {
        # If this directory is NOT versioned, the full path == the base path
        dir_path <- dir_base_path
      }

      # Optionally check if the directory exists
      if(fail_if_does_not_exist) assertthat::assert_that(dir.exists(dir_path))

      return(dir_path)
    },

    #' @description Construct a file path from the config object
    #' 
    #' @details
    #' Looks for the file path under:
    #' `config_list$directories[[dir_name]]$files[[file_name]]`
    #' 
    #' @param dir_name Directory name
    #' @param file_name File name within that directory
    #' @param custom_version (character, default NULL) A custom version that will be
    #'   applied to this folder, rather than pulling from `config_list$versions[[dir]]`.
    #'   Only applies to versioned folders.
    #' @param fail_if_does_not_exist (logical, default FALSE) should this method return an
    #'   error if the directory in question does not already exist?
    #' 
    #' @return The full path to the file
    get_file_path = function(
      dir_name, file_name, custom_version = NULL, fail_if_does_not_exist = FALSE
    ){
      dir_path <- self$get_dir_path(
        dir_name = dir_name,
        custom_version = custom_version,
        fail_if_does_not_exist = fail_if_does_not_exist
      )
      file_stub <- self$get('directories', dir_name, 'files', file_name)
      file_path <- file.path(dir_path, file_stub)
      if(fail_if_does_not_exist) assertthat::assert_that(file.exists(file_path))
      return(file_path)
    },

    #' Read a file based on the config
    #' 
    #' @param dir_name Directory name
    #' @param file_name File name within that directory
    #' @param ... Optional file reading arguments to pass to [autoread()]
    #' @param custom_version (character, default NULL) A custom version that will be
    #'   applied to this folder, rather than pulling from `config_list$versions[[dir]]`.
    #'   Only applies to versioned folders. If passed, this argument must always be
    #'   explicitly named.
    #' 
    #' @return The object loaded by [autoread()]
    read = function(dir_name, file_name, ..., custom_version = NULL){
      # Get the file path
      file_path <- self$get_file_path(
        dir_name = dir_name,
        file_name = file_name,
        custom_version = custom_version,
        fail_if_does_not_exist = TRUE
      )
      # Automatically read it based on the extension
      return(autoread(file_path, ...))
    },

    #' Write an object to file based on the config
    #' 
    #' @param x Object to write
    #' @param dir_name Directory name
    #' @param file_name File name within that directory
    #' @param ... Optional file writing arguments to pass to [autowrite()]
    #' @param custom_version (character, default NULL) A custom version that will be
    #'   applied to this folder, rather than pulling from `config_list$versions[[dir]]`.
    #'   Only applies to versioned folders. If passed, this argument must always be
    #'   explicitly named.
    #' 
    #' @return Invisibly passes TRUE if successful
    write = function(x, dir_name, file_name, ..., custom_version = NULL){
      # Get the file path to write to
      file_path <- self$get_file_path(
        dir_name = dir_name,
        file_name = file_name,
        custom_version = custom_version,
        fail_if_does_not_exist = FALSE
      )
      # Automatically write to file based on extension
      return(autowrite(x = x, file = file_path, ...))
    },

    #' Convenience function: write the config list to a folder as 'config.yaml'
    #' 
    #' @param dir_name Directory name
    #' @param ... Optional file writing arguments to pass to [autowrite()]
    #' @param custom_version (character, default NULL) A custom version that will be
    #'   applied to this folder, rather than pulling from `config_list$versions[[dir]]`.
    #'   Only applies to versioned folders. If passed, this argument must always be
    #'   explicitly named.
    #' 
    #' @return Invisibly passes TRUE if successful
    write_self = function(dir_name, ..., custom_version = NULL){
      # Get the file path to write to
      dir_path <- self$get_dir_path(
        dir_name = dir_name,
        custom_version = custom_version,
        fail_if_does_not_exist = TRUE
      )
      file_path <- file.path(dir_path, 'config.yaml')
      # Automatically write to file based on extension
      return(autowrite(x = self$config_list, file = file_path, ...))
    }
  ),
  private = list()
)
