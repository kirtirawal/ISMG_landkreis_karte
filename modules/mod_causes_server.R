mod_causes_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    ns <- session$ns
    
    # ── Constants ─────────────────────────────────────────────────────────────
    STATE_16 <- c("DE-BW","DE-BY","DE-BE","DE-BB","DE-HB","DE-HH","DE-HE",
                  "DE-MV","DE-NI","DE-NW","DE-RP","DE-SL","DE-SN","DE-ST",
                  "DE-SH","DE-TH")
    
    AVOIDABLE <- list(
      list(code = "F10-F19",
           label_de = "Suchterkrankungen\n(F10-F19)",
           label_en = "Substance Use\n(F10-F19)",    color = "#e74c3c"),
      list(code = "K70-K77",
           label_de = "Lebererkrankungen\n(K70-K77)",
           label_en = "Liver Disease\n(K70-K77)",    color = "#e67e22"),
      list(code = "J40-J47",
           label_de = "COPD\n(J40-J47)",
           label_en = "COPD\n(J40-J47)",             color = "#f39c12"),
      list(code = "E10-E14",
           label_de = "Diabetes mellitus\n(E10-E14)",
           label_en = "Diabetes\n(E10-E14)",         color = "#3498db"),
      list(code = "S00-T98",
           label_de = "Verletzungen &\nVergiftungen\n(S00-T98)",
           label_en = "Injuries &\nPoisoning\n(S00-T98)", color = "#9b59b6")
    )
    
    # ── Language: default German, toggle switches to EN ──────────────────────
    lang <- reactiveVal("de")
    observeEvent(input$cv_lang, { lang(input$cv_lang) })
    
    # Sync metric dropdown labels when language changes
    observeEvent(lang(), {
      if (lang() == "en") {
        new_labels <- c("Deaths (absolute)", "Per 100,000 (crude)",
                        "Per 100,000 (age-std.)")
      } else {
        new_labels <- c("Sterbef\u00e4lle (absolut)",
                        "Je 100.000 Einwohner (roh)",
                        "Je 100.000 (altersstandardisiert)")
      }
      session$sendCustomMessage(ns("update_metric_labels"), new_labels)
    })
    
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
    
    # ── Metric label (language-aware) ────────────────────────────────────────
    metric_lbl <- reactive({
      if (!is.null(input$cv_lang) && input$cv_lang == "en") {
        switch(input$cv_metric,
               "sterbefaelle"                     = "Deaths (absolute)",
               "sterbefaelle_je_100k"             = "Per 100,000 (crude)",
               "sterbefaelle_je_100k_altersstand" = "Per 100,000 (age-std.)",
               input$cv_metric)
      } else {
        switch(input$cv_metric,
               "sterbefaelle"                     = "Sterbefu00e4lle (absolut)",
               "sterbefaelle_je_100k"             = "Je 100.000 Einwohner (roh)",
               "sterbefaelle_je_100k_altersstand" = "Je 100.000 (altersstd.)",
               input$cv_metric)
      }
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
      req(input$cv_icd, input$cv_metric)
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
        paste0(if (diff_pct > 0) "▲ +" else "▼ ", diff_pct, if(!is.null(input$cv_lang) && input$cv_lang=="en") "% vs Germany" else "% vs. Deutschland")
      else if(!is.null(input$cv_lang) && input$cv_lang=="en") "n/a" else "k.A."
      
      div(class = "kpi-row",
          div(class = "kpi-box",
              div(class = "kpi-val", if (!is.na(sv)) round(sv, 1) else "—"),
              div(class = "kpi-lbl", nm),
              div(class = diff_class, diff_text)
          ),
          div(class = "kpi-box",
              div(class = "kpi-val", if (!is.na(dv)) round(dv, 1) else "—"),
              div(class = "kpi-lbl", if(!is.null(input$cv_lang) && input$cv_lang=="en") "🇩🇪 Germany" else "🇩🇪 Deutschland"),
              div(class = "kpi-lbl", lbl)
          )
      )
    })
    
    # ════════════════════════════════════════════════════════════════════════════
    # OUTPUT 2 — AGE GAP KPI
    # ════════════════════════════════════════════════════════════════════════════
    output$cv_age_gap_kpi <- renderUI({
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
              div(class = "kpi-lbl", if(!is.null(input$cv_lang) && input$cv_lang=="en") "Crude rate / 100k" else "Rohe Rate / 100k")
          ),
          div(class = "kpi-box",
              div(class = "kpi-val", if (!is.na(std)) round(std,1) else "—"),
              div(class = "kpi-lbl", if(!is.null(input$cv_lang) && input$cv_lang=="en") "Age-std. rate / 100k" else "Altersstd. Rate / 100k")
          ),
          div(class = "kpi-box",
              div(class = "kpi-val", style = paste0("color:", gap_color),
                  if (!is.na(gap)) gap else "—"),
              div(class = "kpi-lbl", if(!is.null(input$cv_lang) && input$cv_lang=="en") "Age Gap" else "Altersunterschied"),
              div(style = paste0("font-size:0.7rem;color:", gap_color),
                  if (!is.na(gap) && gap > 0)
                    if(!is.null(input$cv_lang) && input$cv_lang=="en") "Age inflates deaths here" else "Alter erhöht die Sterberate")
          )
      )
    })
    
    # ════════════════════════════════════════════════════════════════════════════
    # OUTPUT 2b — MAP INFO PANEL (shows tapped state value on mobile)
    # ════════════════════════════════════════════════════════════════════════════
    output$cv_map_panel <- renderUI({
      nm  <- state_name()
      sc  <- selected_state()
      lbl <- metric_lbl()
      icd <- input$cv_icd
      yr  <- as.integer(input$cv_year)
      alle <- "Alle Krankheiten und Folgen äußerer Ursachen"
      
      top_codes <- causes_data |>
        filter(bundesland_code == "DE-BY", jahr == 2021,
               !is.na(icd_code) & nzchar(icd_code)) |>
        pull(icd_code) |> unique()
      
      state_row <- causes_data |>
        filter(
          icd_bezeichnung == icd |
            ((is.na(icd_code) | !nzchar(icd_code)) & icd == alle),
          is.na(icd_code) | icd_code %in% top_codes,
          bundesland_code == sc, jahr == yr
        ) |> slice(1)
      
      de_row <- causes_data |>
        filter(
          icd_bezeichnung == icd |
            ((is.na(icd_code) | !nzchar(icd_code)) & icd == alle),
          is.na(icd_code) | icd_code %in% top_codes,
          bundesland_code == "DE", jahr == yr
        ) |> slice(1)
      
      sv <- suppressWarnings(as.numeric(state_row[[input$cv_metric]][1]))
      dv <- suppressWarnings(as.numeric(de_row[[input$cv_metric]][1]))
      abs_val <- suppressWarnings(as.numeric(state_row$sterbefaelle[1]))
      
      diff_pct <- if (!is.na(sv) && !is.na(dv) && dv != 0)
        round((sv - dv) / dv * 100, 1) else NA
      
      diff_class <- if (!is.na(diff_pct) && diff_pct > 0) "mip-diff-pos" else "mip-diff-neg"
      diff_text  <- if (!is.na(diff_pct))
        paste0(if (diff_pct > 0) "▲ +" else "▼ ", diff_pct, "% vs. ",
               if(!is.null(input$cv_lang) && input$cv_lang=="en") "Germany" else "Deutschland")
      else ""
      
      de_lbl <- if(!is.null(input$cv_lang) && input$cv_lang=="en") "Germany" else "Deutschland"
      abs_lbl <- if(!is.null(input$cv_lang) && input$cv_lang=="en") "abs. deaths" else "abs. Sterbefälle"
      
      div(class = "map-info-panel",
          div(
            div(class = "mip-name", "📍 ", nm),
            div(class = diff_class, diff_text)
          ),
          div(style = "margin-left:auto; text-align:right;",
              div(class = "mip-val", if (!is.na(sv)) round(sv, 1) else "—"),
              div(class = "mip-lbl", lbl)
          ),
          div(style = "text-align:right; border-left:1px solid rgba(255,255,255,0.2); padding-left:12px;",
              div(class = "mip-val", style="font-size:1rem;",
                  if (!is.na(abs_val)) format(abs_val, big.mark=".", decimal.mark=",") else "—"),
              div(class = "mip-lbl", abs_lbl)
          ),
          div(style = "text-align:right; border-left:1px solid rgba(255,255,255,0.2); padding-left:12px;",
              div(class = "mip-val", style="font-size:1rem; color:#fde68a;",
                  if (!is.na(dv)) round(dv, 1) else "—"),
              div(class = "mip-lbl", paste0("🇩🇪 ", de_lbl))
          )
      )
    })
    
    # ════════════════════════════════════════════════════════════════════════════
    # OUTPUT 3 — CHOROPLETH MAP
    # ════════════════════════════════════════════════════════════════════════════
    output$cv_map <- renderGirafe({
      d <- base_data()
      req(input$cv_icd)
      
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
      
      # Compute centroids for value labels
      map_labels <- map_d |>
        mutate(
          centroid = st_centroid(geometry),
          lbl_val  = ifelse(!is.na(value), as.character(round(value, 1)), ""),
          lbl_size = ifelse(is_selected, 3.4, 2.6)
        )
      
      gg <- ggplot(map_d) +
        geom_sf_interactive(
          aes(geometry = geometry, fill = value,
              tooltip  = paste0("<b>", region, "</b>\n",
                                metric_lbl(), ": ", round(value, 1), "\n",
                                if(!is.null(input$cv_lang) && input$cv_lang=="en")
                                  "Tap to select" else "Antippen zum Ausw\u00e4hlen"),
              data_id  = bundesland_code),
          color = "white", linewidth = 0.4
        ) +
        # Selected state border
        geom_sf(data = map_d |> filter(is_selected),
                aes(geometry = geometry),
                fill = NA, color = "#e74c3c", linewidth = 1.6) +
        # Value labels on each state
        geom_sf_text(
          data = map_labels,
          aes(geometry = centroid, label = lbl_val,
              size = lbl_size,
              fontface = ifelse(is_selected, "bold", "plain")),
          color = "white", show.legend = FALSE
        ) +
        scale_size_identity() +
        scale_fill_gradient(low = "#dbeafe", high = "#1e3a8a", na.value = "grey85") +
        theme_void(base_size = 10) +
        labs(fill = metric_lbl()) +
        theme(legend.key.width = unit(0.45, "cm"),
              legend.text = element_text(size = 8))
      
      girafe(ggobj = gg, width_svg = 9, height_svg = 5.5,
             options = list(
               opts_hover(css = "stroke:#e74c3c;stroke-width:2.5;cursor:pointer;opacity:0.85;"),
               opts_selection(type = "single"),
               opts_zoom(max = 2),
               opts_toolbar(saveaspng = FALSE),
               opts_tooltip(use_fill = FALSE,
                            css = "background:#1a3a5c;color:#fff;padding:8px 12px;border-radius:8px;font-size:13px;font-family:sans-serif;")
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
          entity = ifelse(bundesland_code == "DE",
                          if(!is.null(input$cv_lang) && input$cv_lang=="en") "🇩🇪 Germany" else "🇩🇪 Deutschland",
                          paste0("📍 ", nm))
        ) |>
        select(entity, crude, std) |>
        pivot_longer(c(crude, std), names_to = "type", values_to = "val") |>
        mutate(type = ifelse(type == "crude",
                             if(!is.null(input$cv_lang) && input$cv_lang=="en") "Crude Rate" else "Rohe Rate",
                             if(!is.null(input$cv_lang) && input$cv_lang=="en") "Age-Standardised Rate" else "Altersstandardisiert"))
      
      req(nrow(sub) > 0 && any(!is.na(sub$val)))
      
      gg <- ggplot(sub, aes(x = entity, y = val, fill = type,
                            tooltip = paste0(entity, "\n", type, ": ", round(val,1)),
                            data_id = paste0(entity, type))) +
        geom_col_interactive(position = position_dodge(0.7), width = 0.6) +
        scale_fill_manual(values = setNames(c("#94b8f0","#1e3a8a"),
                                            if(!is.null(input$cv_lang) && input$cv_lang=="en") c("Crude Rate","Age-Standardised Rate") else c("Rohe Rate","Altersstandardisiert"))) +
        theme_minimal(base_size = 11) +
        labs(x = NULL, y = if(!is.null(input$cv_lang) && input$cv_lang=="en") "Rate per 100,000" else "Rate je 100.000", fill = NULL,
             title = paste0(substr(icd, 1, 60), if(nchar(icd)>60)"..." else "",
                            " — ", yr)) +
        theme(plot.title = element_text(size = 10, face = "bold"),
              legend.position = "top",
              panel.grid.major.x = element_blank())
      
      girafe(ggobj = gg, width_svg = 9, height_svg = 4,
             options = list(opts_hover(css = "opacity:0.75;"),
                            opts_toolbar(saveaspng = FALSE)))
    })
    
    # ════════════════════════════════════════════════════════════════════════════
    # OUTPUT 5 — TOP 10 CAUSES vs GERMANY BENCHMARK
    # ════════════════════════════════════════════════════════════════════════════
    output$cv_top10 <- renderGirafe({
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
                               if(!is.null(input$cv_lang) && input$cv_lang=="en") "Germany: " else "Deutschland: ", round(de_val,1))),
          width = 0.65
        ) +
        geom_vline(aes(xintercept = de_val),
                   color = "#555", linetype = "dashed", linewidth = 0.8) +
        scale_fill_identity() +
        theme_minimal(base_size = 10) +
        labs(x = metric_lbl(), y = NULL,
             title = paste0("Top 10 — ", nm, if(!is.null(input$cv_lang) && input$cv_lang=="en") " vs. Germany (" else " vs. Deutschland (", yr, ")"),
             caption = if(!is.null(input$cv_lang) && input$cv_lang=="en") "Red = above Germany avg | Green = below" else "Rot = über Bundesdurchschnitt | Grün = darunter") +
        theme(
          plot.title   = element_text(size = 10, face = "bold"),
          plot.caption = element_text(size = 8, color = "#666"),
          panel.grid.major.y = element_blank()
        )
      
      girafe(ggobj = gg, width_svg = 10, height_svg = 5.5,
             options = list(opts_hover(css = "opacity:0.8;"),
                            opts_toolbar(saveaspng = FALSE)))
    })
    
    # ════════════════════════════════════════════════════════════════════════════
    # OUTPUT 6 — TREND LINE 2021-2024
    # ════════════════════════════════════════════════════════════════════════════
    output$cv_trend <- renderGirafe({
      nm  <- state_name()
      icd <- input$cv_icd
      
      trend_d <- chapter_all_years() |>
        filter(bundesland_code %in% c(selected_state(), "DE")) |>
        mutate(entity = ifelse(bundesland_code == "DE",
                               if(!is.null(input$cv_lang) && input$cv_lang=="en") "Germany" else "Deutschland", nm)) |>
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
        scale_color_manual(values = c(setNames("#94a3b8", if(!is.null(input$cv_lang) && input$cv_lang=="en") "Germany" else "Deutschland"), setNames("#1e3a8a", nm))) +
        scale_linetype_manual(values = c(setNames("dashed", if(!is.null(input$cv_lang) && input$cv_lang=="en") "Germany" else "Deutschland"), setNames("solid", nm))) +
        scale_x_continuous(breaks = c(2021,2022,2023,2024)) +
        theme_minimal(base_size = 11) +
        labs(x = if(!is.null(input$cv_lang) && input$cv_lang=="en") "Year" else "Jahr", y = metric_lbl(), color = NULL, linetype = NULL,
             title = paste0(if(!is.null(input$cv_lang) && input$cv_lang=="en") "Trend: " else "Zeitreihe: ", substr(icd,1,55),
                            if(nchar(icd)>55)"..."else"")) +
        theme(plot.title = element_text(size = 10, face = "bold"),
              legend.position = "top",
              panel.grid.minor = element_blank())
      
      girafe(ggobj = gg, width_svg = 10, height_svg = 4,
             options = list(opts_hover(css = "stroke-width:2.5;"),
                            opts_toolbar(saveaspng = FALSE)))
    })
    
    # ════════════════════════════════════════════════════════════════════════════
    # OUTPUT 7 — AVOIDABLE CAUSES
    # ════════════════════════════════════════════════════════════════════════════
    output$cv_avoidable <- renderGirafe({
      yr  <- as.integer(input$cv_year)
      nm  <- state_name()
      sc  <- selected_state()
      
      avoid_codes <- sapply(AVOIDABLE, `[[`, "code")
      avoid_labels <- sapply(AVOIDABLE, function(x) if(!is.null(input$cv_lang) && input$cv_lang=="en") x[["label_en"]] else x[["label_de"]])
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
                               if(!is.null(input$cv_lang) && input$cv_lang=="en") "Germany: " else "Deutschland: ", round(de_val,1))),
          width = 0.6
        ) +
        geom_point(aes(y = de_val), shape = 23, size = 4,
                   fill = "white", color = "#333", stroke = 1.5) +
        scale_fill_identity() +
        coord_flip() +
        theme_minimal(base_size = 10) +
        labs(x = NULL, y = metric_lbl(),
             title = paste0(if(!is.null(input$cv_lang) && input$cv_lang=="en") "Potentially Avoidable Deaths — " else "Potenziell vermeidbare Todesursachen — ", nm, " (", yr, ")"),
             caption = if(!is.null(input$cv_lang) && input$cv_lang=="en") "◇ = Germany average" else "◇ = Bundesdurchschnitt") +
        theme(
          plot.title   = element_text(size = 10, face = "bold"),
          plot.caption = element_text(size = 8, color = "#666"),
          panel.grid.major.y = element_blank()
        )
      
      girafe(ggobj = gg, width_svg = 10, height_svg = 4.5,
             options = list(opts_hover(css = "opacity:0.8;"),
                            opts_toolbar(saveaspng = FALSE)))
    })
    
  })
}