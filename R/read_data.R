read_data <- function(dir, pattern) {
  stopifnot(dir.exists(dir))
  stopifnot(pattern %in% c("PlayerByGame", "PlayerTotals", "TeamByGame", "TeamTotals"))
  files <- list.files(dir, pattern, full.names = TRUE)
  purrr::map_dfr(files, readr::read_csv, col_types = readr::cols(.default = "c"), name_repair = "unique_quiet", .id = "year") |>
    dplyr::mutate(
      year = as.numeric(year) + 2018
    )
}

read_metric_def <- function(dir) {
  path <- paste0(dir, "/Metric Definitions.xlsx")
  readxl::read_xlsx(path)
}
