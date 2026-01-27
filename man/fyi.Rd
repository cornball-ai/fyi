% tinyrox says don't edit this manually, but it can't stop you!
\name{fyi}
\alias{fyi}
\title{Get Complete Package Information for LLMs}
\usage{
fyi(
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
)
}
\arguments{
\item{package}{Character. Package name.}

\item{src_dir}{Optional path to source directory for options extraction.}

\item{internals}{Logical. Include internal functions? Default TRUE.}

\item{options}{Logical. Include option names? Default TRUE.}

\item{exports}{Logical. Include exported functions? Default TRUE.}

\item{docs}{Logical. Include full documentation? Default FALSE (can be verbose).}

\item{pattern}{Optional regex to filter exports/internals/topics.}

\item{max_exports}{Maximum number of exports to show. Default NULL (all).}

\item{max_internals}{Maximum number of internals to show. Default NULL (all).}

\item{max_topics}{Maximum number of doc topics to list. Default NULL (all).}
}
\value{
Character string of markdown, invisibly. Also prints to console.
}
\description{
The main function - returns everything an LLM needs to understand a package,
including exports, internals, options, and optionally full documentation.
}
\examples{
\dontrun{
fyi("sttapi")
fyi("llamaR", internals = TRUE, options = FALSE)
fyi("sttapi", docs = TRUE)  # Include full help docs

# For large packages like torch, filter to reduce size
fyi("torch", pattern = "^nn_", internals = FALSE)
fyi("torch", max_exports = 50, max_internals = 0, max_topics = 50)
}
}
