download_data <- function(email, url, dir) {
  if (!dir.exists(dir)) {
    dir.create(dir)
  }
  googledrive::drive_auth(email)
  main_folder <- googledrive::drive_ls(url, pattern = "Season") |>
    dplyr::arrange(name)
  data_files <- purrr::map_dfr(main_folder$id, googledrive::drive_ls, pattern = "csv", .progress = TRUE) |>
    dplyr::mutate(
      file = id,
      path = paste0("data/", name),
      overwrite = TRUE
    ) |>
    dplyr::select(file, path, overwrite)
  purrr::pwalk(data_files, googledrive::drive_download, .progress = TRUE)
  googledrive::drive_deauth()
}

download_metric_def <- function(email, url, dir) {
  if (!dir.exists(dir)) {
    dir.create(dir)
  }
  path <- paste0(dir, "/Metric Definitions.xlsx")
  googledrive::drive_auth(email)
  googledrive::drive_download(url, path = path, overwrite = TRUE)
  googledrive::drive_deauth()
}
