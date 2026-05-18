mod_causes_server <- function(id, is_dark = reactive(FALSE)) {
  moduleServer(id, function(input, output, session) {
    
    ns <- session$ns
    
    # --- Dynamic Theme Helper ---
    ct <- reactive({
      if (isTRUE(is_dark())) {
        list(
          bg       = "#1f2937", txt = "#e2e8f0", grid = "#334155",
          na_fill  = "#374151", border = "#4b5563",
          caption  = "#94a3b8", subtitle = "#94a3b8",
          map_low  = "#1e3a8a", map_high  = "#93c5fd",
          bar_blue = "#60a5fa", bar_navy  = "#1d4ed8",
          de_line  = "#94a3b8", state_line = "#60a5fa",
          dashed   = "#6b7280",
          tooltip_bg  = "#0f172a", tooltip_txt = "#e2e8f0"
        )
      } else {
        list(
          bg       = "#ffffff", txt = "#1a3a5c", grid = "#e9ecef",
          na_fill  = "#e5e7eb", border = "#ffffff",
          caption  = "#666666", subtitle = "#556677",
          map_low  = "#dbeafe", map_high  = "#1e3a8a",
          bar_blue = "#94b8f0", bar_navy  = "#1e3a8a",
          de_line  = "#94a3b8", state_line = "#1e3a8a",
          dashed   = "#555555",
          tooltip_bg  = "#f8f9fa", tooltip_txt = "#1a3a5c"
        )
      }
    })
    
    tt_css <- reactive({
      t <- ct()
      paste0(
        "background-color:", t$tooltip_bg, ";color:", t$tooltip_txt, ";",
        "border:1px solid #e74c3c;border-radius:6px;padding:6px 10px;",
        "font-size:0.82rem;box-shadow:0 2px 8px rgba(0,0,0,0.25);"
      )
    })
    
    # Shared ggplot dark theme layer
    dm_theme <- reactive({
      t <- ct()
      list(
        theme(
          plot.background   = element_rect(fill = t$bg, color = NA),
          panel.background  = element_rect(fill = t$bg, color = NA),
          text              = element_text(color = t$txt),
          axis.text         = element_text(color = t$txt),
          axis.title        = element_text(color = t$txt),
          plot.title        = element_text(color = t$txt, size = 10, face = "bold"),
          plot.caption      = element_text(color = t$caption, size = 8),
          panel.grid.major  = element_line(color = t$grid, linewidth = 0.4),
          panel.grid.minor  = element_blank(),
          legend.background = element_rect(fill = t$bg, color = NA),
          legend.text       = element_text(color = t$txt),
          legend.title      = element_text(color = t$txt),
          strip.text        = element_text(color = t$txt)
        )
      )
    })
    
    
    # ── Constants ─────────────────────────────────────────────────────────────
    STATE_16 <- c("DE-BW","DE-BY","DE-BE","DE-BB","DE-HB","DE-HH","DE-HE",
                  "DE-MV","DE-NI","DE-NW","DE-RP","DE-SL","DE-SN","DE-ST",
                  "DE-SH","DE-TH")
    
    AVOIDABLE <- list(
      list(code = "F10-F19", label = "Substance Use\n(F10-F19)",     color = "#e74c3c"),
      list(code = "K70-K77", label = "Liver Disease\n(K70-K77)",     color = "#e67e22"),
      list(code = "J40-J47", label = "COPD\n(J40-J47)",              color = "#f39c12"),
      list(code = "E10-E14", label = "Diabetes\n(E10-E14)",          color = "#3498db"),
      list(code = "S00-T98", label = "Injuries &\nPoisoning\n(S00-T98)", color = "#9b59b6")
    )
    
    # ── Populate ICD dropdown ─────────────────────────────────────────────────
    observe({
      req(causes_data)
      chapters <- causes_data |>
        filter(!is.na(icd_code) & nzchar(icd_code)) |>
        filter(bundesland_code == "DE-BY", jahr == 2021) |>
        distinct(icd_code, icd_bezeichnung) |>
        arrange(icd_code)
      
      choices <- setNames(chapters$icd_bezeichnung, chapters$icd_bezeichnung)
      alle    <- "Alle Krankheiten und Folgen \u00e4u\u00dferer Ursachen"
      choices <- c(setNames(alle, alle), choices)
      
      updateSelectInput(session, "cv_icd", choices = choices, selected = choices[1])
    })
    
    # ── Selected state: pill click or default DE-ST ───────────────────────────
    selected_state <- reactiveVal("DE-ST")
    
    observeEvent(input$cv_state_click, {
      selected_state(input$cv_state_click)
      session$sendCustomMessage(ns("update_pills"), input$cv_state_click)
    })
    
    # ── Helper: state name from code ──────────────────────────────────────────
    state_name <- reactive({
      causes_data |>
        filter(bundesland_code == selected_state()) |>
        pull(region) |> unique() |> first()
    })
    
    # ── Metric label ──────────────────────────────────────────────────────────
    metric_lbl <- reactive({
      switch(input$cv_metric,
             "sterbefaelle"                     = "Deaths (absolute)",
             "sterbefaelle_je_100k"             = "Per 100,000 (crude)",
             "sterbefaelle_je_100k_altersstand" = "Per 100,000 (age-std.)",
             input$cv_metric)
    })
    
    # ── Base filter: top-level chapters, selected year ─────────────────────────
    base_data <- reactive({
      req(input$cv_year, input$cv_metric)
      yr <- as.integer(input$cv_year)
      
      # Top-level only = codes present in 2021 data
      top_codes <- causes_data |>
        filter(bundesland_code == "DE-BY", jahr == 2021,
               !is.na(icd_code) & nzchar(icd_code)) |>
        pull(icd_code) |> unique()
      
      top_codes_all <- c(NA, top_codes)
      
      causes_data |>
        filter(
          jahr == yr,
          is.na(icd_code) | icd_code %in% top_codes
        ) |>
        mutate(value = suppressWarnings(as.numeric(.data[[input$cv_metric]])))
    })
    
    # ── Filter for selected ICD chapter across all years ─────────────────────
    chapter_all_years <- reactive({
      req(input$cv_icd, nzchar(input$cv_icd), input$cv_metric)
      alle <- "Alle Krankheiten und Folgen \u00e4u\u00dferer Ursachen"
      
      top_codes <- causes_data |>
        filter(bundesland_code == "DE-BY", jahr == 2021,
               !is.na(icd_code) & nzchar(icd_code)) |>
        pull(icd_code) |> unique()
      
      causes_data |>
        filter(
          icd_bezeichnung == input$cv_icd |
            ((is.na(icd_code) | !nzchar(icd_code)) & input$cv_icd == alle),
          is.na(icd_code) | icd_code %in% c(top_codes)
        ) |>
        mutate(value = suppressWarnings(as.numeric(.data[[input$cv_metric]])))
    })
    
    # ── Germany reference value (selected ICD, selected year) ────────────────
    de_ref <- reactive({
      chapter_all_years() |>
        filter(bundesland_code == "DE", jahr == as.integer(input$cv_year)) |>
        pull(value) |> first()
    })
    
    # ── State value (selected ICD, selected year) ─────────────────────────────
    state_val <- reactive({
      chapter_all_years() |>
        filter(bundesland_code == selected_state(), jahr == as.integer(input$cv_year)) |>
        pull(value) |> first()
    })
    
    # ════════════════════════════════════════════════════════════════════════════
    # OUTPUT 1 — KPI BOXES
    # ════════════════════════════════════════════════════════════════════════════
    output$cv_kpi_boxes <- renderUI({
      sv  <- state_val()
      dv  <- de_ref()
      nm  <- state_name()
      lbl <- metric_lbl()
      
      diff_pct <- if (!is.na(sv) && !is.na(dv) && dv != 0)
        round((sv - dv) / dv * 100, 1) else NA
      
      diff_class <- if (!is.na(diff_pct) && diff_pct > 0) "kpi-diff-pos" else "kpi-diff-neg"
      diff_text  <- if (!is.na(diff_pct))
        paste0(if (diff_pct > 0) "▲ +" else "▼ ", diff_pct, "% vs Germany")
      else "n/a"
      
      div(class = "kpi-row",
          div(class = "kpi-box",
              div(class = "kpi-val", if (!is.na(sv)) round(sv, 1) else "—"),
              div(class = "kpi-lbl", nm),
              div(class = diff_class, diff_text)
          ),
          div(class = "kpi-box",
              div(class = "kpi-val", if (!is.na(dv)) round(dv, 1) else "—"),
              div(class = "kpi-lbl", "🇩🇪 Germany"),
              div(class = "kpi-lbl", lbl)
          )
      )
    })
    
    # ════════════════════════════════════════════════════════════════════════════
    # OUTPUT 2 — AGE GAP KPI
    # ════════════════════════════════════════════════════════════════════════════
    output$cv_age_gap_kpi <- renderUI({
      req(input$cv_icd, nzchar(input$cv_icd), input$cv_year)
      yr  <- as.integer(input$cv_year)
      icd <- input$cv_icd
      alle <- "Alle Krankheiten und Folgen \u00e4u\u00dferer Ursachen"
      
      top_codes <- causes_data |>
        filter(bundesland_code == "DE-BY", jahr == 2021,
               !is.na(icd_code) & nzchar(icd_code)) |>
        pull(icd_code) |> unique()
      
      sub <- causes_data |>
        filter(
          icd_bezeichnung == icd |
            ((is.na(icd_code) | !nzchar(icd_code)) & icd == alle),
          is.na(icd_code) | icd_code %in% top_codes,
          bundesland_code == selected_state(),
          jahr == yr
        )
      
      crude <- suppressWarnings(as.numeric(sub$sterbefaelle_je_100k[1]))
      std   <- suppressWarnings(as.numeric(sub$sterbefaelle_je_100k_altersstand[1]))
      gap   <- if (!is.na(crude) && !is.na(std)) round(crude - std, 1) else NA
      
      gap_color <- if (!is.na(gap) && gap > 0) "#c0392b" else "#27ae60"
      
      div(class = "kpi-row mt-2",
          div(class = "kpi-box",
              div(class = "kpi-val", if (!is.na(crude)) round(crude,1) else "—"),
              div(class = "kpi-lbl", "Crude rate / 100k")
          ),
          div(class = "kpi-box",
              div(class = "kpi-val", if (!is.na(std)) round(std,1) else "—"),
              div(class = "kpi-lbl", "Age-std. rate / 100k")
          ),
          div(class = "kpi-box",
              div(class = "kpi-val", style = paste0("color:", gap_color),
                  if (!is.na(gap)) gap else "—"),
              div(class = "kpi-lbl", "Age Gap"),
              div(style = paste0("font-size:0.7rem;color:", gap_color),
                  if (!is.na(gap) && gap > 0)
                    "Age inflates deaths here" else "Age not a major driver")
          )
      )
    })
    
    # ════════════════════════════════════════════════════════════════════════════
    # OUTPUT 3 — CHOROPLETH MAP
    # ════════════════════════════════════════════════════════════════════════════
    output$cv_map <- renderGirafe({
      req(input$cv_icd, nzchar(input$cv_icd))
      d <- base_data()
      
      alle <- "Alle Krankheiten und Folgen \u00e4u\u00dferer Ursachen"
      map_d <- d |>
        filter(
          icd_bezeichnung == input$cv_icd |
            ((is.na(icd_code) | !nzchar(icd_code)) & input$cv_icd == alle),
          bundesland_code %in% STATE_16
        ) |>
        left_join(germany_states |> select(state_code, geometry),
                  by = c("bundesland_code" = "state_code")) |>
        st_as_sf() |>
        mutate(is_selected = bundesland_code == selected_state())
      
      req(nrow(map_d) > 0)
      
      t <- ct()
      gg <- ggplot(map_d) +
        geom_sf_interactive(
          aes(geometry = geometry, fill = value,
              tooltip  = paste0("<b>", region, "</b><br>",
                                metric_lbl(), ": ", round(value, 1)),
              data_id  = bundesland_code),
          color = t$border, linewidth = 0.3
        ) +
        geom_sf(data = map_d |> filter(is_selected),
                aes(geometry = geometry),
                fill = NA, color = "#e74c3c", linewidth = 1.2) +
        scale_fill_gradient(low = t$map_low, high = t$map_high, na.value = t$na_fill) +
        theme_void(base_size = 10) +
        labs(fill = metric_lbl()) +
        theme(
          plot.background   = element_rect(fill = t$bg, color = NA),
          panel.background  = element_rect(fill = t$bg, color = NA),
          legend.background = element_rect(fill = t$bg, color = NA),
          legend.text       = element_text(color = t$txt, size = 8),
          legend.title      = element_text(color = t$txt, size = 8),
          legend.key.width  = unit(0.45, "cm")
        )
      
      girafe(ggobj = gg, width_svg = 9, height_svg = 5.5,
             options = list(
               opts_hover(css = "stroke:#e74c3c;stroke-width:2.5;cursor:pointer;"),
               opts_selection(type = "single", css = "stroke:#e74c3c;stroke-width:2.5;"),
               opts_tooltip(css = tt_css()),
               opts_zoom(max = 2),
               opts_toolbar(saveaspng = FALSE)
             ))
    })
    
    # Sync map click → selected state
    observeEvent(input$cv_map_selected, {
      req(nzchar(input$cv_map_selected))
      selected_state(input$cv_map_selected)
      session$sendCustomMessage(ns("update_pills"), input$cv_map_selected)
    })
    
    # ════════════════════════════════════════════════════════════════════════════
    # OUTPUT 4 — DUAL BAR: CRUDE vs AGE-STD, STATE vs GERMANY
    # ════════════════════════════════════════════════════════════════════════════
    output$cv_dual_bar <- renderGirafe({
      req(input$cv_icd, nzchar(input$cv_icd), input$cv_year)
      yr   <- as.integer(input$cv_year)
      icd  <- input$cv_icd
      alle <- "Alle Krankheiten und Folgen \u00e4u\u00dferer Ursachen"
      nm   <- state_name()
      
      top_codes <- causes_data |>
        filter(bundesland_code == "DE-BY", jahr == 2021,
               !is.na(icd_code) & nzchar(icd_code)) |>
        pull(icd_code) |> unique()
      
      sub <- causes_data |>
        filter(
          icd_bezeichnung == icd |
            ((is.na(icd_code) | !nzchar(icd_code)) & icd == alle),
          is.na(icd_code) | icd_code %in% top_codes,
          bundesland_code %in% c(selected_state(), "DE"),
          jahr == yr
        ) |>
        mutate(
          crude = suppressWarnings(as.numeric(sterbefaelle_je_100k)),
          std   = suppressWarnings(as.numeric(sterbefaelle_je_100k_altersstand)),
          entity = ifelse(bundesland_code == "DE", "🇩🇪 Germany", paste0("📍 ", nm))
        ) |>
        select(entity, crude, std) |>
        pivot_longer(c(crude, std), names_to = "type", values_to = "val") |>
        mutate(type = ifelse(type == "crude", "Crude Rate", "Age-Standardised Rate"))
      
      req(nrow(sub) > 0 && any(!is.na(sub$val)))
      
      gg <- ggplot(sub, aes(x = entity, y = val, fill = type,
                            tooltip = paste0(entity, "\n", type, ": ", round(val,1)),
                            data_id = paste0(entity, type))) +
        geom_col_interactive(position = position_dodge(0.7), width = 0.6) +
        scale_fill_manual(values = c("Crude Rate" = "#94b8f0",
                                     "Age-Standardised Rate" = "#1e3a8a")) +
        theme_minimal(base_size = 11) +
        labs(x = NULL, y = "Rate per 100,000", fill = NULL,
             title = paste0(substr(icd, 1, 60), if(nchar(icd)>60)"..." else "",
                            " — ", yr)) +
        dm_theme()[[1]] +
        theme(legend.position = "top", panel.grid.major.x = element_blank())
      
      girafe(ggobj = gg, width_svg = 9, height_svg = 4,
             options = list(
               opts_hover(css = "opacity:0.75;"),
               opts_tooltip(css = tt_css()),
               opts_toolbar(saveaspng = FALSE)
             ))
    })
    
    # ════════════════════════════════════════════════════════════════════════════
    # OUTPUT 5 — TOP 10 CAUSES vs GERMANY BENCHMARK
    # ════════════════════════════════════════════════════════════════════════════
    output$cv_top10 <- renderGirafe({
      req(input$cv_icd, nzchar(input$cv_icd), input$cv_year)
      yr  <- as.integer(input$cv_year)
      nm  <- state_name()
      sc  <- selected_state()
      
      top_codes <- causes_data |>
        filter(bundesland_code == "DE-BY", jahr == 2021,
               !is.na(icd_code) & nzchar(icd_code)) |>
        pull(icd_code) |> unique()
      
      state_d <- causes_data |>
        filter(bundesland_code == sc, jahr == yr,
               icd_code %in% top_codes) |>
        mutate(val = suppressWarnings(as.numeric(.data[[input$cv_metric]]))) |>
        filter(!is.na(val)) |>
        arrange(desc(val)) |>
        slice_head(n = 10)
      
      de_d <- causes_data |>
        filter(bundesland_code == "DE", jahr == yr,
               icd_code %in% state_d$icd_code) |>
        mutate(de_val = suppressWarnings(as.numeric(.data[[input$cv_metric]]))) |>
        select(icd_code, de_val)
      
      plot_d <- state_d |>
        left_join(de_d, by = "icd_code") |>
        mutate(
          short_label = gsub("^[A-Z]\\d{2}-[A-Z]?\\d{0,2}\\s+", "", icd_bezeichnung),
          short_label = substr(short_label, 1, 38),
          short_label = factor(short_label, levels = rev(short_label)),
          bar_color   = ifelse(val > de_val, "#c0392b", "#27ae60")
        )
      
      req(nrow(plot_d) > 0)
      
      gg <- ggplot(plot_d, aes(y = short_label)) +
        geom_col_interactive(
          aes(x = val, fill = bar_color,
              tooltip = paste0(icd_bezeichnung, "\n",
                               nm, ": ", round(val,1), "\n",
                               "Germany: ", round(de_val,1))),
          width = 0.65
        ) +
        geom_vline(aes(xintercept = de_val),
                   color = "#555", linetype = "dashed", linewidth = 0.8) +
        scale_fill_identity() +
        theme_minimal(base_size = 10) +
        labs(x = metric_lbl(), y = NULL,
             title = paste0("Top 10 — ", nm, " vs. Germany (", yr, ")"),
             caption = "Red = above Germany avg | Green = below") +
        dm_theme()[[1]] +
        theme(panel.grid.major.y = element_blank())
      
      girafe(ggobj = gg, width_svg = 10, height_svg = 5.5,
             options = list(
               opts_hover(css = "opacity:0.8;"),
               opts_tooltip(css = tt_css()),
               opts_toolbar(saveaspng = FALSE)
             ))
    })
    
    # ════════════════════════════════════════════════════════════════════════════
    # OUTPUT 6 — TREND LINE 2021-2024
    # ════════════════════════════════════════════════════════════════════════════
    output$cv_trend <- renderGirafe({
      req(input$cv_icd, nzchar(input$cv_icd))
      nm  <- state_name()
      icd <- input$cv_icd
      
      trend_d <- chapter_all_years() |>
        filter(bundesland_code %in% c(selected_state(), "DE")) |>
        mutate(entity = ifelse(bundesland_code == "DE",
                               "Germany", nm)) |>
        arrange(jahr)
      
      req(nrow(trend_d) > 0)
      
      gg <- ggplot(trend_d, aes(x = jahr, y = value,
                                color = entity, group = entity,
                                linetype = entity)) +
        geom_line_interactive(aes(
          tooltip = paste0(entity, " (", jahr, "): ", round(value,1)),
          data_id = paste0(entity, jahr)
        ), linewidth = 1.4) +
        geom_point_interactive(aes(
          tooltip = paste0(entity, " (", jahr, "): ", round(value,1)),
          data_id = paste0(entity, jahr)
        ), size = 3) +
        scale_color_manual(values = c("Germany" = ct()$de_line, setNames(ct()$state_line, nm))) +
        scale_linetype_manual(values = c("Germany" = "dashed", setNames("solid", nm))) +
        scale_x_continuous(breaks = c(2021,2022,2023,2024)) +
        theme_minimal(base_size = 11) +
        labs(x = "Year", y = metric_lbl(), color = NULL, linetype = NULL,
             title = paste0("Trend: ", substr(icd,1,55),
                            if(nchar(icd)>55)"..."else"")) +
        dm_theme()[[1]] +
        theme(legend.position = "top")
      
      girafe(ggobj = gg, width_svg = 10, height_svg = 4,
             options = list(
               opts_hover(css = "stroke-width:2.5;"),
               opts_tooltip(css = tt_css()),
               opts_toolbar(saveaspng = FALSE)
             ))
    })
    
    # ════════════════════════════════════════════════════════════════════════════
    # OUTPUT 7 — AVOIDABLE CAUSES
    # ════════════════════════════════════════════════════════════════════════════
    output$cv_avoidable <- renderGirafe({
      req(input$cv_icd, nzchar(input$cv_icd), input$cv_year)
      yr  <- as.integer(input$cv_year)
      nm  <- state_name()
      sc  <- selected_state()
      
      avoid_codes <- sapply(AVOIDABLE, `[[`, "code")
      avoid_labels <- sapply(AVOIDABLE, `[[`, "label")
      avoid_colors <- sapply(AVOIDABLE, `[[`, "color")
      
      state_av <- causes_data |>
        filter(bundesland_code == sc, jahr == yr,
               icd_code %in% avoid_codes) |>
        mutate(val = suppressWarnings(as.numeric(.data[[input$cv_metric]])))
      
      de_av <- causes_data |>
        filter(bundesland_code == "DE", jahr == yr,
               icd_code %in% avoid_codes) |>
        mutate(de_val = suppressWarnings(as.numeric(.data[[input$cv_metric]]))) |>
        select(icd_code, de_val)
      
      plot_d <- state_av |>
        left_join(de_av, by = "icd_code") |>
        mutate(
          short_label = gsub("^[A-Z]\\d{2}-[A-Z]?\\d{2}\\s+", "", icd_bezeichnung),
          short_label = substr(short_label, 1, 32),
          bar_color   = avoid_colors[match(icd_code, avoid_codes)]
        )
      
      req(nrow(plot_d) > 0)
      
      gg <- ggplot(plot_d, aes(x = reorder(short_label, val))) +
        geom_col_interactive(
          aes(y = val, fill = bar_color,
              tooltip = paste0(icd_bezeichnung, "\n",
                               nm, ": ", round(val,1), "\n",
                               "Germany: ", round(de_val,1))),
          width = 0.6
        ) +
        geom_point(aes(y = de_val), shape = 23, size = 4,
                   fill = "white", color = "#333", stroke = 1.5) +
        scale_fill_identity() +
        coord_flip() +
        theme_minimal(base_size = 10) +
        labs(x = NULL, y = metric_lbl(),
             title = paste0("Potentially Avoidable Deaths — ", nm, " (", yr, ")"),
             caption = "◇ = Germany average") +
        dm_theme()[[1]] +
        theme(panel.grid.major.y = element_blank())
      
      girafe(ggobj = gg, width_svg = 10, height_svg = 4.5,
             options = list(
               opts_hover(css = "opacity:0.8;"),
               opts_tooltip(css = tt_css()),
               opts_toolbar(saveaspng = FALSE)
             ))
    })
    
  })
}