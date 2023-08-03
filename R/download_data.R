download_data <- function(email, url, dir) {
  googledrive::drive_auth(email)

  main_folder <- googledrive::drive_ls(url, pattern = "Season")
  data_files <- purrr::map_dfr(main_folder$id, drive_ls, pattern = "csv", .progress = TRUE) %>%
    dplyr::mutate(
      file = id,
      path = paste0("data/", name),
      overwrite = TRUE
    ) %>%
    dplyr::select(file, path, overwrite)
  purrr::pwalk(data_files, drive_download, .progress = TRUE)

  googledrive::drive_deauth()
}
