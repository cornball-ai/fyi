#' Get Complete Package Information for LLMs
#'
#' The main function - returns everything an LLM needs to understand a package,
#' including exports, internals, options, and optionally full documentation.
#'
#' @param package Character. Package name.
#' @param src_dir Optional path to source directory for options extraction.
#' @param internals Logical. Include internal functions? Default TRUE.
#' @param options Logical. Include option names? Default TRUE.
#' @param exports Logical. Include exported functions? Default TRUE.
#' @param docs Logical. Include full documentation? Default FALSE (can be verbose).
#'
#' @return Character string of markdown, invisibly. Also prints to console.
#' @export
#'
#' @examples
#' \dontrun{
#' fyi("sttapi")
#' fyi("llamaR", internals = TRUE, options = FALSE)
#' fyi("sttapi", docs = TRUE)  # Include full help docs
#' }
fyi <- function(package, src_dir = NULL, internals = TRUE, options = TRUE,
                exports = TRUE, docs = FALSE) {
  sections <- character()

  # Header
  sections <- c(sections, paste0("# fyi: ", package, "\n"))

  # Exports
  if (exports) {
    exp_df <- fyi_exports(package)
    sections <- c(sections, .format_exports_md(exp_df, package), "\n")
  }

  # Internals
  if (internals) {
    int_df <- fyi_internals(package)
    sections <- c(sections, .format_internals_md(int_df, package), "\n")
  }

  # Options
  if (options) {
    opt_df <- fyi_options(package, src_dir = src_dir)
    sections <- c(sections, .format_options_md(opt_df, package), "\n")
  }

  # Documentation
  if (docs) {
    docs_output <- capture.output(fyi_docs(package))
    sections <- c(sections, paste(docs_output, collapse = "\n"), "\n")
  } else {
    # Just show topic list
    sections <- c(sections, .format_docs_summary_md(package), "\n")
  }

  result <- paste(sections, collapse = "\n")
  cat(result)
  invisible(result)
}

#' List Exported Functions
#'
#' Returns functions exported by a package.
#'
#' @param package Character. Package name.
#' @param pattern Optional regex to filter function names.
#'
#' @return A data.frame with columns: name, args.
#' @export
#'
#' @examples
#' \dontrun{
#' fyi_exports("sttapi")
#' }
fyi_exports <- function(package, pattern = NULL) {
  ns <- tryCatch(
    getNamespace(package),
    error = function(e) {
      stop("Package '", package, "' not found. Is it installed?", call. = FALSE)
    }
  )

  exports <- getNamespaceExports(ns)

  # Filter to functions only
  export_fns <- Filter(function(nm) {
    obj <- tryCatch(get(nm, envir = ns), error = function(e) NULL)
    is.function(obj)
  }, exports)

  if (!is.null(pattern)) {
    export_fns <- grep(pattern, export_fns, value = TRUE)
  }

  if (length(export_fns) == 0) {
    return(data.frame(
      name = character(),
      args = character(),
      stringsAsFactors = FALSE
    ))
  }

  args_list <- vapply(export_fns, function(nm) {
    fn <- get(nm, envir = ns)
    paste(names(formals(fn)), collapse = ", ")
  }, character(1))

  data.frame(
    name = sort(export_fns),
    args = args_list[order(export_fns)],
    stringsAsFactors = FALSE,
    row.names = NULL
  )
}

#' Format Exports as Markdown
#'
#' @param df Data.frame from fyi_exports()
#' @param package Package name for header
#' @return Character string of markdown
#' @keywords internal
.format_exports_md <- function(df, package) {
  if (nrow(df) == 0) {
    return(paste0("## Exported Functions\n\nNo exported functions found in `", package, "`.\n"))
  }

  lines <- c(
    paste0("## Exported Functions (", package, "::)\n"),
    "| Function | Arguments |",
    "|----------|-----------|"
  )

  for (i in seq_len(nrow(df))) {
    lines <- c(lines, paste0("| `", df$name[i], "` | ", df$args[i], " |"))
  }

  paste(lines, collapse = "\n")
}
