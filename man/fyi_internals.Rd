\name{fyi_internals}
\alias{fyi_internals}
\title{List Internal (Non-Exported) Functions}
\description{Returns functions defined in a package namespace but not exported.}
\usage{
fyi_internals(package, pattern)
}
\arguments{
  \item{package}{Character. Package name.}
  \item{pattern}{Optional regex to filter function names.}
}
\value{
A data.frame with columns: name, args, internal (all TRUE).
}
\examples{
\dontrun{
fyi_internals("sttapi")
fyi_internals("sttapi", pattern = "^\\.")
}
}
