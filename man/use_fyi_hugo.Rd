% tinyrox says don't edit this manually, but it can't stop you!
\name{use_fyi_hugo}
\alias{use_fyi_hugo}
\title{Generate Hugo Documentation Site for a Package}
\usage{
use_fyi_hugo(
  package,
  dir,
  src_dir = NULL,
  pattern = NULL,
  exports_only = TRUE,
  clean = TRUE
)
}
\arguments{
\item{package}{Character. Package name.}

\item{dir}{Directory to write docs. Creates `<dir>/_index.md` and `<dir>/reference/`.}

\item{src_dir}{Optional path to package source directory (for README).
If NULL, looks in `~/<package>/`.}

\item{pattern}{Optional regex to filter which functions to document.}

\item{exports_only}{Logical. Only document exported functions? Default TRUE.}

\item{clean}{Logical. Remove existing files first? Default TRUE.}
}
\value{
Path to the generated directory, invisibly.
}
\description{
Creates a pkgdown-style documentation structure for Hugo static sites.
Generates package overview from README, function reference pages, and
a reference index.
}
\examples{
\dontrun{
# Generate docs for whisper package
use_fyi_hugo("whisper", "content/docs/whisper")

# Generate docs for package in custom location
use_fyi_hugo("mypackage", "site/docs/mypackage", src_dir = "~/projects/mypackage")

# Only include specific functions
use_fyi_hugo("torch", "content/docs/torch", pattern = "^nn_")
}
}
