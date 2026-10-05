# ============================================================
# Navigation Helpers
# ============================================================

# ------------------------------------------------------------
# Overview Feature Card
# Used inside the "Überblick" tabs of Causes and LäKoSA modules
# ------------------------------------------------------------
overview_feature <- function(
    title,
    description,
    icon_name = "chart-column"
) {
  div(
    class = "overview-feature-card",
    
    div(
      class = "overview-feature-icon",
      icon(icon_name)
    ),
    
    tags$h3(title),
    
    tags$p(description)
  )
}