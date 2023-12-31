plot_squad_age_minutes <- function(team_name, season) {
  df <- player_by_game |>
    filter(teamName == team_name & year == season) |>
    group_by(Player) |>
    summarise(
      Age = max(Age),
      Min = sum(Min)
    ) |>
    filter(!(is.na(Age)) & Age > 0 & !(is.na(Min)))

  max_mins <- ceiling(team_totals$GM[team_totals$Team == team_name & team_totals$year == season] * 90 / 200) * 200
  
  mean_age <- round(weighted.mean(df$Age, df$Min), 1)
  
  plot <- ggplot(df, aes(x = Age, y = Min, label = Player)) +
    geom_rect(aes(xmin = 24, xmax = 29, ymin = 0, ymax = max_mins), alpha = 0.01, fill = league_colours[3]) +
    annotate("text", x = 20, y = max_mins / 2, label = "YOUTH", angle = 90, size = 125 / .pt, colour = league_colours[2], alpha = 0.2) +
    annotate("text", x = 26.5, y = max_mins / 2, label = "PEAK", angle = 90, size = 125 / .pt, colour = league_colours[2], alpha = 0.2) +
    annotate("text", x = 34.5, y = max_mins / 2, label = "EXPERIENCE", angle = 90, size = 125 / .pt, colour = league_colours[2], alpha = 0.2) +
    geom_point(colour = team_colours[[team_name]][2], fill = team_colours[[team_name]][1], shape = 21, size = 6.5 / .pt, stroke = 1.5 / .pt) +
    geom_text_repel(colour = league_colours[2], family = "Oswald", size = 25 / .pt, max.overlaps = 30) +
    scale_x_continuous(
      breaks = seq.int(from = 16, to = 40, by = 4),
      labels = seq.int(from = 16, to = 40, by = 4),
      limits = c(
        min(c(16, min(df$Age))),
        max(c(40, max(df$Age)))
      )
    ) +
    scale_y_continuous(
      breaks = seq.int(0, max_mins, length.out = 5),
      labels = number_format(big.mark = " ")
    ) +
    labs(
      title = paste(team_name, season, "season squad profile"),
      subtitle = paste("Average age weighted by minutes played:", mean_age, "years"),
      x = "Age",
      y = "Minutes played",
      caption = "@CanPLdata | #CCdata | #CanPL"
    ) +
    theme_canpl()
  
  path <- paste0("plots/", team_name, "_", season, "_season_squad_age_minutes.png")
  ggsave(path, plot, width = 2048, height = 2048, units = "px")
  add_logos(path, team_image_id)
}