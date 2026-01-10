\name{fyi_docs}
\alias{fyi_docs}
\title{Get All Help Documentation for a Package}
\description{Extracts all help documentation as markdown, suitable for LLM consumption.}
\usage{
fyi_docs(package, topics)
}
\arguments{
  \item{package}{Character. Package name.}
  \item{topics}{Optional character vector of specific topics to include.}
}
\value{
Character string of markdown, invisibly. Also prints to console.
}
\examples{
\dontrun{
fyi_docs("sttapi")
fyi_docs("sttapi", topics = c("transcribe", "set_stt_base"))
}
}
