% tinyrox says don't edit this manually, but it can't stop you!
\name{fyi_cache_path}
\alias{fyi_cache_path}
\title{Get Cache Path for a Package}
\usage{
fyi_cache_path(package)
}
\arguments{
\item{package}{Character. Package name.}
}
\value{
Character path to ~/.fyi/<package>/
}
\description{
Returns the path where cached docs would be stored for a package.
}
\examples{
fyi_cache_path("torch")
# Returns: "~/.fyi/torch"
}
