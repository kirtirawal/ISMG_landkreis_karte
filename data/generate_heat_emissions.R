library(dplyr)
library(tidyr)

set.seed(42)

PROJECT_ROOT <- "C:/Users/Lenovo/Desktop/HiWi/App/landkreis_dashboard_experimental"

districts <- tibble::tibble(
  district            = c("Magdeburg", "Halle", "Dessau-Roßlau",
                          "Stendal",   "Harz"),
  population          = c(235000, 240000, 78000, 108000, 210000),
  building_density    = c(1250,   1320,   480,   180,    95),
  green_space_pct     = c(18,     15,     32,    52,     68),
  industrial_heat_pct = c(22,     28,     14,    6,      4),
  t_mean              = c(12.0,   12.2,   10.8,  10.0,   8.8),
  t_amp               = c(11.0,   11.2,   10.8,  10.5,   10.0),
  heat_base           = c(4200,   4400,   1400,  950,    1650)
)

periods <- expand.grid(year = c(2023, 2024), month = 1:12)
periods <- periods[!(periods$year == 2024 & periods$month > 8), ]

season_sine <- function(m) sin(2 * pi * (m - 4) / 12)

heat_data <- tidyr::crossing(districts, periods)

heat_data <- heat_data %>%
  dplyr::mutate(
    season_sin        = season_sine(month),
    year_bump         = ifelse(year == 2024, 0.8, 0),
    temperature_c     = t_mean + t_amp * season_sin + year_bump,
    heat_factor       = 0.85 + 0.70 * pmax(0, season_sin),
    heat_emission_mwh = heat_base * heat_factor,
    cooling_demand_index = pmin(100, pmax(0, (temperature_c - 15) * 9)),
    co2_tonnes        = heat_emission_mwh * 0.18,
    heat_risk_score   = pmin(100, pmax(0,
                                       100 * (
                                         0.60 * (temperature_c / 24) +
                                           0.15 * (building_density / 1400) +
                                           0.15 * ((100 - green_space_pct) / 100) +
                                           0.10 * (industrial_heat_pct / 30)
                                       )
    ))
  ) %>%
  dplyr::select(district, year, month, temperature_c, heat_emission_mwh,
                cooling_demand_index, co2_tonnes, population, building_density,
                green_space_pct, industrial_heat_pct, heat_risk_score) %>%
  dplyr::arrange(district, year, month) %>%
  dplyr::mutate(
    temperature_c        = round(temperature_c, 1),
    heat_emission_mwh    = round(heat_emission_mwh, 0),
    cooling_demand_index = round(cooling_demand_index, 0),
    co2_tonnes           = round(co2_tonnes, 1),
    heat_risk_score      = round(heat_risk_score, 1)
  )

out_dir  <- file.path(PROJECT_ROOT, "data")
out_file <- file.path(out_dir, "heat_emissions.csv")

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

write.csv(heat_data, out_file,
          row.names = FALSE, fileEncoding = "UTF-8")

cat("✅ Wrote:", out_file, "\n")
cat("   Exists:", file.exists(out_file), "\n")