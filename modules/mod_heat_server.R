# ============================================================
# Urban Heat Emissions — Server
# ============================================================

mod_heat_server <- function(id, is_dark = reactive(FALSE)) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # ------------------------------------------------------------------
    # DATA LOADING
    # ------------------------------------------------------------------
    heat_data <- local({
      csv_path <- "data/heat_emissions.csv"
      
      if (!file.exists(csv_path)) {
        stop(
          "heat_emissions.csv not found at ", csv_path,
          ". Run data/generate_heat_emissions.R first."
        )
      }
      
      d <- read.csv(csv_path, fileEncoding = "UTF-8", stringsAsFactors = FALSE)
      
      d$district <- factor(
        d$district,
        levels = c("Halle", "Magdeburg", "Dessau-Roßlau", "Stendal", "Harz")
      )
      
      d$month_label <- factor(
        month.abb[d$month],
        levels = month.abb
      )
      
      d$period <- sprintf("%d-%02d", d$year, d$month)
      
      d
    })
    
    # ------------------------------------------------------------------
    # LANGUAGE
    # ------------------------------------------------------------------
    lang <- reactive({ input$lang %||% "de" })
    
    # ------------------------------------------------------------------
    # THEME (dark-mode aware)
    # ------------------------------------------------------------------
    th <- reactive({
      dark <- isTRUE(is_dark())
      list(
        bg     = if (dark) "#1f2937" else "#ffffff",
        bg2    = if (dark) "#151d2b" else "#fafbff",
        txt    = if (dark) "#e2e8f0" else "#1a3a5c",
        muted  = if (dark) "#64748b" else "#94a3b8",
        grid   = if (dark) "#334155" else "#e9ecef",
        tt_bg  = if (dark) "#0f172a" else "#ffffff",
        tt_txt = if (dark) "#e2e8f0" else "#1a3a5c"
      )
    })
    
    base_theme <- reactive({
      t <- th()
      ggplot2::theme_minimal(base_size = 11) +
        ggplot2::theme(
          plot.background   = ggplot2::element_rect(fill = t$bg, color = NA),
          panel.background  = ggplot2::element_rect(fill = t$bg, color = NA),
          panel.grid.major  = ggplot2::element_line(color = t$grid, linewidth = 0.4),
          panel.grid.minor  = ggplot2::element_blank(),
          axis.text         = ggplot2::element_text(color = t$txt),
          axis.title        = ggplot2::element_text(color = t$txt, face = "bold", size = 10),
          plot.title        = ggplot2::element_text(color = t$txt, face = "bold", size = 12),
          plot.subtitle     = ggplot2::element_text(color = t$muted, size = 9),
          legend.background = ggplot2::element_rect(fill = t$bg, color = NA),
          legend.text       = ggplot2::element_text(color = t$txt, size = 9),
          legend.title      = ggplot2::element_text(color = t$txt, size = 9)
        )
    })
    
    tt_css <- reactive({
      t <- th()
      paste0(
        "background-color:", t$tt_bg,
        ";color:", t$tt_txt,
        ";border:1.5px solid #ccc;border-radius:8px;",
        "padding:10px 14px;font-family:sans-serif;font-size:13px;",
        "box-shadow:0 4px 16px rgba(0,0,0,0.18);min-width:140px;"
      )
    })
    
    girafe_opts <- function() list(
      ggiraph::opts_hover(css = "stroke-width:1.5;cursor:pointer;"),
      ggiraph::opts_tooltip(
        css            = tt_css(),
        use_fill       = FALSE,
        use_cursor_pos = FALSE,
        offx = 10, offy = -40,
        delay_mouseover = 0, delay_mouseout = 800
      ),
      ggiraph::opts_toolbar(saveaspng = FALSE),
      ggiraph::opts_sizing(rescale = TRUE)
    )
    
    # ==================================================================
    # PAGE 1 — OVERVIEW
    # ==================================================================
    
    # ------------------------------------------------------------------
    # P1 — Ranked bar: peak heat risk per district
    # ------------------------------------------------------------------
    output$p1_ranked <- ggiraph::renderGirafe({
      d <- heat_data
      
      # Peak risk per district (over the whole 20-month window)
      peaks <- d |>
        dplyr::group_by(district) |>
        dplyr::slice_max(heat_risk_score, n = 1, with_ties = FALSE) |>
        dplyr::ungroup() |>
        dplyr::arrange(heat_risk_score)
      
      peaks$district <- factor(peaks$district, levels = peaks$district)
      
      # Warm palette keyed to risk magnitude
      fill_pal <- grDevices::colorRampPalette(
        c("#fbbf24", "#f97316", "#dc2626", "#7c2d12")
      )(nrow(peaks))
      peaks$bar_col <- fill_pal
      
      gg <- ggplot2::ggplot(
        peaks,
        ggplot2::aes(x = heat_risk_score, y = district)
      ) +
        ggplot2::geom_col(
          ggplot2::aes(fill = bar_col),
          width = 0.62
        ) +
        ggiraph::geom_text_interactive(
          ggplot2::aes(
            label = round(heat_risk_score, 1),
            tooltip = paste0(
              "<b>", district, "</b><br>",
              "Spitzenrisiko: ", round(heat_risk_score, 1), "<br>",
              "Monat: ", month_label[which.max(heat_risk_score)],
              " ", year[which.max(heat_risk_score)]
            )
          ),
          hjust = -0.18,
          size = 3.4,
          color = th()$txt
        ) +
        ggplot2::scale_fill_identity() +
        ggplot2::scale_x_continuous(
          limits = c(0, max(peaks$heat_risk_score) * 1.12),
          expand = ggplot2::expansion(mult = c(0, 0))
        ) +
        base_theme() +
        ggplot2::theme(
          panel.grid.major.y = ggplot2::element_blank(),
          legend.position    = "none"
        ) +
        ggplot2::labs(
          title    = NULL,
          subtitle = NULL,
          x = NULL, y = NULL
        )
      
      ggiraph::girafe(
        ggobj      = gg,
        width_svg  = 8,
        height_svg = 4,
        options    = girafe_opts()
      )
    })
    # ------------------------------------------------------------------
    # P1 — Ridge plot: distribution of heat risk per district
    # ------------------------------------------------------------------
    output$p1_ridge <- renderPlot({
      d <- heat_data
      
      # Same order as p1_ranked (highest risk at top)
      d$district <- factor(
        d$district,
        levels = c("Harz", "Stendal", "Dessau-Roßlau", "Magdeburg", "Halle")
      )
      
      fill_map <- c(
        "Halle"          = "#7c2d12",
        "Magdeburg"      = "#dc2626",
        "Dessau-Roßlau"  = "#f97316",
        "Stendal"        = "#f59e0b",
        "Harz"           = "#fbbf24"
      )
      
      gg <- ggplot2::ggplot(
        d,
        ggplot2::aes(
          x    = heat_risk_score,
          y    = district,
          fill = district
        )
      ) +
        ggridges::geom_density_ridges(
          alpha           = 0.78,
          scale           = 1.4,
          rel_min_height  = 0.02,
          color           = "white",
          linewidth       = 0.5
        ) +
        ggplot2::scale_fill_manual(values = fill_map) +
        ggplot2::scale_x_continuous(
          limits = c(0, 100),
          breaks = seq(0, 100, 25),
          expand = ggplot2::expansion(mult = c(0.02, 0.05))
        ) +
        base_theme() +
        ggplot2::theme(
          legend.position    = "none",
          panel.grid.major.y = ggplot2::element_blank(),
          axis.text.y        = ggplot2::element_text(size = 10, face = "bold")
        ) +
        ggplot2::labs(x = NULL, y = NULL)
      
      print(gg)
    }, res = 110, bg = "transparent")
    # ------------------------------------------------------------------
    # P1 — Small-multiple sparklines: seasonal temperature per district
    # ------------------------------------------------------------------
    output$p1_sparklines <- renderPlot({
      d <- heat_data
      
      # Build a proper date column for the x-axis
      d$date <- as.Date(sprintf("%d-%02d-01", d$year, d$month))
      
      # Keep the same district order as the other P1 charts
      d$district <- factor(
        d$district,
        levels = c("Halle", "Magdeburg", "Dessau-Roßlau", "Stendal", "Harz")
      )
      
      # Shared fill colours for consistency with p1_ranked / p1_ridge
      fill_map <- c(
        "Halle"         = "#7c2d12",
        "Magdeburg"     = "#dc2626",
        "Dessau-Roßlau" = "#f97316",
        "Stendal"       = "#f59e0b",
        "Harz"          = "#fbbf24"
      )
      
      gg <- ggplot2::ggplot(
        d,
        ggplot2::aes(x = date, y = temperature_c, color = district)
      ) +
        # Soft area underneath so each panel has weight
        ggplot2::geom_area(
          ggplot2::aes(fill = district),
          alpha = 0.14,
          show.legend = FALSE
        ) +
        ggplot2::geom_line(linewidth = 0.9, show.legend = FALSE) +
        ggplot2::geom_point(size = 1.0, show.legend = FALSE) +
        ggplot2::scale_color_manual(values = fill_map) +
        ggplot2::scale_fill_manual(values = fill_map) +
        # Shared y-axis so panels are directly comparable
        ggplot2::scale_y_continuous(
          limits = c(-2, 26),
          breaks = c(0, 10, 20)
        ) +
        ggplot2::scale_x_date(
          date_breaks = "6 months",
          date_labels = "%b\n%Y"
        ) +
        ggplot2::facet_wrap(
          ~ district,
          ncol = 5,
          strip.position = "top"
        ) +
        base_theme() +
        ggplot2::theme(
          panel.grid.minor  = ggplot2::element_blank(),
          panel.grid.major.x = ggplot2::element_blank(),
          strip.text        = ggplot2::element_text(
            size = 9, face = "bold", color = th()$txt),
          strip.background  = ggplot2::element_rect(
            fill = th()$bg2, color = NA),
          axis.text.x       = ggplot2::element_text(size = 8),
          axis.text.y       = ggplot2::element_text(size = 8),
          panel.spacing     = ggplot2::unit(0.9, "lines")
        ) +
        ggplot2::labs(x = NULL, y = NULL)
      
      print(gg)
    }, res = 110, bg = "transparent")
    # ==================================================================
    # PAGE 2 — HOTSPOTS
    # ==================================================================
    
    # ------------------------------------------------------------------
    # P2 — Heatmap: district × month, coloured by heat risk score
    # ------------------------------------------------------------------
    output$p2_heatmap <- ggiraph::renderGirafe({
      d <- heat_data
      
      # Order rows north-to-south (matches the spatial story)
      d$district <- factor(
        d$district,
        levels = rev(c("Halle", "Magdeburg", "Dessau-Roßlau", "Stendal", "Harz"))
      )
      
      # Order columns chronologically
      d$period <- factor(
        sprintf("%d-%02d", d$year, d$month),
        levels = sprintf("%d-%02d",
                         rep(c(2023, 2024), c(12, 8)),
                         c(1:12, 1:8))
      )
      
      gg <- ggplot2::ggplot(
        d,
        ggplot2::aes(x = period, y = district, fill = heat_risk_score)
      ) +
        ggiraph::geom_tile_interactive(
          ggplot2::aes(
            tooltip = paste0(
              "<b>", district, "</b><br>",
              month.abb[month], " ", year, "<br>",
              "Risiko: ", round(heat_risk_score, 1), "<br>",
              "Temperatur: ", round(temperature_c, 1), " °C"
            ),
            data_id = paste(district, period)
          ),
          color = th()$bg,
          linewidth = 0.5
        ) +
        ggplot2::scale_fill_gradientn(
          colours = c("#fef3c7", "#fbbf24", "#f97316", "#dc2626", "#7c2d12"),
          limits  = c(0, 100),
          breaks  = c(0, 25, 50, 75, 100),
          name    = "Risiko"
        ) +
        ggplot2::scale_x_discrete(expand = c(0, 0)) +
        ggplot2::scale_y_discrete(expand = c(0, 0)) +
        base_theme() +
        ggplot2::theme(
          panel.grid       = ggplot2::element_blank(),
          axis.text.x      = ggplot2::element_text(angle = 45, hjust = 1, size = 8),
          axis.text.y      = ggplot2::element_text(face = "bold", size = 10),
          legend.position  = "right",
          legend.key.height = ggplot2::unit(1.2, "cm")
        ) +
        ggplot2::labs(x = NULL, y = NULL)
      
      ggiraph::girafe(
        ggobj      = gg,
        width_svg  = 11,
        height_svg = 4.5,
        options    = girafe_opts()
      )
    })
    # ------------------------------------------------------------------
    # P2 — Bubble: building density vs peak heat risk
    # ------------------------------------------------------------------
    output$p2_bubble <- ggiraph::renderGirafe({
      d <- heat_data
      
      # One row per district: peak risk (for the risk axis) and static
      # structural variables (density, green space, population)
      peaks <- d |>
        dplyr::group_by(district) |>
        dplyr::slice_max(heat_risk_score, n = 1, with_ties = FALSE) |>
        dplyr::ungroup()
      
      # Colour ramp for green space: amber (low) → teal (high)
      gs_min <- min(peaks$green_space_pct)
      gs_max <- max(peaks$green_space_pct)
      peaks$green_col <- grDevices::colorRampPalette(
        c("#f59e0b", "#a3e635", "#10b981", "#0d9488")
      )(nrow(peaks))[rank(peaks$green_space_pct)]
      
      gg <- ggplot2::ggplot(
        peaks,
        ggplot2::aes(
          x = building_density,
          y = heat_risk_score
        )
      ) +
        # Reference line at extreme risk
        ggplot2::geom_hline(
          yintercept = 75,
          linetype   = "dashed",
          color      = "#dc2626",
          alpha      = 0.5,
          linewidth  = 0.6
        ) +
        ggiraph::geom_point_interactive(
          ggplot2::aes(
            size    = population / 1000,
            fill    = green_col,
            tooltip = paste0(
              "<b>", district, "</b><br>",
              "Bev\u00f6lkerung: ",
              format(population, big.mark = "."), "<br>",
              "Dichte: ", building_density, " /km\u00b2<br>",
              "Gr\u00fcnfl\u00e4chen: ", green_space_pct, " %<br>",
              "Spitzenrisiko: ", round(heat_risk_score, 1)
            ),
            data_id = district
          ),
          shape = 21,
          color = "white",
          stroke = 1.5,
          alpha = 0.92
        ) +
        ggiraph::geom_text_interactive(
          ggplot2::aes(
            label   = district,
            tooltip = district,
            data_id = district
          ),
          vjust = -2.4,
          size  = 3.2,
          fontface = "bold",
          color = th()$txt
        ) +
        ggplot2::scale_fill_identity() +
        ggplot2::scale_size_continuous(
          range  = c(8, 26),
          breaks = c(100, 200, 250),
          labels = function(x) paste0(x, "k"),
          name   = "Bev\u00f6lkerung"
        ) +
        ggplot2::scale_x_continuous(
          labels = scales::comma,
          limits = c(0, max(peaks$building_density) * 1.15)
        ) +
        ggplot2::scale_y_continuous(
          limits = c(0, 100),
          breaks = seq(0, 100, 25)
        ) +
        base_theme() +
        ggplot2::theme(
          legend.position = "right"
        ) +
        ggplot2::labs(
          x = "Geb\u00e4udedichte (Einwohner/km\u00b2)",
          y = "Spitzenrisiko (0\u2013100)",
          size = "Bev\u00f6lkerung"
        )
      
      ggiraph::girafe(
        ggobj      = gg,
        width_svg  = 9,
        height_svg = 4.5,
        options    = girafe_opts()
      )
    })
  })
}