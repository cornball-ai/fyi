#' Convert Rd Object to Markdown
#'
#' Pure R conversion of parsed Rd objects to clean markdown,
#' without the ugly ASCII formatting of Rd2txt.
#'
#' @param rd A parsed Rd object (from tools::Rd_db or tools::parse_Rd).
#' @return Character string of markdown.
#' @keywords internal
rd2md <- function(rd) {
  sections <- list()

  for (element in rd) {
    tag <- attr(element, "Rd_tag")
    if (is.null(tag)) next

    content <- .rd_element_to_text(element)

    switch(tag,
      "\\title" = {
        sections$title <- trimws(content)
      },
      "\\description" = {
        sections$description <- .rd_content_to_md(element)
      },
      "\\usage" = {
        sections$usage <- .rd_verbatim(element)
      },
      "\\arguments" = {
        sections$arguments <- .rd_arguments_to_md(element)
      },
      "\\value" = {
        sections$value <- .rd_content_to_md(element)
      },
      "\\details" = {
        sections$details <- .rd_content_to_md(element)
      },
      "\\examples" = {
        sections$examples <- .rd_verbatim(element)
      },
      "\\seealso" = {
        sections$seealso <- .rd_content_to_md(element)
      },
      "\\references" = {
        sections$references <- .rd_content_to_md(element)
      },
      "\\author" = {
        sections$author <- .rd_content_to_md(element)
      },
      "\\note" = {
        sections$note <- .rd_content_to_md(element)
      },
      "\\section" = {
        # Custom sections: first child is title, rest is content
        sec_title <- .rd_element_to_text(element[[1]])
        sec_content <- .rd_content_to_md(element[- 1])
        if (is.null(sections$custom_sections)) {
          sections$custom_sections <- list()
        }
        sections$custom_sections <- c(sections$custom_sections,
          list(list(title = sec_title, content = sec_content)))
      }
    )
  }

  # Build markdown output
  lines <- character()

  if (!is.null(sections$title)) {
    lines <- c(lines, paste0("### ", sections$title), "")
  }

  if (!is.null(sections$description)) {
    lines <- c(lines, "#### Description", "", sections$description, "")
  }

  if (!is.null(sections$usage)) {
    lines <- c(lines, "#### Usage", "", "```r", sections$usage, "```", "")
  }

  if (!is.null(sections$arguments)) {
    lines <- c(lines, "#### Arguments", "", sections$arguments, "")
  }

  if (!is.null(sections$details)) {
    lines <- c(lines, "#### Details", "", sections$details, "")
  }

  if (!is.null(sections$value)) {
    lines <- c(lines, "#### Value", "", sections$value, "")
  }

  # Custom sections
  if (!is.null(sections$custom_sections)) {
    for (sec in sections$custom_sections) {
      lines <- c(lines, paste0("#### ", sec$title), "", sec$content, "")
    }
  }

  if (!is.null(sections$note)) {
    lines <- c(lines, "#### Note", "", sections$note, "")
  }

  if (!is.null(sections$seealso)) {
    lines <- c(lines, "#### See Also", "", sections$seealso, "")
  }

  if (!is.null(sections$references)) {
    lines <- c(lines, "#### References", "", sections$references, "")
  }

  if (!is.null(sections$author)) {
    lines <- c(lines, "#### Author", "", sections$author, "")
  }

  if (!is.null(sections$examples)) {
    lines <- c(lines, "#### Examples", "", "```r", sections$examples, "```", "")
  }

  paste(lines, collapse = "\n")
}

#' Extract Plain Text from Rd Element
#' @keywords internal
.rd_element_to_text <- function(element) {
  if (is.character(element)) {
    return(element)
  }
  paste(unlist(lapply(element, .rd_element_to_text)), collapse = "")
}

#' Post-process Text with Embedded Rd Markup
#'
#' Handles Rd markup that appears as raw text (common in value, details sections).
#' @keywords internal
.postprocess_rd_text <- function(text) {
  # Convert \describe{} blocks to markdown lists
  # Match \describe{ ... }
  text <- gsub("\\\\describe\\{\\s*\n?", "", text)

  # Convert \item{name}{desc} to markdown list items (strip leading whitespace)
  text <- gsub("\\s*\\\\item\\{([^}]+)\\}\\{([^}]+)\\}", "\n- **\\1**: \\2", text)

  # Handle closing brace of describe (standalone } on a line)
  text <- gsub("\n\\s*\\}\n", "\n", text)
  text <- gsub("^\\s*\\}\\s*$", "", text)

  # Convert \code{} to backticks

  text <- gsub("\\\\code\\{([^}]+)\\}", "`\\1`", text)

  # Convert \link{} to backticks
  text <- gsub("\\\\link\\{([^}]+)\\}", "`\\1`", text)

  # Convert \emph{} to italics
  text <- gsub("\\\\emph\\{([^}]+)\\}", "*\\1*", text)

  # Convert \strong{} and \bold{} to bold
  text <- gsub("\\\\strong\\{([^}]+)\\}", "**\\1**", text)
  text <- gsub("\\\\bold\\{([^}]+)\\}", "**\\1**", text)

  # Convert \pkg{} to bold
  text <- gsub("\\\\pkg\\{([^}]+)\\}", "**\\1**", text)

  # Convert \file{} to backticks
  text <- gsub("\\\\file\\{([^}]+)\\}", "`\\1`", text)

  # Convert \sQuote{} and \dQuote{}
  text <- gsub("\\\\sQuote\\{([^}]+)\\}", "'\\1'", text)
  text <- gsub("\\\\dQuote\\{([^}]+)\\}", "\"\\1\"", text)

  # Convert \dots and \ldots
  text <- gsub("\\\\dots\\b", "...", text)
  text <- gsub("\\\\ldots\\b", "...", text)

  # Convert \R to R
  text <- gsub("\\\\R\\b", "R", text)

  # Clean up extra whitespace
  text <- gsub("\n{3,}", "\n\n", text)

  trimws(text)
}

#' Convert Rd Content to Markdown
#'
#' Handles Rd markup like \\code{}, \\link{}, \\emph{}, etc.
#' @keywords internal
.rd_content_to_md <- function(element) {
  if (is.character(element)) {
    return(element)
  }

  result <- character()

  for (child in element) {
    tag <- attr(child, "Rd_tag")

    if (is.null(tag)) {
      # Plain text
      if (is.character(child)) {
        result <- c(result, child)
      } else {
        result <- c(result, .rd_content_to_md(child))
      }
    } else {
      content <- .rd_element_to_text(child)
      md <- switch(tag,
        "\\code" = paste0("`", content, "`"),
        "\\link" = paste0("`", content, "`"),
        "\\linkS4class" = paste0("`", content, "`"),
        "\\pkg" = paste0("**", content, "**"),
        "\\emph" = paste0("*", content, "*"),
        "\\strong" = paste0("**", content, "**"),
        "\\bold" = paste0("**", content, "**"),
        "\\sQuote" = paste0("'", content, "'"),
        "\\dQuote" = paste0("\"", content, "\""),
        "\\file" = paste0("`", content, "`"),
        "\\url" = content,
        "\\href" = {
          # \href{url}{text} - child[[1]] is url, child[[2]] is text
          if (length(child) >= 2) {
            url <- .rd_element_to_text(child[[1]])
            text <- .rd_element_to_text(child[[2]])
            paste0("[", text, "](", url, ")")
          } else {
            content
          }
        },
        "\\email" = content,
        "\\var" = paste0("*", content, "*"),
        "\\env" = paste0("`", content, "`"),
        "\\option" = paste0("`", content, "`"),
        "\\command" = paste0("`", content, "`"),
        "\\dfn" = paste0("*", content, "*"),
        "\\acronym" = content,
        "\\dots" = "...",
        "\\ldots" = "...",
        "\\cr" = "\n",
        "\\tab" = "\t",
        "\\R" = "R",
        "\\describe" = .rd_describe_to_md(child),
        "\\itemize" = .rd_itemize_to_md(child),
        "\\enumerate" = .rd_enumerate_to_md(child),
        "\\item" = .rd_content_to_md(child), # handled by parent
        "RCODE" = content,
        "TEXT" = content,
        "VERB" = content,
        "COMMENT" = "",
        # Default: just extract content
        .rd_content_to_md(child)
      )
      result <- c(result, md)
    }
  }

  # Clean up whitespace and post-process embedded Rd markup
  text <- paste(result, collapse = "")
  text <- .postprocess_rd_text(text)
  trimws(text)
}

#' Convert Rd Verbatim Content (usage, examples)
#' @keywords internal
.rd_verbatim <- function(element) {
  text <- .rd_element_to_text(element)
  # Clean up but preserve structure
  text <- gsub("^\\n+|\\n+$", "", text) # Trim leading/trailing newlines
  text
}

#' Convert \\arguments Section to Markdown
#' @keywords internal
.rd_arguments_to_md <- function(element) {
  lines <- character()

  for (child in element) {
    tag <- attr(child, "Rd_tag")
    if (identical(tag, "\\item")) {
      # \item{name}{description}
      if (length(child) >= 2) {
        arg_name <- .rd_element_to_text(child[[1]])
        arg_desc <- .rd_content_to_md(child[[2]])
        lines <- c(lines, paste0("- **`", arg_name, "`**: ", arg_desc))
      }
    }
  }

  paste(lines, collapse = "\n")
}

#' Convert \\describe to Markdown
#' @keywords internal
.rd_describe_to_md <- function(element) {
  lines <- character()

  for (child in element) {
    tag <- attr(child, "Rd_tag")
    if (identical(tag, "\\item")) {
      if (length(child) >= 2) {
        item_name <- .rd_element_to_text(child[[1]])
        item_desc <- .rd_content_to_md(child[[2]])
        lines <- c(lines, paste0("- **", item_name, "**: ", item_desc))
      }
    }
  }

  paste(lines, collapse = "\n")
}

#' Convert \\itemize to Markdown
#' @keywords internal
.rd_itemize_to_md <- function(element) {
  lines <- character()

  for (child in element) {
    tag <- attr(child, "Rd_tag")
    if (identical(tag, "\\item")) {
      item_text <- .rd_content_to_md(child)
      lines <- c(lines, paste0("- ", item_text))
    }
  }

  paste(lines, collapse = "\n")
}

#' Convert \\enumerate to Markdown
#' @keywords internal
.rd_enumerate_to_md <- function(element) {
  lines <- character()
  i <- 1

  for (child in element) {
    tag <- attr(child, "Rd_tag")
    if (identical(tag, "\\item")) {
      item_text <- .rd_content_to_md(child)
      lines <- c(lines, paste0(i, ". ", item_text))
      i <- i + 1
    }
  }

  paste(lines, collapse = "\n")
}

