# ==============================================================================
# Landkreis Health Dashboard
# Docker-Image fuer lokale Nutzung UND Hugging Face Spaces (Docker SDK).
#
# Layer-Reihenfolge ist bewusst gewaehlt (Cache-Optimierung):
#   1. System-Pakete  ->  2. Python-Abhaengigkeiten  ->  3. R-Pakete
#   4. Build-Validierung  ->  5. App-Code
#   => Code-Änderungen in der App benötigen nur noch das letzte (schnelle) Layer.
# ==============================================================================
FROM rocker/r-ver:4.3.1

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Berlin \
    # Deterministische Python-Runtime: verhindert, dass reticulate beim
    # Build/Laufzeit eine eigene Umgebung anlegt (uv-Bootstrap-Fehler)
    RETICULATE_PYTHON=/usr/bin/python3

# ------------------------------------------------------------------------------
# 1. System-Abhaengigkeiten (Spatial-Stack + Python-Basis)
# ------------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    git \
    python3 \
    python3-dev \
    python3-pip \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libcairo2-dev \
    libxt-dev \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# 2. Python-Abhaengigkeiten explizit via pip (deterministisch, keine
#    apt/PEP-Drift, reticulate findet die Module ohne Umgebungs-Bootstrap)
# ------------------------------------------------------------------------------
RUN python3 -m pip install --no-cache-dir pandas numpy plotly scikit-learn

# ------------------------------------------------------------------------------
# 3. R-Pakete (WICHTIG: vor dem App-Code kopieren installieren, damit dieses
#    Layer gecacht bleibt, solange die Paketliste unverändert ist)
# ------------------------------------------------------------------------------
RUN R -e "options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/jammy/latest'), \
             Ncpus = parallel::detectCores()); \
    pkgs <- c('shiny', 'shinyWidgets', 's2', 'sf', 'dplyr', 'ggplot2', 'ggiraph', \
              'glue', 'readxl', 'tidyverse', 'giscoR', 'janitor', 'bslib', \
              'reticulate', 'DT', 'bsicons', 'shinyjs'); \
    install.packages(pkgs); \
    # Validierung: Abbruch, falls etwas fehlt \
    installed <- rownames(installed.packages()); \
    missing <- setdiff(pkgs, installed); \
    if (length(missing) > 0) stop(paste('Installation fehlgeschlagen für:', paste(missing, collapse=', ')))"

# 4. Finaler Test-Check während des Builds (R-Pakete + Python-Module)
RUN R -e "library(sf); library(tidyverse); library(shiny); library(DT); library(bsicons); library(shinyjs); library(reticulate); py_config(); stopifnot(py_available(initialize = TRUE)); stopifnot(all(sapply(c('pandas', 'numpy', 'plotly', 'sklearn'), py_module_available)))"

# ------------------------------------------------------------------------------
# 5. App-Code (kleinestmoegliches Layer am Ende)
# ------------------------------------------------------------------------------
WORKDIR /app
COPY . /app

# Port: Hugging Face Spaces injiziert PORT (default 7860), lokaler Fallback 3838
ENV PORT=3838
EXPOSE 3838

HEALTHCHECK --interval=30s --timeout=5s --start-period=180s --retries=3 \
    CMD curl -fsS "http://127.0.0.1:${PORT}/" > /dev/null || exit 1

CMD ["R", "-e", "shiny::runApp('/app', host='0.0.0.0', port=as.integer(Sys.getenv('PORT', '3838')))"]