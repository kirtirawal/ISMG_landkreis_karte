mod_main_server <- function(id, is_dark = reactive(FALSE)) {
  moduleServer(id, function(input, output, session) {
    
    ns <- session$ns
    
    # --- Dynamic Theme Helper ---
    curr_theme <- reactive({
      if (isTRUE(is_dark())) {
        list(
          bg          = "#1f2937",
          bg_panel    = "#151d2b",
          txt         = "#e2e8f0",
          grid        = "#334155",
          tooltip_bg  = "#0f172a",
          tooltip_txt = "#e2e8f0",
          border      = "#334155",
          na_fill     = "#374151"
        )
      } else {
        list(
          bg          = "#ffffff",
          bg_panel    = "#fafbff",
          txt         = "#1a3a5c",
          grid        = "#e9ecef",
          tooltip_bg  = "#ffffff",
          tooltip_txt = "#1a3a5c",
          border      = "#e2e8f0",
          na_fill     = "#e5e7eb"
        )
      }
    })
    
    # ── 1. Metric Value Box ──────────────────────────────────────────────────
    output$metric_val <- renderText({ "" })
    
    # ── 2. Filter data ───────────────────────────────────────────────────────
    map_data <- reactive({
      req(input$selected_param)
      Daten_long %>%
        filter(variable == input$selected_param) %>%
        mutate(
          value = ifelse(value == "k.A.", 0, value),
          value = suppressWarnings(as.numeric(value))
        )
    })
    
    # ── 3. Selected region ───────────────────────────────────────────────────
    selected_region <- reactive({
      if (!is.null(input$map_plot_selected) && nzchar(input$map_plot_selected)) {
        input$map_plot_selected
      } else {
        unique(map_data()$nuts_name)[1]
      }
    })
    
    # ── 4. Color palette ─────────────────────────────────────────────────────
    map_palette <- reactive({
      scale_fill_viridis_c(option = input$color_palette,
                           na.value = curr_theme()$na_fill)
    })
    
    # ── 5. Interactive Map ───────────────────────────────────────────────────
    output$map_plot <- renderGirafe({
      t          <- curr_theme()
      border_col <- if (isTRUE(is_dark())) "#4b5563" else "#ffffff"
      
      gg_map <- ggplot(map_data()) +
        geom_sf_interactive(
          aes(
            geometry = geometry,
            fill     = value,
            # Tooltip: styled exactly like Image 1 — bold name, Jahr, Wert
            tooltip  = paste0(
              "<span style='font-size:15px;font-weight:700;color:#1a1a1a;'>",
              nuts_name,
              "</span><br/>",
              "<span style='color:#555;font-size:12px;'>Jahr: </span>",
              "<span style='font-size:12px;'>", year, "</span><br/>",
              "<span style='color:#555;font-size:12px;'>Wert: </span>",
              "<span style='font-size:12px;font-weight:600;'>",
              round(value, 1),
              "</span>"
            ),
            data_id  = nuts_name
          ),
          color     = border_col,
          linewidth = 0.25
        ) +
        theme_void() +
        map_palette() +
        theme(
          plot.background   = element_rect(fill = t$bg,       color = NA),
          panel.background  = element_rect(fill = t$bg,       color = NA),
          legend.background = element_rect(fill = t$bg,       color = NA),
          legend.text       = element_text(color = t$txt,     size = 9),
          legend.title      = element_text(color = t$txt,     size = 9),
          plot.title        = element_text(color = t$txt,     size = 13,
                                           face = "bold",
                                           margin = margin(b = 8))
        ) +
        labs(fill = NULL, title = paste("Distribution:", input$selected_param))
      
      # Tooltip CSS: white card, border, shadow — matches Image 1 exactly
      tooltip_css <- paste0(
        "background-color:", t$tooltip_bg, ";",
        "color:", t$tooltip_txt, ";",
        "border:1.5px solid #cccccc;",
        "border-radius:8px;",
        "padding:10px 14px;",
        "font-family:sans-serif;",
        "font-size:13px;",
        "box-shadow:0 4px 16px rgba(0,0,0,0.18);",
        "min-width:160px;"
      )
      
      girafe(
        ggobj     = gg_map,
        width_svg = 10, height_svg = 8,
        options   = list(
          opts_hover(css = "stroke:#ff3b3b;stroke-width:2.5;cursor:pointer;"),
          opts_selection(type = "single",
                         css  = "stroke:#ff3b3b;stroke-width:2.5;"),
          # use_cursor_pos=FALSE anchors tooltip to the tapped region on mobile
          # offx/offy nudge it away from the finger so it stays visible
          opts_tooltip(
            css           = tooltip_css,
            use_fill      = FALSE,
            use_cursor_pos = FALSE,
            offx          = 10,
            offy          = -40,
            delay_mouseover = 0,
            delay_mouseout  = 1000    # keep visible 1 s after tap lifts
          ),
          opts_toolbar(saveaspng = FALSE),
          opts_sizing(rescale = TRUE)
        )
      )
    })
    
    # ── 6. Bar chart for selected region ─────────────────────────────────────
    output$bar_plot <- renderGirafe({
      t           <- curr_theme()
      region_name <- selected_region()
      bar_data    <- map_data() %>% filter(nuts_name == region_name)
      
      gg_bar <- ggplot(bar_data, aes(x = year, y = value, fill = value)) +
        geom_col_interactive(
          aes(tooltip = paste0(
            "<span style='font-size:14px;font-weight:700;'>", region_name, "</span><br/>",
            "<span style='color:#555;font-size:12px;'>Jahr: </span>",
            "<span style='font-size:12px;'>", year, "</span><br/>",
            "<span style='color:#555;font-size:12px;'>Wert: </span>",
            "<span style='font-size:12px;font-weight:600;'>", round(value, 1), "</span>"
          )),
          width = 0.7
        ) +
        scale_fill_viridis_c(option = input$color_palette) +
        theme_minimal(base_size = 11) +
        theme(
          plot.background  = element_rect(fill = t$bg,   color = NA),
          panel.background = element_rect(fill = t$bg,   color = NA),
          panel.grid.major = element_line(color = t$grid, linewidth = 0.5),
          panel.grid.minor = element_blank(),
          axis.text        = element_text(color = t$txt),
          axis.title       = element_text(color = t$txt, face = "bold"),
          plot.title       = element_text(color = t$txt, face = "bold", size = 12),
          legend.position  = "none"
        ) +
        labs(title = paste("Trend:", region_name), x = "Jahr", y = NULL)
      
      tooltip_css <- paste0(
        "background-color:", t$tooltip_bg, ";",
        "color:", t$tooltip_txt, ";",
        "border:1.5px solid #cccccc;",
        "border-radius:8px;",
        "padding:10px 14px;",
        "font-family:sans-serif;",
        "font-size:13px;",
        "box-shadow:0 4px 16px rgba(0,0,0,0.18);",
        "min-width:140px;"
      )
      
      girafe(
        ggobj     = gg_bar,
        width_svg = 8, height_svg = 10,
        options   = list(
          opts_hover(css = "fill:#ff3b3b;"),
          opts_tooltip(
            css            = tooltip_css,
            use_fill       = FALSE,
            use_cursor_pos = FALSE,
            offx           = 10,
            offy           = -40,
            delay_mouseover  = 0,
            delay_mouseout   = 1000
          ),
          opts_toolbar(saveaspng = FALSE)
        )
      )
    })
  })
}