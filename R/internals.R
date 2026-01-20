#' List Internal (Non-Exported) Functions
#'
#' Returns functions defined in a package namespace but not exported.
#'
#' @param package Character. Package name.
#' @param pattern Optional regex to filter function names.
#'
#' @return A data.frame with columns: name, args, internal (all TRUE).
#' @export
#'
#' @examples
#' \dontrun{
#' fyi_internals("sttapi")
#' fyi_internals("sttapi", pattern = "^\\.")
#' }
fyi_internals <- function(
  package,
  pattern = NULL
) {
  # Get namespace

  ns <- tryCatch(
    getNamespace(package),
    error = function(e) {
      stop("Package '", package, "' not found. Is it installed?", call. = FALSE)
    }
  )

  # Get exported names
  exports <- getNamespaceExports(ns)

  # Get all names in namespace
  all_names <- ls(ns, all.names = TRUE)

  # Internal = in namespace but not exported
  internal_names <- setdiff(all_names, exports)

  # Filter to functions only
  internal_fns <- Filter(function(nm) {
      obj <- get(nm, envir = ns)
      is.function(obj)
    }, internal_names)

  # Apply pattern filter if provided
  if (!is.null(pattern)) {
    internal_fns <- grep(pattern, internal_fns, value = TRUE)
  }

  # Build result
  if (length(internal_fns) == 0) {
    return(data.frame(
        name = character(),
        args = character(),
        stringsAsFactors = FALSE
      ))
  }

  # Get args for each function
  args_list <- vapply(internal_fns, function(nm) {
      fn <- get(nm, envir = ns)
      paste(names(formals(fn)), collapse = ", ")
    }, character(1))

  data.frame(
    name = internal_fns,
    args = args_list,
    stringsAsFactors = FALSE,
    row.names = NULL
  )
}

#' Format Internals as Markdown
#'
#' @param df Data.frame from fyi_internals()
#' @param package Package name for header
#' @return Character string of markdown
#' @keywords internal
.format_internals_md <- function(
  df,
  package
) {
  if (nrow(df) == 0) {
    return(paste0("## Internal Functions\n\nNo internal functions found in `", package, "`.\n"))
  }

  truncated <- attr(df, "truncated")
  header <- if (!is.null(truncated)) {
    paste0("## Internal Functions (", package, ":::) [showing ", nrow(df), " of ", truncated, "]\n")
  } else {
    paste0("## Internal Functions (", package, ":::)\n")
  }

  lines <- c(
    header,
    "| Function | Arguments |",
    "|----------|-----------|"
  )

  for (i in seq_len(nrow(df))) {
    lines <- c(lines, paste0("| `", df$name[i], "` | ", df$args[i], " |"))
  }

  paste(lines, collapse = "\n")
}

