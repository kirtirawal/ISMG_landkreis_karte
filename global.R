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
library(DT)
library(bsicons)
library(shinyjs)
library(bsicons)   # or replace bs_icon() with icon("circle-info") from Shinylibrary(ggridges)

# ---- Load UI helpers & Python scripts ----
source("global_additions.R")


# ============================================================
# 1.  EXISTING DATA  (Landkreis indicators)
# ============================================================
Daten_Landkreis_excel <- read_xlsx("data/Public Data with required columns.xlsx")

germany_districts <- gisco_get_nuts(
  year       = "2021",
  nuts_level = 3,
  epsg       = 3035,
  country    = "Germany"
) |> janitor::clean_names()

Daten_Landkreis_joined <- germany_districts |>
  inner_join(Daten_Landkreis_excel, by = c("nuts_id" = "NUTS"))

Daten_long <- Daten_Landkreis_joined |>
  pivot_longer(
    cols         = matches("^\\d{4}"),
    names_to     = "year_variable",
    values_to    = "value"
  ) |>
  separate(
    year_variable,
    into  = c("year", "variable"),
    sep   = "\\r\\n|\\s",
    extra = "merge",
    fill  = "right"
  )

# ============================================================
# 2.  MORTALITY DATA  (ICD-10 Sterbefallstatistik)
# ============================================================
mort_raw <- read_xlsx(
  "data/23211-0001-Mortality_Stats_v4.xlsx",
  sheet     = "23211-0001",
  skip      = 3,
  col_names = TRUE
)

mort_raw <- mort_raw |> filter(!is.na(NUTS))
names(mort_raw) <- make.unique(names(mort_raw), sep = "_sub")

mortality_data <- mort_raw |>
  select(
    NUTS, Jahr, Region, Geschlecht,
    matches("^(Insgesamt|ICD10_|COVID)")
  ) |>
  mutate(
    Jahr       = as.character(Jahr),
    Geschlecht = trimws(Geschlecht)
  )

# ============================================================
# 3.  TODESURSACHEN NACH BUNDESLAND  (2021-2024)
# ============================================================
causes_data <- read.csv(
  "data/sterbefaelle_deutschland_2021_2024.csv",
  encoding       = "UTF-8",
  stringsAsFactors = FALSE
)

germany_states <- gisco_get_nuts(
  year       = "2021",
  nuts_level = 1,
  epsg       = 3035,
  country    = "Germany"
) |>
  janitor::clean_names() |>
  mutate(state_code = dplyr::recode(nuts_id,
                                    "DE1"  = "DE-BW",
                                    "DE2"  = "DE-BY",
                                    "DE3"  = "DE-BE",
                                    "DE4"  = "DE-BB",
                                    "DE5"  = "DE-HB",
                                    "DE6"  = "DE-HH",
                                    "DE7"  = "DE-HE",
                                    "DE8"  = "DE-MV",
                                    "DE9"  = "DE-NI",
                                    "DEA"  = "DE-NW",
                                    "DEB"  = "DE-RP",
                                    "DEC"  = "DE-SL",
                                    "DED"  = "DE-SN",
                                    "DEE"  = "DE-ST",
                                    "DEF"  = "DE-SH",
                                    "DEG"  = "DE-TH"
  ))


#============================================================
#  4.  SYNTHETIC DATA (LaeKoSA Modul 2)
#============================================================
lakosa_data <-
  readxl::read_excel(
    "data/LaeKoSA_real_processed_300.xlsx",
    sheet = "processed_300"
  )

lakosa_dictionary <-
  readxl::read_excel(
    "data/LaeKoSA_real_processed_300.xlsx",
    sheet = "derived_dictionary"
  )
