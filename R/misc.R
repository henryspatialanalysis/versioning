## Helper functions

#' Stop without listing the containing function call
#'
#' @param ... Parameters passed to `stop()`
#'
#' @return Concisely stops program execution
qstop <- function(...) stop(..., call. = FALSE)

#' Require that a namespace be loaded, or stop execution
#'
#' @param pkg (`character(1)`) Package to be loaded
#'
#' @return Silently loads namespace, or stops execution if package cannot be loaded
require_namespace_or_stop <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)){
    paste('Package', pkg, 'is required.') |> qstop()
  }
}
