library(purrr)

funs <- list.files("R", full.names = TRUE)
walk(funs, source)

email <- Sys.getenv("drive_email")
url <- Sys.getenv("drive_url")
data_dir <- "data"

if (!dir.exists(dir)) {
  dir.create(dir)
}

download_data(email, url, data_dir)
