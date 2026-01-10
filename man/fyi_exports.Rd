\name{fyi_exports}
\alias{fyi_exports}
\title{List Exported Functions}
\description{Returns functions exported by a package.}
\usage{
fyi_exports(package, pattern)
}
\arguments{
  \item{package}{Character. Package name.}
  \item{pattern}{Optional regex to filter function names.}
}
\value{
A data.frame with columns: name, args.
}
\examples{
\dontrun{
fyi_exports("sttapi")
}
}
