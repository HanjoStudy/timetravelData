% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/document_meta.R
\name{document_meta}
\alias{document_meta}
\title{Return the meta data for a given document}
\usage{
document_meta(guid_hash, tidy = TRUE)
}
\arguments{
\item{guid_hash}{Document global unique identifier to look up in the elasticsearch.}

\item{tidy}{Tidy the results into a nested tibble \link{DEFAULT: TRUE}.}
}
\value{
tibble.
}
\description{
Return the meta data for a given document
}
\examples{
# Search for document.
\dontrun{
document_meta(guid_hash ="1c5c4be6f456e84d992c")
}

}
