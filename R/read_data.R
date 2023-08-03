library(purrr)
library(readr)

files_types <- c("PlayerByGame", "PlayerTotals", "TeamByGame", "TeamTotals")

player_by_game_files <- list.files("data", "PlayerByGame", full.names = TRUE)
player_by_game <- map_dfr(list)
