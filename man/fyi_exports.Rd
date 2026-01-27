% tinyrox says don't edit this manually, but it can't stop you!
\name{fyi_exports}
\alias{fyi_exports}
\title{List Exported Functions}
\usage{
fyi_exports(package, pattern = NULL)
}
\arguments{
\item{package}{Character. Package name.}

\item{pattern}{Optional regex to filter function names.}
}
\value{
A data.frame with columns: name, args.
}
\description{
Returns functions exported by a package.
}
\examples{
\dontrun{
fyi_exports("sttapi")
}
}
