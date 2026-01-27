% tinyrox says don't edit this manually, but it can't stop you!
\name{fyi_options}
\alias{fyi_options}
\title{Extract Option Names from Package Source}
\usage{
fyi_options(package, src_dir = NULL)
}
\arguments{
\item{package}{Character. Package name (must be installed).}

\item{src_dir}{Optional. Path to source directory. If NULL, uses
installed package location.}
}
\value{
A data.frame with columns: option, file, type (get/set).
}
\description{
Scans R source files for getOption() and options() calls to find
option names used by a package.
}
\examples{
\dontrun{
fyi_options("sttapi")
fyi_options("sttapi", src_dir = "~/sttapi")
}
}
