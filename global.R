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
# ---- Load UI helpers (dark mode CSS, toggle button) ----
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
# Read raw sheet – header is on row 4, data starts row 5
mort_raw <- read_xlsx(
  "data/23211-0001-Mortality_Stats_v4.xlsx",
  sheet     = "23211-0001",
  skip      = 3,          # skip the 3 empty rows before the header
  col_names = TRUE
)

# Drop fully empty rows (the blank separator row between header and data)
mort_raw <- mort_raw |> filter(!is.na(NUTS))

# Rename ambiguous "darunter" columns (duplicates) to unique names
# They appear after cols 6, 9, 15, 18 – give them the parent ICD prefix
names(mort_raw) <- make.unique(names(mort_raw), sep = "_sub")

# Keep only the key ID columns + ICD columns (drop "darunter_sub*")
mortality_data <- mort_raw |>
  select(
    NUTS, Jahr, Region, Geschlecht,
    # Insgesamt (total) and all named ICD chapters – drop the sub-cols
    matches("^(Insgesamt|ICD10_|COVID)")
  ) |>
  mutate(
    Jahr       = as.character(Jahr),
    Geschlecht = trimws(Geschlecht)
  )

# ============================================================
# 3.  TODESURSACHEN NACH BUNDESLAND  (2021-2024)
# ============================================================
# Add these lines to your existing global.R after section 2.

causes_data <- read.csv(
  "data/sterbefaelle_deutschland_2021_2024.csv",
  encoding       = "UTF-8",
  stringsAsFactors = FALSE
)

# Bundesland geometries (NUTS-1) via giscoR  -- same package you already use
germany_states <- gisco_get_nuts(
  year       = "2021",
  nuts_level = 1,          # <-- NUTS-1 = Bundeslaender
  epsg       = 3035,
  country    = "Germany"
) |>
  janitor::clean_names() |>
  # Build the ISO state code (DE-BW, DE-BY, …) from the NUTS_ID column
  # NUTS-1 IDs for Germany are "DE1" … "DEG" -- map to ISO codes
  mutate(state_code = dplyr::recode(nuts_id,
                                    "DE1"  = "DE-BW",   # Baden-Wuerttemberg
                                    "DE2"  = "DE-BY",   # Bayern
                                    "DE3"  = "DE-BE",   # Berlin
                                    "DE4"  = "DE-BB",   # Brandenburg
                                    "DE5"  = "DE-HB",   # Bremen
                                    "DE6"  = "DE-HH",   # Hamburg
                                    "DE7"  = "DE-HE",   # Hessen
                                    "DE8"  = "DE-MV",   # Mecklenburg-Vorpommern
                                    "DE9"  = "DE-NI",   # Niedersachsen
                                    "DEA"  = "DE-NW",   # Nordrhein-Westfalen
                                    "DEB"  = "DE-RP",   # Rheinland-Pfalz
                                    "DEC"  = "DE-SL",   # Saarland
                                    "DED"  = "DE-SN",   # Sachsen
                                    "DEE"  = "DE-ST",   # Sachsen-Anhalt
                                    "DEF"  = "DE-SH",   # Schleswig-Holstein
                                    "DEG"  = "DE-TH"    # Thueringen
  ))