% tinyrox says don't edit this manually, but it can't stop you!
\name{rd2md}
\alias{rd2md}
\title{Convert Rd Object to Markdown}
\usage{
rd2md(rd)
}
\arguments{
\item{rd}{A parsed Rd object (from tools::Rd_db or tools::parse_Rd).}
}
\value{
Character string of markdown.
}
\description{
Pure R conversion of parsed Rd objects to clean markdown,
without the ugly ASCII formatting of Rd2txt.
}
\keyword{internal}
