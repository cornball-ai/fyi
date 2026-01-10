\name{fyi_help}
\alias{fyi_help}
\title{Get Help Documentation for a Topic}
\description{Extracts help documentation as plain text, suitable for LLM consumption.}
\usage{
fyi_help(topic, package)
}
\arguments{
  \item{topic}{Character. The topic to get help for.}
  \item{package}{Character. Package name.}
}
\value{
Character string of help text, invisibly. Also prints to console.
}
\examples{
\dontrun{
fyi_help("transcribe", "sttapi")
}
}
