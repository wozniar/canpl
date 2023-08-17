library(shiny)
library(tidyverse)
library(gt)

funs <- list.files("R", full.names = TRUE)
walk(funs, source)

email <- Sys.getenv("DRIVE_EMAIL")
drive_url <- Sys.getenv("DRIVE_URL")
metric_def_url <- Sys.getenv("METRIC_DEF_URL")
dir <- "data"

# download_data(email, drive_url, dir)
# download_metric_def(email, metric_def_url, dir)

metric_def <- read_metric_def(dir)

team_totals <- read_data(dir, "TeamTotals") |>
  clean_cols()

team_by_game <- read_data(dir, "TeamByGame") |>
  clean_cols() |>
  mutate(
    across(GM, ~ as.numeric(.x)),
    across(c(Win, Draw, Loss), ~ as.logical(.x)),
    Date = as.Date(parse_date_time(Date, c("Ymd", "mdY"))),
    stage = case_when(
      Date <= as.Date("2019-07-01") ~ "2019 Spring season",
      Date <= as.Date("2019-10-19") ~ "2019 Fall season",
      Date == as.Date("2019-10-26") | Date == as.Date("2019-11-02") ~ "2019 Finals",
      Date <= as.Date("2020-09-06") ~ "2020 First stage",
      Date <= as.Date("2020-09-16") ~ "2020 Group stage",
      Date == as.Date("2020-09-19") ~ "2020 Final",
      Date <= as.Date("2021-11-16") ~ "2021 Regular season",
      Date <= as.Date("2021-11-21") ~ "2021 Semi-finals",
      Date == as.Date("2021-12-05") ~ "2021 Final",
      Date <= as.Date("2022-10-09") ~ "2022 Regular season",
      Date <= as.Date("2022-10-23") ~ "2022 Semi-finals",
      Date == as.Date("2022-10-30") ~ "2022 Final"
    )
  )

player_totals <- read_data(dir, "PlayerTotals") |>
  clean_cols()

ui <- fluidPage(
  titlePanel("Canadian Premier League"),
  fluidRow(
    column(3, selectInput("team", label = "Select team", choices = sort(unique(team_totals$Team)), selected = "Atlético Ottawa")),
    column(3, selectInput("season", label = "Select season", choices = sort(unique(team_totals$year)), selected = 2020)),
  ),
  tableOutput("table_001"),
  tableOutput("table_002")
)

server <- function(input, output, session) {
  season_sel <- reactive({
    team_totals |>
      filter(Team == input$team) |>
      distinct(year) |>
      pull(year)
  })
  observeEvent(season_sel(), {
    updateSelectInput(session, "season", choices = season_sel())
  })
  sel_team_image <- reactive({
    team_totals |>
      filter(Team == input$team) |>
      distinct(teamImageId) |>
      pull(teamImageId)
  })
  # output$team_image <- renderUI({
  #   tags$img(src = paste0("https://omo.akamai.opta.net/image.php?secure=true&h=omo.akamai.opta.net&sport=football&entity=team&description=badges&dimensions=150&id=", sel_team_image()))
  # })
  # output$player_image <- renderUI({
  #   tags$img(src = "https://omo.akamai.opta.net/image.php?secure=true&h=omo.akamai.opta.net&sport=football&entity=player&description=9xmhnv6im8h7c9e17oqvcx8gl&dimensions=40x60&id=5hylntpne6d7xwey2v9d9lg8a")
  # })
  output$table_001 <- renderTable({
    team_totals |>
      filter(Team == input$team & year == input$season)
  })
  output$table_002 <- renderTable({
    team_by_game |>
      filter(Team == input$team & year == input$season) |>
      group_by(Team) |>
      summarise(
        across(c(GM, Win, Draw, Loss), ~ sum(.x))
      ) |>
      ungroup()
  })
}

shinyApp(ui, server)
