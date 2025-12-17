# Use the official R-base image (v4.3.0 or 4.3.1)
FROM rocker/r-ver:4.3.1

# Install system dependencies for spatial and visualization packages
# These are required for 'sf', 'giscoR', 'ggiraph', and 'tidyverse'
RUN apt-get update && apt-get install -y \
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory to match your app structure
WORKDIR /app

# Copy the entire repository into the container
COPY . /app

# Explicitly set the library path for stability
ENV R_LIBS_SITE=/usr/local/lib/R/site-library

# Install exactly the packages required by your global.R and modules
# 'sf' and 'giscoR' are critical for the mapping features
RUN R -e "options(error=quote(q(status=1))); \
    install.packages(c('shiny', 'shinyWidgets', 'sf', 'dplyr', 'ggplot2', \
                       'ggiraph', 'glue', 'readxl', 'tidyverse', 'giscoR', \
                       'janitor', 'bslib'), repos='https://cloud.r-project.org')"

# Expose the standard Shiny port
EXPOSE 3838

# Launch the app using the modules and data provided in the repo
CMD ["R", "-e", "shiny::runApp('/app', host='0.0.0.0', port=3838)"]