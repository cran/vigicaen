test_that("basic use and here package works", {
  f_sets <-
   list(
     DEMO.txt = data.frame(f0 = c("96548661   32194501051119460820")),
     DRUG.txt = data.frame(f0 = c("70548965   8          4901354    064392080055011    31- 806")
                           ),
     LINK.txt = data.frame(f0 = c("2              17     51---0.78991   0.98745    ",
                                  "2              14     51---6.98789   -          ")),
     FOLLOWUP.txt = data.frame(f0 = c("0548978    0254687    ",
                                      "7568798    4565321    ")),
     ADR.txt = data.frame(f0 = c("96570161   14         100474561",
                                 "70578465   17         145078144")),
     OUT.txt = data.frame(f0 = c("70547815   - N",
                                 "96575661   - Y")),
     SRCE.txt = data.frame(f0 = c("4898765    1 ",
                                  "9804562    1 ")),
     IND.txt = data.frame(# 266 length
       f0 = "     8     Cutaneous diseases due to other mycobacteria                                                                                                                                                                                                                "
       ),
     SUSPECTEDDUPLICATES.txt = data.frame(f0 = c("789054     789542     ",
                                                 "780546     654352     ")),
     AgeGroup_Lx.txt = data.frame(f0 = c("1An age range             ")),
     Dechallenge_Lx.txt = data.frame(f0 = c("1Some drug action                                                                                                                                                                                                                                                ")),
     Dechallenge2_Lx.txt = data.frame(f0 = c("1Some outcome occurring                                                                                                                                                                                                                                          ")),
     Frequency_Lx.txt = data.frame(f0 = c("123Some frequency of administration                                                                                                                                                                                                                                ")),
     Gender_Lx.txt = data.frame(f0 = c("1Some gender                                                                                                                                                                                                                                                     ")),
     Notifier_Lx.txt = data.frame(f0 = c("1 Some notifier                                                                                                                                                                                                                                                   ")),
     Outcome_Lx.txt = data.frame(f0 = c("1Some outcome                                                                                                                                                                                                                                                    ")),
     Rechallenge_Lx.txt = data.frame(f0 = c("1A rechallenge action                                                            ")),
     Rechallenge2_Lx.txt = data.frame(f0 = c("1A reaction recurrence status                                    ")),
     Region_Lx.txt = data.frame(f0 = c("1A world region                                    ")),
     RepBasis_Lx.txt = data.frame(f0 = c("1A reputation basis                                ")),
     ReportType_Lx.txt = data.frame(f0 = c("1A type of report                                                                                                                                                                                                                                                ")),
     RouteOfAdm_Lx.txt = data.frame(f0 = c("1 A route of admnistration                                                        ")),
     Seriousness_Lx.txt = data.frame(f0 = c("1 Some seriousness criteria                                                                                                                                                                                                                                   ")),
     SizeUnit_Lx.txt = data.frame(f0 = c("1 A dosing unit                                                                  "))
   )

  tmp_folder <- tempdir()

  path_base <- paste0(tmp_folder, "/", "main", "/")

  if(!dir.exists(path_base))
    dir.create(path_base)

  path_sub  <- paste0(tmp_folder, "/", "sub",  "/")

  if(!dir.exists(path_sub))
    dir.create(path_sub)

  purrr::iwalk(f_sets, function(d_, name_){
    if(name_ %in%
       c("SUSPECTEDDUPLICATES.txt",
         "AgeGroup_Lx.txt",
         "Dechallenge_Lx.txt",
         "Dechallenge2_Lx.txt",
         "Frequency_Lx.txt",
         "Gender_Lx.txt",
         "Notifier_Lx.txt",
         "Outcome_Lx.txt",
         "Rechallenge_Lx.txt",
         "Rechallenge2_Lx.txt",
         "Region_Lx.txt",
         "RepBasis_Lx.txt",
         "ReportType_Lx.txt",
         "RouteOfAdm_Lx.txt",
         "Seriousness_Lx.txt",
         "SizeUnit_Lx.txt")
         ){
      write.table(d_, file = paste0(path_sub, name_), row.names = FALSE, quote = FALSE, col.names = FALSE)
    } else {
      write.table(d_, file = paste0(path_base, name_), row.names = FALSE, quote = FALSE, col.names = FALSE)
    }
  })

   expect_snapshot({
     options(cli.progress_show_after = 0)
     options(cli.progress_clear = FALSE)
     tb_vigibase(path_base = path_base,
                 path_sub  = path_sub,
                 force = TRUE,
                 overwrite_existing_tables = TRUE)
   },
   transform =
     function(chr_line)
       stringr::str_replace(
         chr_line,
         "(?>=\\d{1,3}\\%\\s| ).*(?= \\|)",
         " percent, seconds"
       )
   )


   demo_res <- arrow::read_parquet(paste0(path_base, "demo.parquet"),
                                   mmap = FALSE)

   drug_res <- arrow::read_parquet(paste0(path_base, "drug.parquet"),
                                   mmap = FALSE)

   link_res <- arrow::read_parquet(paste0(path_base, "link.parquet"),
                                   mmap = FALSE) |>
     dplyr::mutate(
       range = cff(range, dig = 2),
       tto_mean = cff(tto_mean, dig = 2)
     )

   adr_res  <- arrow::read_parquet(paste0(path_base, "adr.parquet"),
                                   mmap = FALSE)

   ind_res  <- arrow::read_parquet(paste0(path_base, "ind.parquet"),
                                   mmap = FALSE)

   demo_true <-
     dplyr::tibble(
       UMCReportId = 96548661,
       AgeGroup = "3",
       Gender = "2",
       DateDatabase = "19450105",
       Type = "1",
       Region = "1",
       FirstDateDatabase = "19460820")

   drug_true <-
     dplyr::tibble(
       UMCReportId = 70548965,
       Drug_Id = 8,
       MedicinalProd_Id = 4901354,
       DrecNo = 64392,
       Seq1 = "08",
       Seq2 = "005",
       Route = "50",
       Basis = "1",
       Amount = "1    ",
       AmountU = "31",
       Frequency = "- ",
       FrequencyU = "806"
       )

   adr_true <-
     dplyr::tibble(
       UMCReportId = c(96570161, 70578465),
       Adr_Id = c(14, 17),
       MedDRA_Id = c(10047456, 14507814),
       Outcome = c("1", "4")
     )

   link_true <-
     dplyr::tibble(
       Drug_Id = c(2, 2),
       Adr_Id = c(17, 14),
       Dechallenge1 = c("5", "5"),
       Dechallenge2 = c("1", "1"),
       Rechallenge1 = c("-", "-"),
       Rechallenge2 = c("-", "-"),
       TimeToOnsetMin = c(-0.78991, -6.98789),
       TimeToOnsetMax = c(0.98745, NA),
       tto_mean = c("0.10", NA_character_),
       range = c("0.89", NA_character_),
       UMCReportId = c(70578465, 96570161)
     )

   ind_true <-
     dplyr::tibble(
       Drug_Id = 8,
       Indication = "Cutaneous diseases due to other mycobacteria")

   expect_equal(demo_res, demo_true)

   expect_equal(drug_res, drug_true)

   expect_equal(link_res, link_true)

   expect_equal(ind_res, ind_true)

   expect_equal(adr_res, adr_true)


   # here syntax

   here_path_base <- here::here(tmp_folder, "main")

   here_path_sub <- here::here(tmp_folder, "sub")

   expect_snapshot(
     tb_vigibase(path_base = here_path_base,
                 path_sub  = here_path_sub,
                 force = TRUE,
                 overwrite_existing_tables = TRUE),
     transform =
       function(chr_line)
         stringr::str_replace(
           chr_line,
           "(?>=\\d{1,3}\\%\\s| ).*(?= \\|)",
           " percent, seconds"
         )
   )

   demo_res_here <- arrow::read_parquet(here::here(here_path_base, "demo.parquet"),
                                        mmap = FALSE)

   expect_equal(demo_res_here, demo_true)


   # mix of path with end slash and without, for path_base and path_sub

   expect_snapshot(
     tb_vigibase(path_base = path_base,
                 path_sub  = here_path_sub,
                 force = TRUE,
                 overwrite_existing_tables = TRUE),
     transform =
       function(chr_line)
         stringr::str_replace(
           chr_line,
           "(?>=\\d{1,3}\\%\\s| ).*(?= \\|)",
           " percent, seconds"
         )
   )

   expect_snapshot(
     tb_vigibase(
       path_base = here_path_base,
       path_sub  = path_sub,
       force = TRUE,
       overwrite_existing_tables = TRUE
     ),

     transform =
       function(chr_line)
         stringr::str_replace(
           chr_line,
           "(?>=\\d{1,3}\\%\\s| ).*(?= \\|)",
           " percent, seconds"
         )
   )

   age_group_res <-
     arrow::read_parquet(paste0(path_sub, "AgeGroup.parquet"),
                         mmap = FALSE)

   dechallenge_res <-
     arrow::read_parquet(paste0(path_sub, "Dechallenge.parquet"),
                         mmap = FALSE)

   dechallenge2_res <-
     arrow::read_parquet(paste0(path_sub, "Dechallenge2.parquet"),
                         mmap = FALSE)

   frequency_res <-
     arrow::read_parquet(paste0(path_sub, "Frequency.parquet"),
                         mmap = FALSE)

   gender_res <-
     arrow::read_parquet(paste0(path_sub, "Gender.parquet"),
                         mmap = FALSE)

   notifier_res <-
     arrow::read_parquet(paste0(path_sub, "Notifier.parquet"),
                         mmap = FALSE)

   outcome_res <-
     arrow::read_parquet(paste0(path_sub, "Outcome.parquet"),
                         mmap = FALSE)

   rechallenge_res <-
     arrow::read_parquet(paste0(path_sub, "Rechallenge.parquet"),
                         mmap = FALSE)

   rechallenge2_res <-
     arrow::read_parquet(paste0(path_sub, "Rechallenge2.parquet"),
                         mmap = FALSE)

   region_res <-
     arrow::read_parquet(paste0(path_sub, "Region.parquet"),
                         mmap = FALSE)

   rep_basis_res <-
     arrow::read_parquet(paste0(path_sub, "RepBasis.parquet"),
                         mmap = FALSE)

   report_type_res <-
     arrow::read_parquet(paste0(path_sub, "ReportType.parquet"),
                         mmap = FALSE)

   route_of_adm_res <-
     arrow::read_parquet(paste0(path_sub, "RouteOfAdm.parquet"),
                         mmap = FALSE)

   seriousness_res <-
     arrow::read_parquet(paste0(path_sub, "Seriousness.parquet"),
                         mmap = FALSE)

   size_unit_res <-
     arrow::read_parquet(paste0(path_sub, "SizeUnit.parquet"),
                         mmap = FALSE)

   expect_equal(age_group_res,
                dplyr::tibble(
                  AgeGroup = "1",
                  Code = "An age range")
   )

   expect_equal(dechallenge_res,
                dplyr::tibble(
                  Dechallenge1 = "1",
                  Code = "Some drug action")
   )

   expect_equal(dechallenge2_res,
                dplyr::tibble(
                  Dechallenge2 = "1",
                  Code = "Some outcome occurring")
   )

   expect_equal(frequency_res,
                dplyr::tibble(
                  FrequencyU = "123",
                  Code = "Some frequency of administration")
   )

   expect_equal(gender_res,
                dplyr::tibble(
                  Gender = "1",
                  Code = "Some gender")
   )

   expect_equal(notifier_res,
                dplyr::tibble(
                  Type = 1L,
                  Code = "Some notifier")
   )

   expect_equal(outcome_res,
                dplyr::tibble(
                  Outcome = "1",
                  Code = "Some outcome")
   )

   expect_equal(rechallenge_res,
                dplyr::tibble(
                  Rechallenge1 = "1",
                  Code = "A rechallenge action")
   )

   expect_equal(rechallenge2_res,
                dplyr::tibble(
                  Rechallenge2 = "1",
                  Code = "A reaction recurrence status")
   )

   expect_equal(region_res,
                dplyr::tibble(
                  Region = "1",
                  Code = "A world region")
   )

   expect_equal(rep_basis_res,
                dplyr::tibble(
                  Basis = "1",
                  Code = "A reputation basis")
   )

   expect_equal(report_type_res,
                dplyr::tibble(
                  ReportType = "1",
                  Code = "A type of report")
   )

   expect_equal(route_of_adm_res,
                dplyr::tibble(
                  Route = 1L,
                  Code = "A route of admnistration")
   )

   expect_equal(seriousness_res,
                dplyr::tibble(
                  Seriousness = 1L,
                  Code = "Some seriousness criteria")
   )

   expect_equal(size_unit_res,
                dplyr::tibble(
                  AmountU = 1L,
                  Code = "A dosing unit")
   )

     unlink(tmp_folder, recursive = TRUE)
})

test_that("path_base and path_sub exist before working on tables", {
  wrong_path <- "/a/wrong/filepath/"

  right_path <- tempdir()

  expect_error(
    tb_vigibase(path_base = wrong_path,
            path_sub  = right_path,
            force = TRUE),
    class = "no_dir",
    regexp = wrong_path
  )

  cnd_base <- rlang::catch_cnd(
    tb_vigibase(path_base = wrong_path,
                path_sub  = right_path,
                force = TRUE)
  )

  expect_equal(cnd_base$dir, "path_base")
  expect_equal(cnd_base$wrong_dir, wrong_path)

  expect_error(
    tb_vigibase(path_base = right_path,
            path_sub  = wrong_path,
            force = TRUE),
    class = "no_dir",
    regexp = wrong_path
  )

  cnd_sub <- rlang::catch_cnd(
    tb_vigibase(path_base = right_path,
                path_sub  = wrong_path,
                force = TRUE)
  )

  expect_equal(cnd_sub$dir, "path_sub")
  expect_equal(cnd_sub$wrong_dir, wrong_path)

  expect_error(
    tb_vigibase(path_base = wrong_path,
            path_sub  = wrong_path,
            force = TRUE),
    class = "no_dir",
    regexp = wrong_path
  )

  expect_snapshot(error = TRUE,
                  tb_vigibase(path_base = wrong_path,
                              # first check is on path_base
                              path_sub  = wrong_path,
                              force = TRUE),
                  cnd_class = TRUE
                  )
})

test_that("rm_suspdup removes suspected duplicates in main tables", {
  # Prepare test files using create_ex_main_txt and create_ex_sub_txt
  tmp_folder <- tempdir()
  path_base <- paste0(tmp_folder, "/test_tb_vigibase_duplicates_main/")
  path_sub  <- paste0(tmp_folder, "/test_tb_vigibase_duplicates_sub/")
  dir.create(path_base)
  dir.create(path_sub)


  create_ex_main_txt(path_base)
  create_ex_sub_txt(path_sub)

  # Call with rm_suspdup = TRUE (default)

  expect_snapshot({
    options(cli.progress_show_after = 0)
    options(cli.progress_clear = FALSE)
    tb_vigibase(path_base = path_base,
                path_sub = path_sub,
                force = TRUE,
                overwrite_existing_tables = TRUE)
  },
  transform =
    function(chr_line)
      stringr::str_replace(
        chr_line,
        "(?>=\\d{1,3}\\%\\s| ).*(?= \\|)",
        " percent, seconds"
      )
  )

  demo <- arrow::read_parquet(paste0(path_base, "demo.parquet"))
  drug <- arrow::read_parquet(paste0(path_base, "drug.parquet"))
  link <- arrow::read_parquet(paste0(path_base, "link.parquet"))
  expect_false(10000002 %in% demo$UMCReportId)
  expect_true(10000001 %in% demo$UMCReportId)
  expect_false(10000002 %in% drug$UMCReportId)
  expect_true(10000001 %in% drug$UMCReportId)
  # For link, check that only Drug_Id 8 remains (corresponding to non-duplicate UMCReportId)
  expect_true(all(link$Drug_Id == 8))

  # Call with rm_suspdup = FALSE

  expect_snapshot({
    options(cli.progress_show_after = 0)
    options(cli.progress_clear = FALSE)
    tb_vigibase(
      path_base = path_base,
      path_sub = path_sub,
      force = TRUE,
      rm_suspdup = FALSE,
      overwrite_existing_tables = TRUE
    )
  },
  transform =
    function(chr_line)
      stringr::str_replace(
        chr_line,
        "(?>=\\d{1,3}\\%\\s| ).*(?= \\|)",
        " percent, seconds"
      )
  )

  demo2 <- arrow::read_parquet(paste0(path_base, "demo.parquet"))
  drug2 <- arrow::read_parquet(paste0(path_base, "drug.parquet"))
  link2 <- arrow::read_parquet(paste0(path_base, "link.parquet"))
  expect_true(all(c(10000001, 10000002) %in% demo2$UMCReportId))
  expect_true(all(c(10000001, 10000002) %in% drug2$UMCReportId))
  expect_true(all(c(8, 9) %in% link2$Drug_Id))
  unlink(tmp_folder, recursive = TRUE)
})

test_that("tb_screen_main_parquet and tb_screen_sub_parquet skip existing tables and overwrite_existing_tables works", {
  tmp_folder <- tempdir()

  set_recycler_setting <-
    function(setting_name = "1", tmp_folder){
      path_base <<- paste0(tmp_folder, "/tb_vigibase_recycler_main", setting_name, "/")
      path_sub  <<- paste0(tmp_folder, "/tb_vigibase_recycler_sub", setting_name, "/")
      dir.create(path_base, showWarnings = FALSE)
      dir.create(path_sub, showWarnings = FALSE)

      # Create text files
      create_ex_main_txt(path_base)
      create_ex_sub_txt(path_sub)

      # Create example parquet tables for tests
      create_ex_main_pq(path_base)
      create_ex_sub_pq(path_sub)
    }

  # Case 1: ind.parquet is missing

  set_recycler_setting("1", tmp_folder)

  file.remove(paste0(path_base, "ind.parquet"))

    expect_message(
      main_tables <-
        tb_screen_main_parquet(path_base),
      "fol.*(?!ind)",
      perl = TRUE
    )

  expect_false("ind.parquet" %in% main_tables)
  expect_true("demo.parquet" %in% main_tables)
  expect_true("drug.parquet" %in% main_tables)
  expect_true("adr.parquet" %in% main_tables)
  expect_true("link.parquet" %in% main_tables)
  expect_snapshot({
    options(cli.progress_show_after = 0)
    options(cli.progress_clear = FALSE)
    tb_vigibase(
      path_base = path_base,
      path_sub = path_sub,
      overwrite_existing_tables = FALSE,
      force = TRUE
    )
  },
  transform =
    function(chr_line)
      stringr::str_replace(
        chr_line,
        "(?>=\\d{1,3}\\%\\s| ).*(?= \\|)",
        " percent, seconds"
      )
  )

  # Case 2: link.parquet and ind.parquet are missing

  set_recycler_setting("2", tmp_folder)

  file.remove(paste0(path_base, "link.parquet"))
  file.remove(paste0(path_base, "ind.parquet"))
  expect_message(
    main_tables <-
      tb_screen_main_parquet(path_base),
    "fol.*(?!link)",
    perl = TRUE
  )

  expect_false("link.parquet" %in% main_tables)
  expect_false("ind.parquet" %in% main_tables)
  expect_true("demo.parquet" %in% main_tables)
  expect_true("drug.parquet" %in% main_tables)
  expect_true("adr.parquet" %in% main_tables)
  expect_snapshot({
    options(cli.progress_show_after = 0)
    options(cli.progress_clear = FALSE)
    tb_vigibase(
      path_base = path_base,
      path_sub = path_sub,
      overwrite_existing_tables = FALSE,
      force = TRUE
    )
  },
  transform =
    function(chr_line)
      stringr::str_replace(
        chr_line,
        "(?>=\\d{1,3}\\%\\s| ).*(?= \\|)",
        " percent, seconds"
      )
  )

  # Case 3: adr.parquet, link.parquet and ind.parquet are missing

  set_recycler_setting("3", tmp_folder)

  initial_adr_table <-
    arrow::read_parquet(paste0(path_base, "adr.parquet"),
                        mmap = FALSE)

  initial_demo_table <-
    arrow::read_parquet(paste0(path_base, "demo.parquet"),
                        mmap = FALSE)

  file.remove(paste0(path_base, "adr.parquet"))
  file.remove(paste0(path_base, "link.parquet"))
  file.remove(paste0(path_base, "ind.parquet"))
  expect_message(
    main_tables <- tb_screen_main_parquet(path_base),
    "fol.*(?!adr)",
    perl = TRUE
  )

  expect_false("adr.parquet" %in% main_tables)
  expect_false("link.parquet" %in% main_tables)
  expect_false("ind.parquet" %in% main_tables)
  expect_true("demo.parquet" %in% main_tables)
  expect_true("drug.parquet" %in% main_tables)
  expect_snapshot({
    options(cli.progress_show_after = 0)
    options(cli.progress_clear = FALSE)
    tb_vigibase(
      path_base = path_base,
      path_sub = path_sub,
      overwrite_existing_tables = FALSE,
      rm_suspdup = TRUE,
      force = TRUE
    )
  },
  transform =
    function(chr_line)
      stringr::str_replace(
        chr_line,
        "(?>=\\d{1,3}\\%\\s| ).*(?= \\|)",
        " percent, seconds"
      )
  )

  # since rm_suspdup is TRUE, new adr should be different from
  # that created with create_ex_main_pq()

  new_adr_table <-
    arrow::read_parquet(paste0(path_base, "adr.parquet"),
                        mmap = FALSE)

  # duplicates in initial_adr
  expect_true(all(c(10000001, 10000002) %in% initial_adr_table$UMCReportId))

  # removed in new adr
  expect_false(10000002 %in% new_adr_table$UMCReportId)

  # other cases still here
  expect_true(10000001 %in% new_adr_table$UMCReportId)

  # whereas unchanged tables still have duplicates
  new_demo_table <- arrow::read_parquet(paste0(path_base, "demo.parquet"))

  # this might look a bit strange, but this is more a control
  # of tb_vigibase behavior, rather than an intended purpose
  # which would suggest the user turned rm_suspdup TRUE
  # only on the second run...
  # here, we mostly say that previous tables are unchanged.
  # and new ones are
  expect_equal(new_demo_table, initial_demo_table)

  # Case 4: drug.parquet, adr.parquet, link.parquet and ind.parquet are missing

  set_recycler_setting("4", tmp_folder)

  file.remove(paste0(path_base, "drug.parquet"))
  file.remove(paste0(path_base, "adr.parquet"))
  file.remove(paste0(path_base, "link.parquet"))
  file.remove(paste0(path_base, "ind.parquet"))

  expect_message(
    main_tables <- tb_screen_main_parquet(path_base),
    "fol.*(?!drug)",
    perl = TRUE
  )

  expect_false("drug.parquet" %in% main_tables)
  expect_false("adr.parquet" %in% main_tables)
  expect_false("link.parquet" %in% main_tables)
  expect_false("ind.parquet" %in% main_tables)
  expect_true("demo.parquet" %in% main_tables)
  expect_snapshot({
    options(cli.progress_show_after = 0)
    options(cli.progress_clear = FALSE)
    tb_vigibase(
      path_base = path_base,
      path_sub = path_sub,
      overwrite_existing_tables = FALSE,
      force = TRUE
    )
  },
  transform =
    function(chr_line)
      stringr::str_replace(
        chr_line,
        "(?>=\\d{1,3}\\%\\s| ).*(?= \\|)",
        " percent, seconds"
      )
  )

  # Also test subsidiary tables (should find all)

  set_recycler_setting("5", tmp_folder)

  expect_message(
    sub_tables <- tb_screen_sub_parquet(path_sub),
    "Subsidiary.*found"
  )

  expect_true("AgeGroup.parquet" %in% sub_tables)

  # if any missing subsidiary, tables are rebuilt in tb_vigibase

  file.remove(paste0(path_sub, "AgeGroup.parquet"))

  expect_invisible(
    sub_tables <- tb_screen_sub_parquet(path_sub)
  )

  expect_false("AgeGroup.parquet" %in% sub_tables)

  expect_snapshot({
    options(cli.progress_show_after = 0)
    options(cli.progress_clear = FALSE)
    tb_vigibase(
      path_base = path_base,
      path_sub = path_sub,
      overwrite_existing_tables = FALSE,
      force = TRUE
    )
  },
  transform =
    function(chr_line)
      stringr::str_replace(
        chr_line,
        "(?>=\\d{1,3}\\%\\s| ).*(?= \\|)",
        " percent, seconds"
      )
  )

  # Case overwrite_existing_tables = TRUE with all tables present

  set_recycler_setting("6", tmp_folder)

  expect_snapshot({
    options(cli.progress_show_after = 0)
    options(cli.progress_clear = FALSE)
    tb_vigibase(
      path_base = path_base,
      path_sub = path_sub,
      overwrite_existing_tables = TRUE,
      force = TRUE
    )
  },
  transform =
    function(chr_line)
      stringr::str_replace(
        chr_line,
        "(?>=\\d{1,3}\\%\\s| ).*(?= \\|)",
        " percent, seconds"
      )
  )

  # test with rm_suspdup on FALSE, overwrite_existing_tables FALSE
  # should not remove suspected duplicates

  set_recycler_setting("7", tmp_folder)

  file.remove(paste0(path_base, "drug.parquet"))

  expect_snapshot({
    options(cli.progress_show_after = 0)
    options(cli.progress_clear = FALSE)
    tb_vigibase(
      path_base = path_base,
      path_sub = path_sub,
      rm_suspdup = FALSE,
      overwrite_existing_tables = FALSE,
      force = TRUE
    )
  },
  transform =
    function(chr_line)
      stringr::str_replace(
        chr_line,
        "(?>=\\d{1,3}\\%\\s| ).*(?= \\|)",
        " percent, seconds"
      )
  )

  demo <- arrow::read_parquet(paste0(path_base, "demo.parquet"))
  drug <- arrow::read_parquet(paste0(path_base, "drug.parquet"))
  link <- arrow::read_parquet(paste0(path_base, "link.parquet"))

  expect_true(10000001 %in% demo$UMCReportId)
  expect_true(10000002 %in% demo$UMCReportId) # duplicate

  expect_true(10000001 %in% drug$UMCReportId)
  expect_true(10000002 %in% drug$UMCReportId) # duplicate

  # For link, check that both Drug_Id 8 and 9 remain
  expect_true(all(link$Drug_Id %in% c(8, 9)))


  unlink(tmp_folder, recursive = TRUE)
})
