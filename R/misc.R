## Helper functions

#' Stop without listing the containing function call
qstop <- function(...) stop(..., call. = FALSE)

#' Require that a namespace be loaded, or stop execution
require_namespace_or_stop <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)){
    paste('Package', pkg, 'is required.') |> qstop()
  }
}
