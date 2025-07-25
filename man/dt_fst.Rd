% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dt_fst.R
\name{dt_fst}
\alias{dt_fst}
\title{Read fst and convert to data.table}
\usage{
dt_fst(path_base, name = NULL, ext = ".fst")
}
\arguments{
\item{path_base}{A character string, providing the path to read from.}

\item{name}{A character string, the file name.}

\item{ext}{A character string, optional, specifying the file extension.}
}
\value{
A data.table, read from \code{path_base/(name)}.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#deprecated}{\figure{lifecycle-deprecated.svg}{options: alt='[Deprecated]'}}}{\strong{[Deprecated]}} Short hand to \code{as.data.table(read_fst())}.
File extension can be omitted.
}
\details{
Output is a data.table.
The function is deprecated, with the use of parquet tables. Tables can now
be loaded \strong{IN}-memory or \strong{OUT} of memory with \code{\link{dt_parquet}}.
}
\examples{

# dt_fst is deprecated and will generate an error
}
\seealso{
\code{\link[=dt_parquet]{dt_parquet()}}, \code{\link[=tb_vigibase]{tb_vigibase()}}, \code{\link[=tb_who]{tb_who()}}, \code{\link[=tb_meddra]{tb_meddra()}}
}
\keyword{import}
