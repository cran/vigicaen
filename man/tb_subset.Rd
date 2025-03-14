% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tb_subset.R
\name{tb_subset}
\alias{tb_subset}
\title{Extract of subset of Vigibase}
\usage{
tb_subset(
  wd_in,
  wd_out,
  subset_var = c("drecno", "medprod_id", "meddra_id", "age"),
  sv_selection,
  rm_suspdup = TRUE
)
}
\arguments{
\item{wd_in}{Source directory pathway (character)}

\item{wd_out}{Output directory pathway (character)}

\item{subset_var}{One of \code{"drecno"}, \code{"medprod_id"}, \code{"meddra_id"}, \code{"age"}}

\item{sv_selection}{A named list or a vector containing the appropriate ids (according to the method, see details)}

\item{rm_suspdup}{A logical. Should suspected duplicates be removed? TRUE by default}
}
\value{
Parquet files in the output directory. All files from a
vigibase ECL main folder are returned subsetted
(including suspectedduplicates).
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{\figure{lifecycle-stable.svg}{options: alt='[Stable]'}}}{\strong{[Stable]}} Create a subset of the VigiBase
ECL datasets
}
\details{
You must select a subset variable with \code{subset_var} and provide
an appropriate list according to this variable in \code{sv_selection}.
Available \code{subset_var} :
\itemize{
\item \code{drecno} will use Drug Record Number (DrecNo), from WHO Drug, and will subset from \code{drug} (see \code{\link[=get_drecno]{get_drecno()}}).
\item \code{medprod_id} will use MedicinalProd_Id, also from \code{drug}. May be useful if requesting from ATC classes. (see \code{\link[=get_atc_code]{get_atc_code()}}).
\item \code{meddra_id} will use MedDRA_Id, subset from \code{adr}. (see \code{\link[=get_llt_soc]{get_llt_soc()}} or See \code{\link[=get_llt_smq]{get_llt_smq()}}).
\item \code{age} will use AgeGroup from \code{demo}. See below.
}
Age groups ids are as follows:
\itemize{
\item 1 0 - 27 days
\item 2 28 days to 23 months
\item 3 2 - 11 years
\item 4 12 - 17 years
\item 5 18 - 44 years
\item 6 45 - 64 years
\item 7 65 - 74 years
\item 8 >= 75 years
\item 9 Unknown
}
Example: To work with patients aged 18 to 74, provide \code{c(5, 6, 7)}
as \code{sv_selection}.

Use \code{\link[=dt_parquet]{dt_parquet()}} to load the tables afterward.
}
\examples{
\dontshow{if (interactive()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}

# --- technical steps ---- #

wd_in <- paste0(tempdir(), "/", "tbsubsetex")
dir.create(wd_in)
create_ex_main_pq(wd_in)

# Select a subset_var and corresponding data

# Subset on adr colitis codes

adr_llt <-
 list(
   colitis = "Colitis"
   ) |>
   get_llt_soc(term_level = "pt", meddra_, verbose = FALSE)

wd_out <- paste0(wd_in, "/", "colitis_subset", "/")

tb_subset(wd_in, wd_out,
          subset_var = "meddra_id",
          sv_selection = adr_llt)

# Subset on drug codes

 d_drecno <-
   list(
    ipi = "ipilimumab") |>
    get_drecno(mp = mp_, verbose = FALSE)

wd_out <- paste0(wd_in, "/", "nivolumab_subset", "/")

tb_subset(wd_in, wd_out,
          subset_var = "drecno",
          sv_selection = d_drecno)

 # Subset on age > 65 year-old

 sv_selection <-
    c(7, 8)

wd_out <- paste0(wd_in, "/", "more_than_65_subset", "/")

tb_subset(wd_in, wd_out,
          subset_var = "age",
          sv_selection = sv_selection)

unlink(wd_in, recursive = TRUE)
\dontshow{\}) # examplesIf}
}
\seealso{
\code{\link[=get_drecno]{get_drecno()}}, \code{\link[=get_atc_code]{get_atc_code()}}, \code{\link[=get_llt_soc]{get_llt_soc()}}, \code{\link[=get_llt_smq]{get_llt_smq()}}, \code{\link[=dt_parquet]{dt_parquet()}}
}
\keyword{custom}
\keyword{dataset}
\keyword{subset}
