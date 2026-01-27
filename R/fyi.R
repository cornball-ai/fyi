#' Ensure Package Docs Exist in Cache
#'
#' Generates fyi.md and man-md/ docs for any installed package into a
#' central cache (~/.fyi/<package>/). Use this for all packages to keep
#' documentation in a uniform location.
#'
#' @param package Character. Package name.
#' @param force Logical. Regenerate even if docs exist? Default FALSE.
#' @param pattern Optional regex to filter exports/internals/topics in fyi.md,
#'   and which doc files to generate in man-md/.
#' @param max_exports Maximum exports in fyi.md. Default NULL (all).
#' @param max_internals Maximum internals in fyi.md. Use 0 to skip. Default NULL.
#' @param max_topics Maximum doc topics to list in fyi.md. Default NULL (all).
#' @param internals Include internal functions in fyi.md? Default TRUE.
#' @param docs_pattern Optional separate pattern for man-md/ files
#'   (if different from fyi.md pattern).
#' @param format Output format: "default" (HTML comments) or "hugo" (YAML front matter).
#'
#' @return Path to the package's fyi directory, invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' # Cache all docs for a small package
#' fyi_cache("sttapi")
#'
#' # For large packages, filter to reduce fyi.md size
#' # (man-md/ files still generated for on-demand reading)
#' fyi_cache("torch",
#'           max_exports = 100,
#'           max_internals = 0,
#'           max_topics = 100)
#'
#' # Only cache nn_* modules
#' fyi_cache("torch", pattern = "^nn_")
#'
#' # Filter fyi.md but generate all doc files
#' fyi_cache("torch",
#'           pattern = "^nn_",
#'           docs_pattern = NULL)  # NULL = all docs
#'
#' # Force regeneration
#' fyi_cache("torch", force = TRUE)
#'
#' # Hugo format for static sites
#' fyi_cache("sttapi", format = "hugo")
#' }
fyi_cache <- function(
  package,
  force = FALSE,
  pattern = NULL,
  max_exports = NULL,
  max_internals = NULL,
  max_topics = NULL,
  internals = TRUE,
  docs_pattern = pattern,
  format = "default"
) {
  cache_dir <- file.path(Sys.getenv("HOME"), ".fyi", package)
  fyi_path <- file.path(cache_dir, "fyi.md")
  manmd_dir <- file.path(cache_dir, "man-md")

  # Check if already cached
  if (!force && file.exists(fyi_path) && dir.exists(manmd_dir)) {
    message("Using cached docs: ", cache_dir)
    return(invisible(cache_dir))
  }

  # Create cache directory
  if (!dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE)
  }

  # Generate fyi.md (with filtering)
  use_fyi_md(package, path = fyi_path,
    internals = internals,
    pattern = pattern,
    max_exports = max_exports,
    max_internals = max_internals,
    max_topics = max_topics,
    format = format)

  # Generate man-md/ (possibly with different pattern)
  use_fyi_docs(package, dir = manmd_dir, pattern = docs_pattern, format = format)

  message("Cached docs for '", package, "' in ", cache_dir)
  invisible(cache_dir)
}

#' Get Cache Path for a Package
#'
#' Returns the path where cached docs would be stored for a package.
#'
#' @param package Character. Package name.
#' @return Character path to ~/.fyi/<package>/
#' @export
#'
#' @examples
#' fyi_cache_path("torch")
#' # Returns: "~/.fyi/torch"
fyi_cache_path <- function(package) {
  file.path(Sys.getenv("HOME"), ".fyi", package)
}

#' Create Persistent fyi.md File
#'
#' Generates package information and writes it to a markdown file for
#' persistent LLM context in your project.
#'
#' @param package Character. Package name.
#' @param path File path to write. Default "fyi.md" in current directory.
#' @param src_dir Optional path to source directory for options extraction.
#' @param internals Logical. Include internal functions? Default TRUE.
#' @param options Logical. Include option names? Default TRUE.
#' @param exports Logical. Include exported functions? Default TRUE.
#' @param docs Logical. Include full documentation? Default FALSE.
#'   Consider using use_fyi_docs() instead for individual doc files.
#' @param pattern Optional regex to filter exports/internals/topics.
#' @param max_exports Maximum number of exports to show. Default NULL (all).
#' @param max_internals Maximum number of internals to show. Default NULL (all).
#' @param max_topics Maximum number of doc topics to list. Default NULL (all).
#' @param append Logical. Append to existing file? Default FALSE (overwrite).
#'
#' @return The file path, invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' # Create fyi.md for a package (summary only - recommended)
#' use_fyi_md("sttapi")
#'
#' # Also generate individual doc files for on-demand reading
#' use_fyi_docs("sttapi")
#'
#' # Custom path
#' use_fyi_md("sttapi", path = "docs/sttapi-context.md")
#'
#' # For large packages, filter to reduce size
#' use_fyi_md("torch", pattern = "^nn_", internals = FALSE)
#' use_fyi_md("torch", max_exports = 100, max_internals = 0, max_topics = 100)
#'
#' # Hugo format (YAML front matter)
#' use_fyi_md("sttapi", format = "hugo")
#' }
use_fyi_md <- function(
  package,
  path = "fyi.md",
  src_dir = NULL,
  internals = TRUE,
  options = TRUE,
  exports = TRUE,
  docs = FALSE,
  pattern = NULL,
  max_exports = NULL,
  max_internals = NULL,
  max_topics = NULL,
  append = FALSE,
  format = "default"
) {
  # Generate content (suppress console output)
  content <- capture.output(
    fyi(package, src_dir = src_dir, internals = internals,
      options = options, exports = exports, docs = docs,
      pattern = pattern, max_exports = max_exports,
      max_internals = max_internals, max_topics = max_topics)
  )
  content <- paste(content, collapse = "\n")

  # Remove the first line (# fyi: package) for hugo format
  # since title is in front matter
  if (format == "hugo") {
    content_lines <- strsplit(content, "\n")[[1]]
    if (length(content_lines) > 0 && grepl("^# fyi:", content_lines[1])) {
      content <- paste(content_lines[-1], collapse = "\n")
      content <- sub("^\n+", "", content)
    }
  }

  # Add metadata header based on format
  if (format == "hugo") {
    header <- paste0(
      "---\n",
      "title: \"", package, "\"\n",
      "description: \"R package reference for ", package, "\"\n",
      "---\n\n",
      "*Last updated: ", Sys.Date(), "*\n\n"
    )
  } else {
    header <- paste0(
      "<!-- Generated by fyi::use_fyi_md() on ", Sys.Date(), " -->\n",
      "<!-- Regenerate with: fyi::use_fyi_md(\"", package, "\") -->\n\n"
    )
  }

  full_content <- paste0(header, content)

  # Write to file
  if (append && file.exists(path)) {
    existing <- paste(readLines(path, warn = FALSE), collapse = "\n")
    full_content <- paste0(existing, "\n\n---\n\n", full_content)
  }

  writeLines(full_content, path)
  message("Wrote ", path)

  invisible(path)
}

#' Generate Individual Documentation Files
#'
#' Creates a directory of individual markdown files, one per help topic.
#' LLMs can read these on-demand when they need details about specific functions.
#'
#' @param package Character. Package name.
#' @param dir Directory to write files. Default "man-md" in current directory.
#' @param pattern Optional regex to filter which topics to include.
#' @param topics Optional character vector of specific topics to include.
#' @param exclude Optional regex pattern to exclude topics.
#' @param exports_only Logical. Only include docs for exported functions? Default FALSE.
#' @param clean Logical. Remove existing files in dir first? Default TRUE.
#' @param format Output format: "default" (HTML comments) or "hugo" (YAML front matter).
#'
#' @return Character vector of generated file paths, invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' # Generate all doc files
#' use_fyi_docs("sttapi")
#'
#' # Filter to specific patterns (torch example)
#' use_fyi_docs("torch", pattern = "^nn_")      # Neural network modules
#' use_fyi_docs("torch", pattern = "^optim_")   # Optimizers
#' use_fyi_docs("torch", pattern = "^torch_")   # Tensor operations
#'
#' # Specific topics only
#' use_fyi_docs("torch", topics = c("nn_linear", "nn_conv2d", "nn_module"))
#'
#' # Exclude patterns
#' use_fyi_docs("torch", exclude = "^nnf_")     # Skip functional variants
#'
#' # Only exported functions (skip internal helper docs)
#' use_fyi_docs("torch", exports_only = TRUE)
#'
#' # Hugo format for static sites
#' use_fyi_docs("sttapi", format = "hugo")
#' }
use_fyi_docs <- function(
  package,
  dir = "man-md",
  pattern = NULL,
  topics = NULL,
  exclude = NULL,
  exports_only = FALSE,
  clean = TRUE,
  format = "default"
) {
  db <- tools::Rd_db(package)

  if (length(db) == 0) {
    message("No documentation found for package '", package, "'.")
    return(invisible(character()))
  }

  # Get topic names
  topic_names <- sub("\\.Rd$", "", names(db))

  # Filter by pattern

  if (!is.null(pattern)) {
    keep <- grep(pattern, topic_names)
    db <- db[keep]
    topic_names <- topic_names[keep]
  }

  # Filter by specific topics
  if (!is.null(topics)) {
    keep <- topic_names %in% topics
    db <- db[keep]
    topic_names <- topic_names[keep]
  }

  # Exclude pattern
  if (!is.null(exclude)) {
    keep <- !grepl(exclude, topic_names)
    db <- db[keep]
    topic_names <- topic_names[keep]
  }

  # Filter to exports only
  if (exports_only) {
    exports <- tryCatch(
      getNamespaceExports(getNamespace(package)),
      error = function(e) character()
    )
    keep <- topic_names %in% exports
    db <- db[keep]
    topic_names <- topic_names[keep]
  }

  if (length(db) == 0) {
    message("No topics matched filters for package '", package, "'.")
    return(invisible(character()))
  }

  # Create directory
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  } else if (clean) {
    # Remove existing .md files
    existing <- list.files(dir, pattern = "\\.md$", full.names = TRUE)
    if (length(existing) > 0) {
      file.remove(existing)
    }
  }

  generated <- character()

  for (i in seq_along(db)) {
    topic_name <- topic_names[i]
    rd <- db[[i]]

    # Convert to markdown
    md_content <- rd2md(rd)

    # Add header based on format
    if (format == "hugo") {
      # Extract title from first line of content (usually # Title)
      content_lines <- strsplit(md_content, "\n")[[1]]
      title <- topic_name
      if (length(content_lines) > 0 && grepl("^# ", content_lines[1])) {
        title <- sub("^# ", "", content_lines[1])
        md_content <- paste(content_lines[-1], collapse = "\n")
        md_content <- sub("^\n+", "", md_content)
      }
      header <- paste0(
        "---\n",
        "title: \"", title, "\"\n",
        "description: \"", package, "::", topic_name, "\"\n",
        "---\n\n"
      )
    } else {
      header <- paste0(
        "<!-- ", package, "::", topic_name, " -->\n",
        "<!-- Generated by fyi::use_fyi_docs() -->\n\n"
      )
    }

    # Write file
    filepath <- file.path(dir, paste0(topic_name, ".md"))
    writeLines(paste0(header, md_content), filepath)
    generated <- c(generated, filepath)
  }

  message("Wrote ", length(generated), " files to ", dir, "/")
  invisible(generated)
}

#' Generate Hugo Documentation Site for a Package
#'
#' Creates a pkgdown-style documentation structure for Hugo static sites.
#' Generates package overview from README, function reference pages, and
#' a reference index.
#'
#' @param package Character. Package name.
#' @param dir Directory to write docs. Creates `<dir>/_index.md` and `<dir>/reference/`.
#' @param src_dir Optional path to package source directory (for README).
#'   If NULL, looks in `~/<package>/`.
#' @param pattern Optional regex to filter which functions to document.
#' @param exports_only Logical. Only document exported functions? Default TRUE.
#' @param clean Logical. Remove existing files first? Default TRUE.
#'
#' @return Path to the generated directory, invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' # Generate docs for whisper package
#' use_fyi_hugo("whisper", "content/docs/whisper")
#'
#' # Generate docs for package in custom location
#' use_fyi_hugo("mypackage", "site/docs/mypackage", src_dir = "~/projects/mypackage")
#'
#' # Only include specific functions
#' use_fyi_hugo("torch", "content/docs/torch", pattern = "^nn_")
#' }
use_fyi_hugo <- function(
  package,
  dir,
  src_dir = NULL,
  pattern = NULL,
  exports_only = TRUE,
  clean = TRUE
) {
  # Find source directory for README

if (is.null(src_dir)) {
    src_dir <- file.path(Sys.getenv("HOME"), package)
  }

  # Create directories
  ref_dir <- file.path(dir, "reference")
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }
  if (!dir.exists(ref_dir)) {
    dir.create(ref_dir, recursive = TRUE)
  }

  # 1. Generate package overview from README
  readme_path <- file.path(src_dir, "README.md")
  index_path <- file.path(dir, "_index.md")

  if (file.exists(readme_path)) {
    readme <- readLines(readme_path, warn = FALSE)

    # Extract title from first H1
    title_line <- grep("^# ", readme, value = TRUE)[1]
    title <- if (!is.na(title_line)) sub("^# ", "", title_line) else package

    # Remove the first H1 line (title will be in front matter)
    first_h1 <- which(grepl("^# ", readme))[1]
    if (!is.na(first_h1)) {
      readme <- readme[-first_h1]
    }

    # Get description from DESCRIPTION file
    desc_file <- file.path(src_dir, "DESCRIPTION")
    if (file.exists(desc_file)) {
      desc <- read.dcf(desc_file)
      description <- desc[1, "Title"]
    } else {
      description <- title
    }

    # Build Hugo content
    front_matter <- c(
      "---",
      paste0("title: \"", title, "\""),
      paste0("description: \"", description, "\""),
      "---",
      "",
      paste0("*Last updated: ", Sys.Date(), "*"),
      ""
    )

    # Add reference link at end
    readme <- c(readme, "", "## Reference", "",
                paste0("See [Function Reference](reference/) for complete API documentation."))

    content <- c(front_matter, readme)
    writeLines(content, index_path)
    message("Wrote ", index_path)
  } else {
    # No README - create minimal index
    desc_file <- file.path(src_dir, "DESCRIPTION")
    if (file.exists(desc_file)) {
      desc <- read.dcf(desc_file)
      title <- package
      description <- desc[1, "Title"]
    } else {
      title <- package
      description <- paste("Documentation for", package)
    }

    content <- c(
      "---",
      paste0("title: \"", title, "\""),
      paste0("description: \"", description, "\""),
      "---",
      "",
      paste0("*Last updated: ", Sys.Date(), "*"),
      "",
      description,
      "",
      "## Reference",
      "",
      "See [Function Reference](reference/) for complete API documentation."
    )
    writeLines(content, index_path)
    message("Wrote ", index_path, " (no README found)")
  }

  # 2. Generate reference docs
  use_fyi_docs(package, dir = ref_dir, pattern = pattern,
               exports_only = exports_only, clean = clean, format = "hugo")

  # 3. Generate reference index (Hugo template lists child pages automatically)
  ref_index_path <- file.path(ref_dir, "_index.md")

  lines <- c(
    "---",
    paste0("title: \"", package, " Reference\""),
    paste0("description: \"Function reference for ", package, "\""),
    "---"
  )

  writeLines(lines, ref_index_path)
  message("Wrote ", ref_index_path)

  invisible(dir)
}

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
#' @param pattern Optional regex to filter exports/internals/topics.
#' @param max_exports Maximum number of exports to show. Default NULL (all).
#' @param max_internals Maximum number of internals to show. Default NULL (all).
#' @param max_topics Maximum number of doc topics to list. Default NULL (all).
#'
#' @return Character string of markdown, invisibly. Also prints to console.
#' @export
#'
#' @examples
#' \dontrun{
#' fyi("sttapi")
#' fyi("llamaR", internals = TRUE, options = FALSE)
#' fyi("sttapi", docs = TRUE)  # Include full help docs
#'
#' # For large packages like torch, filter to reduce size
#' fyi("torch", pattern = "^nn_", internals = FALSE)
#' fyi("torch", max_exports = 50, max_internals = 0, max_topics = 50)
#' }
fyi <- function(
  package,
  src_dir = NULL,
  internals = TRUE,
  options = TRUE,
  exports = TRUE,
  docs = FALSE,
  pattern = NULL,
  max_exports = NULL,
  max_internals = NULL,
  max_topics = NULL
) {
  sections <- character()

  # Header
  sections <- c(sections, paste0("# fyi: ", package, "\n"))

  # Exports
  if (exports) {
    exp_df <- fyi_exports(package, pattern = pattern)
    if (!is.null(max_exports) && nrow(exp_df) > max_exports) {
      total <- nrow(exp_df)
      exp_df <- exp_df[seq_len(max_exports),, drop = FALSE]
      attr(exp_df, "truncated") <- total
    }
    sections <- c(sections, .format_exports_md(exp_df, package), "\n")
  }

  # Internals
  if (internals) {
    # max_internals = 0 means skip entirely
    if (!is.null(max_internals) && max_internals == 0) {
      sections <- c(sections, paste0("## Internal Functions (", package, ":::)\n\n_Skipped (use internals=TRUE to include)_\n"), "\n")
    } else {
      int_df <- fyi_internals(package, pattern = pattern)
      if (!is.null(max_internals) && nrow(int_df) > max_internals) {
        total <- nrow(int_df)
        int_df <- int_df[seq_len(max_internals),, drop = FALSE]
        attr(int_df, "truncated") <- total
      }
      sections <- c(sections, .format_internals_md(int_df, package), "\n")
    }
  }

  # Options
  if (options) {
    opt_df <- fyi_options(package, src_dir = src_dir)
    sections <- c(sections, .format_options_md(opt_df, package), "\n")
  }

  # Documentation
  if (docs) {
    docs_output <- capture.output(fyi_docs(package, pattern = pattern))
    sections <- c(sections, paste(docs_output, collapse = "\n"), "\n")
  } else {
    # Just show topic list
    sections <- c(sections, .format_docs_summary_md(package, pattern = pattern,
        max_topics = max_topics), "\n")
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
fyi_exports <- function(
  package,
  pattern = NULL
) {
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
.format_exports_md <- function(
  df,
  package
) {
  if (nrow(df) == 0) {
    return(paste0("## Exported Functions\n\nNo exported functions found in `", package, "`.\n"))
  }

  truncated <- attr(df, "truncated")
  header <- if (!is.null(truncated)) {
    paste0("## Exported Functions (", package, "::) [showing ", nrow(df), " of ", truncated, "]\n")
  } else {
    paste0("## Exported Functions (", package, "::)\n")
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

