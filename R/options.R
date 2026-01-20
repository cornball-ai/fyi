#' Extract Option Names from Package Source
#'
#' Scans R source files for getOption() and options() calls to find
#' option names used by a package.
#'
#' @param package Character. Package name (must be installed).
#' @param src_dir Optional. Path to source directory. If NULL, uses
#'   installed package location.
#'
#' @return A data.frame with columns: option, file, type (get/set).
#' @export
#'
#' @examples
#' \dontrun{
#' fyi_options("sttapi")
#' fyi_options("sttapi", src_dir = "~/sttapi")
#' }
fyi_options <- function(
  package,
  src_dir = NULL
) {
  # Find R source files
  if (is.null(src_dir)) {
    pkg_path <- find.package(package, quiet = TRUE)
    if (length(pkg_path) == 0) {
      stop("Package '", package, "' not found.", call. = FALSE)
    }
    r_dir <- file.path(pkg_path, "R")
    # Installed packages have .rdb files, need to look elsewhere
    # Try to find source in common locations
    src_candidates <- c(
      file.path("~", package, "R"),
      file.path("~/cornyverse", package, "R"),
      r_dir
    )
    r_dir <- NULL
    for (candidate in src_candidates) {
      if (dir.exists(candidate) && length(list.files(candidate, pattern = "\\.R$")) > 0) {
        r_dir <- candidate
        break
      }
    }
    if (is.null(r_dir)) {
      return(data.frame(
          option = character(),
          file = character(),
          type = character(),
          stringsAsFactors = FALSE
        ))
    }
  } else {
    r_dir <- file.path(src_dir, "R")
    if (!dir.exists(r_dir)) {
      r_dir <- src_dir
    }
  }

  r_files <- list.files(r_dir, pattern = "\\.R$", full.names = TRUE)

  results <- list()

  for (r_file in r_files) {
    lines <- readLines(r_file, warn = FALSE)
    text <- paste(lines, collapse = "\n")

    # Find getOption("name") patterns
    get_matches <- gregexpr('getOption\\s*\\(\\s*["\']([^"\']+)["\']', text, perl = TRUE)
    if (get_matches[[1]][1] != - 1) {
      captures <- regmatches(text, get_matches) [[1]]
      opts <- sub('getOption\\s*\\(\\s*["\']([^"\']+)["\'].*', '\\1', captures)
      for (opt in opts) {
        results[[length(results) + 1]] <- list(
          option = opt,
          file = basename(r_file),
          type = "get"
        )
      }
    }

    # Find options(name = ...) patterns
    set_matches <- gregexpr('options\\s*\\(\\s*([a-zA-Z_.][a-zA-Z0-9_.]*)', text, perl = TRUE)
    if (set_matches[[1]][1] != - 1) {
      captures <- regmatches(text, set_matches) [[1]]
      opts <- sub('options\\s*\\(\\s*([a-zA-Z_.][a-zA-Z0-9_.]+).*', '\\1', captures)
      for (opt in opts) {
        # Skip if it's just "options(op" or similar
        if (nchar(opt) > 2 && !opt %in% c("op", "old", "opts")) {
          results[[length(results) + 1]] <- list(
            option = opt,
            file = basename(r_file),
            type = "set"
          )
        }
      }
    }
  }

  if (length(results) == 0) {
    return(data.frame(
        option = character(),
        file = character(),
        type = character(),
        stringsAsFactors = FALSE
      ))
  }

  df <- do.call(rbind, lapply(results, as.data.frame, stringsAsFactors = FALSE))

  # Deduplicate
  df <- unique(df)

  # Sort by option name

  df[order(df$option),]
}

#' Format Options as Markdown
#'
#' @param df Data.frame from fyi_options()
#' @param package Package name for header
#' @return Character string of markdown
#' @keywords internal
.format_options_md <- function(
  df,
  package
) {
  if (nrow(df) == 0) {
    return(paste0("## Options\n\nNo options found in `", package, "`.\n"))
  }

  lines <- c(
    paste0("## Options (", package, ")\n"),
    "| Option | File | Type |",
    "|--------|------|------|"
  )

  for (i in seq_len(nrow(df))) {
    lines <- c(lines, paste0("| `", df$option[i], "` | ", df$file[i], " | ", df$type[i], " |"))
  }

  paste(lines, collapse = "\n")
}

