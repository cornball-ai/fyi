\name{use_fyi_md}
\alias{use_fyi_md}
\title{Create Persistent fyi.md File}
\description{Generates package information and writes it to a markdown file for persistent LLM context in your project.}
\usage{
use_fyi_md(package, path, src_dir, internals, options, exports, docs, append)
}
\arguments{
  \item{package}{Character. Package name.}
  \item{path}{File path to write. Default "fyi.md" in current directory.}
  \item{src_dir}{Optional path to source directory for options extraction.}
  \item{internals}{Logical. Include internal functions? Default TRUE.}
  \item{options}{Logical. Include option names? Default TRUE.}
  \item{exports}{Logical. Include exported functions? Default TRUE.}
  \item{docs}{Logical. Include full documentation? Default FALSE.}
  \item{append}{Logical. Append to existing file? Default FALSE (overwrite).}
}
\value{
The file path, invisibly.
}
\examples{
\dontrun{
# Create fyi.md for a package
use_fyi_md("sttapi")

# Custom path
use_fyi_md("sttapi", path = "docs/sttapi-context.md")

# Multiple packages in one file
use_fyi_md("sttapi", path = "context.md")
use_fyi_md("ttsapi", path = "context.md", append = TRUE)

# Include full docs
use_fyi_md("sttapi", docs = TRUE)
}
}
