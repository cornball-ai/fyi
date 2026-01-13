#' List Help Topics for a Package
#'
#' Returns all documented topics (help pages) in a package.
#'
#' @param package Character. Package name.
#'
#' @return A character vector of help topic names.
#' @export
#'
#' @examples
#' \dontrun{
#' fyi_help_topics("sttapi")
#' }
fyi_help_topics <- function(package) {
  # Get the package's help index
  db <- tools::Rd_db(package)
  if (length(db) == 0) {
    return(character())
  }

  # Extract topic names from Rd files
  topics <- sub("\\.Rd$", "", names(db))
  sort(unique(topics))
}

#' Get Help Documentation for a Topic
#'
#' Extracts help documentation as markdown, suitable for LLM consumption.
#'
#' @param topic Character. The topic to get help for.
#' @param package Character. Package name.
#' @param format Output format: "markdown" (default, clean) or "text" (Rd2txt).
#'
#' @return Character string of help text, invisibly. Also prints to console.
#' @export
#'
#' @examples
#' \dontrun{
#' fyi_help("transcribe", "sttapi")
#' fyi_help("transcribe", "sttapi", format = "text")
#' }
fyi_help <- function(topic, package, format = c("markdown", "text")) {
  format <- match.arg(format)

  # Get the Rd database
  db <- tools::Rd_db(package)

  # Find matching Rd file
  rd_name <- paste0(topic, ".Rd")
  if (!rd_name %in% names(db)) {
    # Try to find alias
    for (nm in names(db)) {
      rd <- db[[nm]]
      aliases <- .get_rd_aliases(rd)
      if (topic %in% aliases) {
        rd_name <- nm
        break
      }
    }
  }

  if (!rd_name %in% names(db)) {
    stop("Topic '", topic, "' not found in package '", package, "'.", call. = FALSE)
  }

  rd <- db[[rd_name]]

  # Convert Rd to output format
  if (format == "markdown") {
    result <- rd2md(rd)
  } else {
    txt <- capture.output(tools::Rd2txt(rd, outputEncoding = "UTF-8"))
    result <- paste(txt, collapse = "\n")
  }

  cat(result, "\n")
  invisible(result)
}

#' Get All Help Documentation for a Package
#'
#' Extracts all help documentation as markdown, suitable for LLM consumption.
#'
#' @param package Character. Package name.
#' @param topics Optional character vector of specific topics to include.
#' @param pattern Optional regex to filter topics by name.
#' @param format Output format: "markdown" (default, clean) or "text" (Rd2txt).
#'
#' @return Character string of markdown, invisibly. Also prints to console.
#' @export
#'
#' @examples
#' \dontrun{
#' fyi_docs("sttapi")
#' fyi_docs("sttapi", topics = c("transcribe", "set_stt_base"))
#' fyi_docs("torch", pattern = "^nn_")
#' fyi_docs("sttapi", format = "text")
#' }
fyi_docs <- function(package, topics = NULL, pattern = NULL,
                     format = c("markdown", "text")) {
  format <- match.arg(format)
  db <- tools::Rd_db(package)

  if (length(db) == 0) {
    msg <- paste0("No documentation found for package '", package, "'.\n")
    cat(msg)
    return(invisible(msg))
  }

  # Filter by pattern first
  if (!is.null(pattern)) {
    topic_names <- sub("\\.Rd$", "", names(db))
    keep <- grep(pattern, topic_names)
    db <- db[keep]
  }

  # Filter to specific topics if requested
  if (!is.null(topics)) {
    # Find Rd files matching topics (by name or alias)
    keep <- character()
    for (topic in topics) {
      rd_name <- paste0(topic, ".Rd")
      if (rd_name %in% names(db)) {
        keep <- c(keep, rd_name)
      } else {
        # Check aliases
        for (nm in names(db)) {
          rd <- db[[nm]]
          aliases <- .get_rd_aliases(rd)
          if (topic %in% aliases) {
            keep <- c(keep, nm)
            break
          }
        }
      }
    }
    db <- db[unique(keep)]
  }

  sections <- character()
  sections <- c(sections, paste0("# Documentation: ", package, "\n"))

  for (nm in sort(names(db))) {
    topic_name <- sub("\\.Rd$", "", nm)
    rd <- db[[nm]]

    if (format == "markdown") {
      # Clean markdown output
      sections <- c(sections, paste0("## ", topic_name), "")
      sections <- c(sections, rd2md(rd), "")
    } else {
      # Legacy Rd2txt output
      title <- .get_rd_title(rd)
      sections <- c(sections, paste0("## ", topic_name, "\n"))
      if (!is.null(title) && title != topic_name) {
        sections <- c(sections, paste0("*", title, "*\n"))
      }
      txt <- capture.output(tools::Rd2txt(rd, outputEncoding = "UTF-8"))
      sections <- c(sections, "```")
      sections <- c(sections, txt)
      sections <- c(sections, "```\n")
    }
  }

  result <- paste(sections, collapse = "\n")
  cat(result)
  invisible(result)
}

#' Get Aliases from Rd Object
#' @keywords internal
.get_rd_aliases <- function(rd) {
  aliases <- character()
  for (tag in rd) {
    if (attr(tag, "Rd_tag") == "\\alias") {
      aliases <- c(aliases, as.character(tag))
    }
  }
  trimws(aliases)
}

#' Get Title from Rd Object
#' @keywords internal
.get_rd_title <- function(rd) {
  for (tag in rd) {
    if (attr(tag, "Rd_tag") == "\\title") {
      return(trimws(paste(unlist(tag), collapse = "")))
    }
  }
  NULL
}

#' Format Docs Summary as Markdown
#'
#' Creates a compact summary of package documentation.
#'
#' @param package Character. Package name.
#' @param pattern Optional regex to filter topics.
#' @param max_topics Maximum number of topics to show. Default NULL (all).
#' @return Character string of markdown
#' @keywords internal
.format_docs_summary_md <- function(package, pattern = NULL, max_topics = NULL) {
  topics <- fyi_help_topics(package)

  if (length(topics) == 0) {
    return(paste0("## Documentation\n\nNo documentation found for `", package, "`.\n"))
  }

  # Filter by pattern
  if (!is.null(pattern)) {
    topics <- grep(pattern, topics, value = TRUE)
  }

  total <- length(topics)

  # Truncate if needed
  if (!is.null(max_topics) && length(topics) > max_topics) {
    topics <- topics[seq_len(max_topics)]
    header <- paste0("## Documentation Topics [showing ", max_topics, " of ", total, "]\n")
  } else {
    header <- paste0("## Documentation Topics (", length(topics), ")\n")
  }

  lines <- c(
    header,
    "For details, read `man-md/<topic>.md` or use `fyi_help(\"topic\", \"pkg\")`.\n",
    paste0("Topics: ", paste(paste0("`", topics, "`"), collapse = ", "))
  )

  paste(lines, collapse = "\n")
}
