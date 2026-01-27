% tinyrox says don't edit this manually, but it can't stop you!
\name{.format_docs_summary_md}
\alias{.format_docs_summary_md}
\title{Format Docs Summary as Markdown}
\usage{
.format_docs_summary_md(package, pattern = NULL, max_topics = NULL)
}
\arguments{
\item{package}{Character. Package name.}

\item{pattern}{Optional regex to filter topics.}

\item{max_topics}{Maximum number of topics to show. Default NULL (all).}
}
\value{
Character string of markdown
}
\description{
Creates a compact summary of package documentation.
}
\keyword{internal}
