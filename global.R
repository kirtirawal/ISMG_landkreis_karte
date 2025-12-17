# ---- Load libraries ----
library(shiny)
library(shinyWidgets)
library(sf)
library(dplyr)
library(ggplot2)
library(ggiraph)
library(glue)
library(readxl)
library(tidyverse)
library(giscoR)
library(janitor)
library(bslib)

# ---- Load Data ----
# Use relative paths for deployment
Daten_Landkreis_excel <- read_xlsx("data/Public Data with required columns.xlsx")

germany_districts <- gisco_get_nuts(
  year = "2021",
  nuts_level = 3,
  epsg = 3035,
  country = 'Germany'
) |> janitor::clean_names()

# Join map with data
Daten_Landkreis_joined <- germany_districts |>
  inner_join(Daten_Landkreis_excel, by = c("nuts_id" = "NUTS"))

# Convert data to long format
Daten_long <- Daten_Landkreis_joined |>
  pivot_longer(
    cols = matches("^\\d{4}"),
    names_to = "year_variable",
    values_to = "value"
  ) |>
  separate(
    year_variable,
    into = c("year", "variable"),
    sep = "\\r\\n|\\s",
    extra = "merge",
    fill = "right"
  )

