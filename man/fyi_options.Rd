\name{fyi_options}
\alias{fyi_options}
\title{Extract Option Names from Package Source}
\description{Scans R source files for getOption() and options() calls to find option names used by a package.}
\usage{
fyi_options(package, src_dir)
}
\arguments{
  \item{package}{Character. Package name (must be installed).}
  \item{src_dir}{Optional. Path to source directory. If NULL, uses installed package location.}
}
\value{
A data.frame with columns: option, file, type (get/set).
}
\examples{
\dontrun{
fyi_options("sttapi")
fyi_options("sttapi", src_dir = "~/sttapi")
}
}
