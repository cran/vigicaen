#' Rechallenge descriptive
#'
#' @description `r lifecycle::badge('stable')` Computes counts of rechallenge cases,
#' over a set of adr and drug pairs.
#'
#' @details Counts are provided at the **case** level (not the drug-adr pair level).
#' Description span from number of rechallenge cases
#' to __informative__ rechallenge cases (those cases where the outcome is known).
#' You will need a `link` data.table, see \code{\link{link_}}, on which
#' you have added drugs and adrs with [add_drug()] and [add_adr()].
#' Terminology
#' \itemize{
#'   \item `Overall` as opposed to `rch` for rechallenged (`rch` + `no_rch` = `overall`).
#'   \item Among `rch`, `inf` (informative) as opposed to `non_inf` (`inf` + `non_inf` = `rch`)
#'   \item Among `inf`, `rec` (recurring) as opposed to `non_rec` (`rec` + `non_rec` = `inf`)
#' }
#'
#' @param .data A `link` data.table. See \code{\link{link_}}.
#' @param drug_s A character string. The name of the drug column. Drug columns can be created with \code{\link{add_drug}}.
#' @param adr_s A character string. The name of the adr column. Adr columns can be created with \code{\link{add_adr}}.
#'
#' @returns A data.table with one row per drug-adr pair
#' \itemize{
#'   \item `drug_s` and `adr_s`, same as input.
#'   \item Counts of __overall__, __rch__, __inf__, and __rec__ cases (see details).
#' }
#' @export
#' @keywords drug-adr-pair descriptive
#' @seealso \code{\link{link_}}, [add_drug()], [add_adr()], [desc_dch()], [desc_tto()]
#' @importFrom rlang .data
#' @importFrom rlang .env
#' @importFrom data.table .N
#'
#' @examples
#' link_ <-
#'   link_ |>
#'   add_drug(
#'     d_code = ex_$d_groups_drecno,
#'     drug_data = drug_
#'   ) |>
#'   add_adr(
#'     a_code = ex_$a_llt,
#'     adr_data = adr_
#'   )
#'
#' desc_rch(.data = link_,
#'          drug_s = "pd1",
#'          adr_s = "a_colitis")
#'
#' # You can vectorize over drugs and adrs
#'
#' desc_rch(.data = link_,
#'          adr_s = c("a_colitis", "a_pneumonitis"),
#'          drug_s = c("pd1", "pdl1")
#'          )

desc_rch <- function(.data,
                     drug_s = "drug1",
                     adr_s = "adr1"
){

  check_data_link(.data)

  core_desc_rch <-
    function(one_drug,
             one_adr,
             UMCReportId = {{ UMCReportId }}
    ){
      link_sel <- # selection
        .data |>
        dplyr::filter(.data[[one_drug]] == 1 &
                 .data[[one_adr]] == 1
               )

      n_overall <- link_sel |>
        dplyr::distinct(.data$UMCReportId) |>
        dplyr::count() |>
        dplyr::collect() |>
        dplyr::pull()

      n_rch <-
        link_sel |>
        dplyr::filter(.data$Rechallenge1 == "1") |>
        dplyr::distinct(.data$UMCReportId) |>
        dplyr::count() |>
        dplyr::collect() |>
        dplyr::pull()

      n_inf <-
        link_sel |>
        dplyr::filter(.data$Rechallenge2 %in% c("1", "2")) |>
        dplyr::distinct(.data$UMCReportId) |>
        dplyr::count() |>
        dplyr::collect() |>
        dplyr::pull()

      n_rec <-
        link_sel |>
        dplyr::filter(.data$Rechallenge2 == "1") |>
        dplyr::distinct(.data$UMCReportId) |>
        dplyr::count() |>
        dplyr::collect() |>
        dplyr::pull()

      # Output of results
      data.table::data.table(
        drug_s = one_drug,
        adr_s = one_adr,

        n_overall,

        n_rch,
        n_inf,
        n_rec
        )
    }

  purrr::map(
    adr_s, function(one_adr_)
      purrr::map(
        drug_s, function(one_drug_)
          core_desc_rch(
            one_drug = one_drug_,
            one_adr = one_adr_
          )
      ) |>
      purrr::list_rbind()
  ) |>
    purrr::list_rbind()

}
