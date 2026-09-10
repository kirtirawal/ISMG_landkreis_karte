---
title: Landkreis Health Dashboard
emoji: chart_with_upwards_trend
colorFrom: blue
colorTo: green
sdk: docker
app_port: 3838
---


## Deploy with Docker

Build and run the dashboard locally:

```powershell
docker build -t landkreis-dashboard:local .
docker run --rm -p 3838:3838 landkreis-dashboard:local
```

Open `http://localhost:3838` in your browser. The container listens on port `3838`.

## Deploy to Hugging Face Spaces

Create a new Space at https://huggingface.co/new-space with:

* **SDK:** Docker
* **Visibility:** choose public or private
* **Hardware:** CPU Basic is sufficient to start

Then push this repository to the Space repository. Replace the placeholders with your Hugging Face account and Space name:

```powershell
git remote add huggingface https://huggingface.co/spaces/<HF_USERNAME>/<SPACE_NAME>
git add Dockerfile .dockerignore README.md global.R app.R modules python data www
git commit -m "Prepare Hugging Face Docker deployment"
git push huggingface HEAD:main
```

Hugging Face builds the `Dockerfile` automatically and exposes the app on port `3838`. Authentication is requested by Git when pushing; use a Hugging Face access token with write permission as the password.

---

## 🗺️ Project Overview / Projektübersicht

The "Interaktiver Landkreis-Explorer mit Zeitreihenanalyse" allows users to explore various indicators across Germany's administrative districts from 2006 to 2023. It provides:

* **Interactive Mapping:** A geographic visualization of selected parameters across Germany.
* **Time-Series Analysis:** Dynamic bar charts that update when a region is clicked on the map, showing trends over time for that specific district.
* **Customizable Visualization:** Options to switch between different color palettes for the map.

Der „Interaktive Landkreis-Explorer mit Zeitreihenanalyse“ ermöglicht es Nutzern, verschiedene Indikatoren der deutschen Verwaltungsbezirke von 2006 bis 2023 zu untersuchen. Er bietet:

* **Interaktive Karten:** Eine geografische Visualisierung ausgewählter Parameter in ganz Deutschland.
* **Zeitreihenanalyse:** Dynamische Balkendiagramme, die sich bei Klick auf eine Region in der Karte aktualisieren und Trends über die Zeit für diesen spezifischen Bezirk anzeigen.
* **Anpassbare Visualisierung:** Optionen zum Wechseln zwischen verschiedenen Farbpaletten für die Karte.

---

## 📊 Available Data Indicators / Verfügbare Datenindikatoren

The dashboard processes a wide range of public data, including:

* **Demographics:** Total population, median age, average age, and population development.
* **Vital Statistics:** Birth rates, death rates, and natural population balance.
* **Migration:** In-migration, out-migration, educational migration, and family migration patterns.
* **Socio-structural Indices:** Youth quotient, old-age quotient, and population density.

Das Dashboard verarbeitet eine Vielzahl öffentlicher Daten, darunter:

* **Demografie:** Gesamtbevölkerung, Medianalter, Durchschnittsalter und Bevölkerungsentwicklung.
* **Vitalstatistiken:** Geburtenraten, Sterberaten und natürlicher Bevölkerungssaldo.
* **Wanderung:** Zuzüge, Fortzüge, Bildungswanderung und Familienwanderungsmuster.
* **Soziostrukturelle Indizes:** Jugendquotient, Altenquotient und Einwohnerdichte.

---

## 📂 Repository Structure / Struktur des Repositorys

* `app.R`: Main entry point for the Shiny application.
* `global.R`: Handles library loading and data preprocessing.
* `modules/`: Modularized UI (`mod_main_ui.R`) and Server (`mod_main_server.R`) logic.
* `data/`: Source datasets in CSV and Excel formats.
* `www/`: Static assets like custom CSS and images.
* `app.R`: Haupteinstiegspunkt für die Shiny-Anwendung.
* `global.R`: Verwaltet das Laden von Bibliotheken und die Datenvorverarbeitung.
* `modules/`: Modularisierte Logik für UI (`mod_main_ui.R`) und Server (`mod_main_server.R`).
* `data/`: Quelldatensätze in den Formaten CSV und Excel.
* `www/`: Statische Inhalte wie benutzerdefiniertes CSS und Bilder.

---

## Releases & Versioning

<Here’s a clear, concise **documentation template** you can include in your project to explain how releases and the `VERSION` file work. This can be in a file called `RELEASE_GUIDE.md` or part of your `README.md`.

---

# Project Release Documentation

## 1. Purpose

This document explains how **project releases** are managed, how the **versioning system** works, and the workflow for creating a new release.

---

## 2. Versioning System

We use **date-based versioning**:

```
YYYY.MM.DD
```

* Represents the date the release became stable.
* Example: `2025.12.18`
* If multiple releases occur on the same day, a revision suffix is added:

  ```
  YYYY.MM.DD-r1
  YYYY.MM.DD-r2
  ```

**Key Points:**

* Version changes happen **only on the `main` branch**.
* Feature branches do **not** touch the version file.
* The version is stored in a single file: `VERSION`.

---

## 3. The `VERSION` file

* Location: project root
* Content: the current release version
* Example:

  ```
  2025.12.18
  ```
* This file is the authoritative source for the project version.
* All release-related operations (PR title, Git tag, release notes) refer to this version.

**Accessing the version in R:**

```r
project_version <- readLines("VERSION")
print(project_version)
```

---

## 4. Release Workflow

### Step 1: Create a feature branch

```bash
git checkout -b feature/<feature-name>
```

* All development work happens here.
* **Do not** update the `VERSION` file on this branch.

### Step 2: Merge to `main`

* After the feature is complete and stable, create a Pull Request (PR) to merge the branch into `main`.
* PR title format:

```
[YYYY.MM.DD] Short description
```

### Step 3: Update version

* On `main`, update `VERSION` to the release date (and revision if needed).
* Commit the change.

### Step 4: Tag the release

```bash
git tag vYYYY.MM.DD
git push origin vYYYY.MM.DD
```

### Step 5: Optional GitHub/GitLab release

* Go to **Releases** → **Create New Release**
* Use the same tag as the version
* Add release notes or changelog entries

---

## 5. Changelog (optional)

Maintain a simple `CHANGES.txt`:

```
2025.12.18
- Added VERSION file
- Updated dashboard filters

2025.11.30
- Initial working version
```

---

## 6. Guidelines for collaborators

* Only update the `VERSION` file on `main` during a release.
* Feature branches are **WIP** and do not touch the version.
* Use PR titles to indicate the intended release version.
* Tags and `VERSION` file must match.

---

This ensures anyone viewing the repo understands:

* How version numbers are assigned
* How releases are created
* How to read or use the project version

---

## Deploy to Hugging Face (Docker SDK)

The `Dockerfile` in the repo root is compatible with the **Docker SDK** of
Hugging Face Spaces. HF injects the listening port via the `PORT` environment
variable (default `7860`); the app picks it up automatically (local fallback: `3838`).

1. Create a new Space on https://huggingface.co/spaces and select **SDK: Docker**.
2. Push this repository to the Space:

   ```bash
   git remote add hf https://huggingface.co/spaces/<user>/<space-name>
   git push -u hf main
   ```

3. The Space builds automatically; the app starts on the port provided by HF.

**Test locally before pushing:**

```bash
docker build -t landkreis-dashboard:latest .
docker run -p 3838:3838 landkreis-dashboard:latest
# open http://localhost:3838
```

> Note: `global.R` downloads NUTS geometry (giscoR) at startup, so the
> container needs internet access when the app first loads (available on HF Spaces).

---
>