#' Safely pull an item from a list
#' 
#' @description Indexing function for a list
#' 
#' @details Use the `...` arguments to index the list. Not passing any `...` arguments
#'   will return the entire list. The indexing will fail if either of two conditions are
#'   met:
#'   1. The index (which can be numeric or a key) does not exist in the list
#'   2. If the index exists but the value of the item is NULL, and `fail_if_null` is TRUE
#' 
#' @param x List to pull items from
#' @param ... List indices to pull. Can be either numeric or (preferably) a character.
#' @param fail_if_null (logical, default TRUE). Returns an informative error message if
#'   the list index is NULL. This function must always be named.
#' 
#' @importFrom assertthat assert_that
#' @importFrom glue glue
#' @export
pull_from_list <- function(x, ..., fail_if_null = TRUE){
  indices <- list(...)
  # Get original name of `x` for more informative error messages
  list_name <- deparse(substitute(x))
  
  # Iteratively subset list using indices
  working_list <- x
  for(index_i in seq_along(indices)){
    index <- indices[[index_i]]
    # Check that the subset will work
    issue_prefix <- glue::glue("Issue with subset #{index_i} for list '{list_name}':")
    assertthat::assert_that(
      length(index) == 1,
      msg = paste(issue_prefix, 'All list indices should have length 1.')
    )
    assertthat::assert_that(
      is.character(index) | is.integer(index),
      msg = paste(issue_prefix, "Indices should be either characters or integers.")
    )
    if(is.character(index)){
      assertthat::assert_that(
        index %in% names(working_list),
        msg = glue::glue("{issue_prefix} '{index}' is not a name in the sub-list.")
      )
    }
    if(is.integer(index)){
      assertthat::assert_that(
        length(working_list) <= index,
        msg = glue::glue(
          "{issue_prefix} numeric index {index} greater than the length of sub-list."
        )
      )
    }

    # Get the subset
    working_list <- working_list[[index]]

    # Optionally check that the subset is not NULL
    if(fail_if_null){
      assertthat::assert_that(
        !is.null(working_list),
        msg = paste(issue_prefix, 'Sub-list is NULL.')
      )
    }
  }
  return(working_list)
}
