mod_causes_server <- function(id, causes_data, germany_states) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # ------------------------------------------------------------------------
    # Theme mode
    # ------------------------------------------------------------------------
    theme_mode <- reactiveVal("dark")
    observeEvent(input$cv_theme_mode, {
      v <- input$cv_theme_mode
      if (!is.null(v) && length(v) > 0 && !is.na(v[1])) {
        theme_mode(as.character(v)[1])
      }
    })
    
    theme_clinical <- function(base_size = 10) {
      is_light <- theme_mode() == "light"
      bg_col   <- if (is_light) "#e2e8f0" else "#172442"
      text_col <- if (is_light) "#1e293b" else "#cbd5e1"
      grid_col <- if (is_light) "#cbd5e1" else "#1e2d4a"
      
      theme_minimal(base_size = base_size) +
        theme(
          plot.background   = element_rect(fill = bg_col, color = NA),
          panel.background  = element_rect(fill = bg_col, color = NA),
          text              = element_text(color = text_col, family = "sans"),
          plot.title        = element_text(
            color = if (is_light) "#0f172a" else "#f8fafc",
            face = "bold"),
          axis.text         = element_text(color = text_col),
          axis.title        = element_text(color = text_col),
          panel.grid.major  = element_line(color = grid_col, linewidth = 0.4),
          panel.grid.minor  = element_blank(),
          legend.text       = element_text(color = text_col),
          legend.background = element_rect(fill = bg_col, color = NA))
    }
    
    STATE_16 <- c("DE-BW","DE-BY","DE-BE","DE-BB","DE-HB","DE-HH","DE-HE",
                  "DE-MV","DE-NI","DE-NW","DE-RP","DE-SL","DE-SN","DE-ST",
                  "DE-SH","DE-TH")
    
    ALL_LABEL <- "Alle Krankheiten und Folgen äußerer Ursachen"
    
    AVOIDABLE <- list(
      list(code = "F10-F19", label_de = "Suchterkrankungen\n(F10-F19)",
           label_en = "Substance Use\n(F10-F19)",  color = "#2dd4bf"),
      list(code = "K70-K77", label_de = "Lebererkrankungen\n(K70-K77)",
           label_en = "Liver Disease\n(K70-K77)",  color = "#38bdf8"),
      list(code = "J40-J47", label_de = "COPD\n(J40-J47)",
           label_en = "COPD\n(J40-J47)",           color = "#fbbf24"),
      list(code = "E10-E14", label_de = "Diabetes mellitus\n(E10-E14)",
           label_en = "Diabetes\n(E10-E14)",       color = "#f87171"),
      list(code = "S00-T98", label_de = "Verletzungen\n(S00-T98)",
           label_en = "Injuries\n(S00-T98)",       color = "#a78bfa"))
    
    lang <- reactiveVal("de")
    observeEvent(input$cv_lang, {
      v <- input$cv_lang
      if (!is.null(v) && length(v) > 0 && !is.na(v[1])) {
        lang(as.character(v)[1])
      }
    })
    
    # ------------------------------------------------------------------------
    # ICD catalogue
    # ------------------------------------------------------------------------
    observe({
      req(causes_data)
      chapters <- causes_data |>
        filter(!is.na(icd_code) & nzchar(icd_code)) |>
        distinct(icd_code, icd_bezeichnung) |>
        arrange(icd_code)
      choices <- setNames(chapters$icd_bezeichnung, chapters$icd_bezeichnung)
      choices <- c(setNames(ALL_LABEL, ALL_LABEL), choices)
      updateSelectInput(session, "cv_icd", choices = choices,
                        selected = choices[1])
    })
    
    selected_state <- reactiveVal("DE-ST")
    
    observeEvent(input$cv_state_click, {
      val <- input$cv_state_click
      if (is.null(val) || length(val) == 0) return()
      code <- as.character(val)[1]
      if (is.na(code) || !nzchar(code)) return()
      selected_state(code)
      session$sendCustomMessage(ns("update_pills"), code)
    })
    
    # ---- scalar-safe state name ----
    state_name <- reactive({
      code <- selected_state()
      if (is.null(code) || length(code) == 0 || is.na(code[1])) return("—")
      v <- causes_data |>
        dplyr::filter(bundesland_code == code[1]) |>
        dplyr::pull(region) |>
        unique()
      if (length(v) == 0) return("—")
      as.character(v)[1]
    })
    
    metric_lbl <- reactive({
      if (!is.null(input$cv_lang) && length(input$cv_lang) > 0 &&
          input$cv_lang[1] == "en") {
        switch(input$cv_metric,
               "sterbefaelle" = "Deaths (absolute)",
               "sterbefaelle_je_100k" = "Per 100,000 (crude)",
               "sterbefaelle_je_100k_altersstand" = "Per 100,000 (age-std.)",
               input$cv_metric)
      } else {
        switch(input$cv_metric,
               "sterbefaelle" = "Sterbefälle (absolut)",
               "sterbefaelle_je_100k" = "Je 100.000 (roh)",
               "sterbefaelle_je_100k_altersstand" = "Je 100.000 (altersstd.)",
               input$cv_metric)
      }
    })
    
    base_data <- reactive({
      req(input$cv_year, input$cv_metric, causes_data)
      causes_data |>
        filter(jahr == as.integer(input$cv_year)) |>
        mutate(value = suppressWarnings(as.numeric(.data[[input$cv_metric]])))
    })
    
    chapter_all_years <- reactive({
      req(input$cv_icd, input$cv_metric, causes_data)
      causes_data |>
        filter(
          icd_bezeichnung == input$cv_icd |
            ((is.na(icd_code) | !nzchar(icd_code)) & input$cv_icd == ALL_LABEL)
        ) |>
        mutate(value = suppressWarnings(as.numeric(.data[[input$cv_metric]])))
    })
    
    # ---- de_ref with fallback aggregation ----
    de_ref <- reactive({
      d  <- chapter_all_years()
      yr <- as.integer(input$cv_year)
      
      v <- d |>
        dplyr::filter(bundesland_code == "DE", jahr == yr) |>
        dplyr::pull(value)
      
      if (length(v) > 0 && !all(is.na(v))) {
        return(v[1])
      }
      
      v2 <- d |>
        dplyr::filter(bundesland_code %in% STATE_16, jahr == yr,
                      !is.na(value)) |>
        dplyr::summarise(v = mean(value, na.rm = TRUE)) |>
        dplyr::pull(v)
      
      if (length(v2) == 0 || is.na(v2[1])) return(NA_real_)
      v2[1]
    })
    
    # ---- scalar-safe state value ----
    state_val <- reactive({
      code <- selected_state()
      if (is.null(code) || length(code) == 0 || is.na(code[1])) return(NA_real_)
      v <- chapter_all_years() |>
        dplyr::filter(bundesland_code == code[1],
                      jahr == as.integer(input$cv_year)) |>
        dplyr::pull(value)
      if (length(v) == 0) return(NA_real_)
      v[1]
    })
    
    # ---- rank table ----
    rank_tbl <- reactive({
      base_data() |>
        filter(bundesland_code %in% STATE_16) |>
        filter(icd_bezeichnung == input$cv_icd |
                 ((is.na(icd_code) | !nzchar(icd_code)) & input$cv_icd == ALL_LABEL)) |>
        filter(!is.na(value)) |>
        group_by(bundesland_code, region) |>
        summarise(value = mean(value, na.rm = TRUE), .groups = "drop") |>
        arrange(desc(value)) |>
        mutate(rank = row_number())
    })
    
    # ---- scalar-safe rank ----
    current_rank <- reactive({
      code <- selected_state()
      if (is.null(code) || length(code) == 0 || is.na(code[1])) return(NA_integer_)
      rt <- rank_tbl()
      r  <- rt |> dplyr::filter(bundesland_code == code[1])
      if (nrow(r) == 0) NA_integer_ else r$rank[1]
    })
    
    diff_pct_now <- reactive({
      sv <- state_val(); dv <- de_ref()
      if (length(sv) == 0 || length(dv) == 0) return(NA_real_)
      if (is.na(sv[1]) || is.na(dv[1]) || dv[1] == 0) return(NA_real_)
      round((sv[1] - dv[1]) / dv[1] * 100, 1)
    })
    
    # ---- top10 with unique labels and fallback DE ----
    top10_data <- reactive({
      yr <- as.integer(input$cv_year)
      sc <- selected_state()
      nm <- state_name()
      req(length(sc) > 0, !is.na(sc[1]))
      
      state_d <- causes_data |>
        dplyr::filter(bundesland_code == sc[1], jahr == yr,
                      !is.na(icd_code), nzchar(icd_code)) |>
        dplyr::mutate(val = suppressWarnings(as.numeric(.data[[input$cv_metric]]))) |>
        dplyr::filter(!is.na(val)) |>
        dplyr::arrange(dplyr::desc(val)) |>
        dplyr::slice_head(n = 10)
      
      req(nrow(state_d) > 0)
      
      de_d <- causes_data |>
        dplyr::filter(bundesland_code == "DE", jahr == yr,
                      icd_code %in% state_d$icd_code) |>
        dplyr::mutate(de_val = suppressWarnings(as.numeric(.data[[input$cv_metric]]))) |>
        dplyr::select(icd_code, de_val)
      
      de_fallback <- causes_data |>
        dplyr::filter(bundesland_code %in% STATE_16, jahr == yr,
                      icd_code %in% state_d$icd_code) |>
        dplyr::mutate(de_val = suppressWarnings(as.numeric(.data[[input$cv_metric]]))) |>
        dplyr::group_by(icd_code) |>
        dplyr::summarise(de_val = mean(de_val, na.rm = TRUE), .groups = "drop")
      
      de_full <- dplyr::bind_rows(de_d, de_fallback) |>
        dplyr::distinct(icd_code, .keep_all = TRUE)
      
      state_d |>
        dplyr::left_join(de_full, by = "icd_code") |>
        dplyr::mutate(
          short_base  = gsub("^[A-Z]\\d{2}-[A-Z]?\\d{0,2}\\s+", "", icd_bezeichnung),
          short_base  = substr(short_base, 1, 26),
          short_label = paste0(short_base, " (", icd_code, ")"),
          gap         = val - de_val,
          gap_abs     = abs(gap),
          state       = nm)
    })
    
    # ========================================================================
    # KPI row
    # ========================================================================
    output$cv_kpi_boxes <- renderUI({
      sv  <- state_val(); dv <- de_ref(); nm <- state_name(); lbl <- metric_lbl()
      diff_pct <- diff_pct_now()
      rk       <- current_rank()
      n_states <- nrow(rank_tbl())
      
      diff_class <- if (!is.na(diff_pct) && diff_pct > 0) "kpi-diff-pos" else "kpi-diff-neg"
      diff_text  <- if (!is.na(diff_pct))
        paste0(if (diff_pct > 0) "▲ +" else "▼ ", diff_pct, "% vs. Bund") else "—"
      
      rank_txt <- if (!is.na(rk)) paste0(rk, "/", n_states) else "—"
      
      div(class = "kpi-row",
          div(class = "kpi-box",
              div(class = "kpi-val", style = "color:var(--accent-cyan);",
                  if (!is.na(sv)) round(sv, 1) else "—"),
              div(class = "kpi-lbl", nm),
              div(class = diff_class, diff_text)),
          div(class = "kpi-box",
              div(class = "kpi-val", style = "color:#f59e0b;",
                  if (!is.na(dv)) round(dv, 1) else "—"),
              div(class = "kpi-lbl", "🇩🇪 Bundesschnitt"),
              div(style = "font-size:0.72rem; color:var(--text-muted); margin-top:4px;",
                  lbl)),
          div(class = "kpi-box",
              div(class = "kpi-val", style = "color:#a78bfa;", rank_txt),
              div(class = "kpi-lbl", "Nationales Ranking"),
              div(style = "font-size:0.72rem; color:var(--text-muted); margin-top:4px;",
                  "1 = höchste Mortalität")))
    })
    
    # ---- map severity badge ----
    output$cv_map_badge <- renderUI({
      d <- diff_pct_now()
      r <- classify_risk(d)
      severity_badge(r$level, r$label)
    })
    
    # ========================================================================
    # Map
    # ========================================================================
    output$cv_map <- renderGirafe({
      d <- base_data(); req(input$cv_icd, germany_states)
      
      map_d <- d |>
        filter(icd_bezeichnung == input$cv_icd |
                 ((is.na(icd_code) | !nzchar(icd_code)) & input$cv_icd == ALL_LABEL),
               bundesland_code %in% STATE_16) |>
        left_join(germany_states |> select(state_code, geometry),
                  by = c("bundesland_code" = "state_code")) |>
        st_as_sf()
      req(nrow(map_d) > 0)
      
      gr <- de_ref()
      validate(need(!is.na(gr),
                    "Kein Bundesdurchschnitt für diese Auswahl verfügbar."))
      
      code_sel <- selected_state()
      code_sel <- if (length(code_sel) == 0) NA_character_ else code_sel[1]
      
      map_d <- map_d |>
        dplyr::mutate(is_selected = !is.na(bundesland_code) &
                        bundesland_code == code_sel,
                      deviation   = value - gr)
      
      lim <- suppressWarnings(max(abs(map_d$deviation), na.rm = TRUE))
      if (!is.finite(lim) || lim == 0) lim <- 1
      
      gg <- ggplot(map_d) +
        geom_sf_interactive(
          aes(geometry = geometry, fill = deviation,
              tooltip = paste0("<b>", region, "</b>\n", metric_lbl(), ": ",
                               round(value, 1), "\nvs. Bund: ",
                               ifelse(deviation >= 0, "+", ""),
                               round(deviation, 1)),
              data_id = bundesland_code),
          color = "#0b1326", linewidth = 0.5) +
        geom_sf(data = map_d |> filter(is_selected), aes(geometry = geometry),
                fill = NA, color = "#2dd4bf", linewidth = 1.8) +
        scale_fill_gradient2(low = "#2c7bb6", mid = "#f7f7f7", high = "#d73027",
                             midpoint = 0, limits = c(-lim, lim),
                             oob = scales::squish, name = "Abweichung\nvom Bund") +
        theme_void() +
        theme(
          plot.background = element_rect(
            fill = if (theme_mode() == "light") "#e2e8f0" else "#172442", color = NA),
          legend.position = "bottom",
          legend.text  = element_text(
            color = if (theme_mode() == "light") "#1e293b" else "#cbd5e1", size = 8),
          legend.title = element_text(
            color = if (theme_mode() == "light") "#1e293b" else "#cbd5e1", size = 9))
      
      girafe(ggobj = gg, width_svg = 8, height_svg = 6,
             options = list(
               opts_hover(css = "stroke:#2dd4bf;stroke-width:2;cursor:pointer;"),
               opts_toolbar(saveaspng = FALSE),
               opts_tooltip(css = "background:#0b1326;color:#f8fafc;padding:6px 10px;border-radius:6px;")))
    })
    
    observeEvent(input$cv_map_selected, {
      v <- input$cv_map_selected
      if (is.null(v) || length(v) == 0 || !nzchar(v[1])) return()
      code <- as.character(v)[1]
      selected_state(code)
      session$sendCustomMessage(ns("update_pills"), code)
    })
    
    # ========================================================================
    # Map interpretation
    # ========================================================================
    output$cv_map_interp <- renderUI({
      cs <- base_data() |>
        filter(icd_bezeichnung == input$cv_icd |
                 ((is.na(icd_code) | !nzchar(icd_code)) & input$cv_icd == ALL_LABEL),
               bundesland_code %in% STATE_16) |>
        filter(!is.na(value))
      
      req(nrow(cs) > 0)
      gr <- de_ref()
      if (is.na(gr)) return(NULL)
      
      worst <- cs |> slice_max(value, n = 1)
      best  <- cs |> slice_min(value, n = 1)
      n_above <- sum(cs$value > gr, na.rm = TRUE)
      
      d <- diff_pct_now()
      r <- classify_risk(d)
      rk <- current_rank()
      n_states <- nrow(rank_tbl())
      
      txt <- sprintf(
        "Höchste Mortalität: <b>%s</b> (%s).<br>
         Niedrigste Mortalität: <b>%s</b> (%s).<br>
         Bundesdurchschnitt: <b>%s</b>.<br>
         <b>%d von %d Ländern</b> liegen über dem Bundesdurchschnitt.<br><br>
         <b>Ausgewähltes Bundesland:</b> %s<br>
         Abweichung vom Bund: <b>%s%.1f%%</b><br>
         Risikogruppe: <b>%s</b><br>
         Rang: <b>%s von %d</b>",
        worst$region[1], round(worst$value[1], 1),
        best$region[1],  round(best$value[1], 1),
        round(gr, 1), n_above, nrow(cs),
        state_name(),
        if (!is.na(d) && d >= 0) "+" else "",
        ifelse(is.na(d), 0, d),
        r$label,
        ifelse(is.na(rk), "—", rk), n_states)
      
      interpretation_card("Lesehilfe Karte", txt, icon = "map")
    })
    
    # ========================================================================
    # Dumbbell
    # ========================================================================
    output$cv_top10 <- renderGirafe({
      plot_d <- top10_data() |>
        dplyr::filter(!is.na(gap_abs)) |>
        dplyr::arrange(gap_abs) |>
        dplyr::mutate(short_label = factor(short_label,
                                           levels = unique(short_label)))
      req(nrow(plot_d) > 0)
      
      gg <- ggplot(plot_d, aes(y = short_label)) +
        geom_segment(aes(x = de_val, xend = val, yend = short_label),
                     color = "grey65", linewidth = 1.4) +
        geom_point_interactive(
          aes(x = de_val,
              tooltip = paste0("<b>Deutschland</b><br>", icd_bezeichnung,
                               "<br>", round(de_val, 1)),
              data_id = paste0("de_", icd_code)),
          color = "#f59e0b", size = 4.2) +
        geom_point_interactive(
          aes(x = val,
              tooltip = paste0("<b>", state, "</b><br>", icd_bezeichnung,
                               "<br>", round(val, 1),
                               "<br>Δ ", ifelse(gap >= 0, "+", ""),
                               round(gap, 1)),
              data_id = paste0("st_", icd_code)),
          color = "#0d9488", size = 4.2) +
        theme_clinical(base_size = 9) +
        labs(x = metric_lbl(), y = NULL,
             title = paste0("Diagnosen mit größter Abweichung — ",
                            plot_d$state[1], " vs. Bund"),
             caption = "● Orange = Deutschland    ● Türkis = Bundesland") +
        theme(panel.grid.major.y = element_blank(),
              plot.caption = element_text(
                color = if (theme_mode() == "light") "#64748b" else "#94a3b8",
                size = 8, hjust = 0))
      
      girafe(ggobj = gg, width_svg = 8, height_svg = 6,
             options = list(
               opts_hover(css = "stroke:#2dd4bf;stroke-width:2;cursor:pointer;"),
               opts_toolbar(saveaspng = FALSE),
               opts_tooltip(css = "background:#0b1326;color:#f8fafc;padding:6px 10px;border-radius:6px;")))
    })
    
    # ========================================================================
    # Contribution
    # ========================================================================
    output$cv_contribution <- renderGirafe({
      d <- top10_data() |>
        dplyr::filter(!is.na(gap), gap > 0) |>
        dplyr::arrange(dplyr::desc(gap)) |>
        dplyr::slice_head(n = 8) |>
        dplyr::mutate(
          short_label = factor(short_label,
                               levels = rev(unique(short_label))),
          pct = ifelse(!is.na(de_val) & de_val > 0,
                       100 * gap / de_val, NA))
      
      validate(need(nrow(d) > 0,
                    "Keine Diagnose in dieser Auswahl liegt über dem Bundesdurchschnitt."))
      
      gg <- ggplot(d, aes(x = gap, y = short_label)) +
        geom_col_interactive(
          aes(tooltip = paste0("<b>", icd_bezeichnung, "</b><br>",
                               "Beitrag zur erhöhten Mortalität: +", round(gap, 1),
                               "<br>", round(pct, 1), "% über Bund")),
          fill = "#ef4444", width = 0.65) +
        geom_text(aes(label = paste0("+", round(pct, 0), "%")),
                  hjust = -0.12, size = 3, fontface = "bold",
                  color = if (theme_mode() == "light") "#7f1d1d" else "#fca5a5") +
        scale_x_continuous(expand = expansion(mult = c(0, .25))) +
        theme_clinical(base_size = 9) +
        labs(x = "Beitrag zur erhöhten Mortalität (vs. Bund)", y = NULL,
             title = paste0("Beitrag zur erhöhten Mortalität — ", state_name())) +
        theme(panel.grid.major.y = element_blank())
      
      girafe(ggobj = gg, width_svg = 8, height_svg = 6,
             options = list(
               opts_hover(css = "stroke:#fca5a5;stroke-width:2;cursor:pointer;"),
               opts_toolbar(saveaspng = FALSE),
               opts_tooltip(css = "background:#0b1326;color:#f8fafc;padding:6px 10px;border-radius:6px;")))
    })
    
    # ========================================================================
    # Donut
    # ========================================================================
    output$cv_cause_pie <- plotly::renderPlotly({
      yr <- as.integer(input$cv_year)
      sc <- selected_state()
      req(length(sc) > 0, !is.na(sc[1]))
      
      is_light <- theme_mode() == "light"
      paper_bg <- if (is_light) "#e2e8f0" else "#172442"
      font_col <- if (is_light) "#1e293b" else "#cbd5e1"
      
      pie_full <- causes_data |>
        dplyr::filter(bundesland_code == sc[1], jahr == yr,
                      !is.na(icd_code), nzchar(icd_code)) |>
        dplyr::mutate(val = suppressWarnings(as.numeric(.data[[input$cv_metric]]))) |>
        dplyr::filter(!is.na(val), val > 0) |>
        dplyr::arrange(dplyr::desc(val))
      
      validate(need(nrow(pie_full) > 0,
                    paste0("Keine Daten für ", sc[1], " / ", yr, ".")))
      
      shorten <- function(x) {
        x <- gsub("^[A-Z]\\d{2}-[A-Z]?\\d{0,2}\\s+", "", x)
        x <- gsub("Krankheiten des ", "", x)
        x <- gsub("Bösartige Neubildungen", "Bösart. Neubild.", x)
        x <- gsub("Ischämische Herzkrankheiten", "Ischäm. Herzkrankh.", x)
        x <- gsub("Sonstige Formen der Herzkrankheiten", "Sonst. Herzkrankh.", x)
        x <- gsub("Hypertonie \\(Hochdruckkrankheit\\)", "Hypertonie", x)
        ifelse(nchar(x) > 28, paste0(substr(x, 1, 27), "…"), x)
      }
      
      top8 <- pie_full |>
        dplyr::slice_head(n = 8) |>
        dplyr::mutate(short_label = shorten(icd_bezeichnung)) |>
        dplyr::select(short_label, val)
      
      rest <- pie_full |> dplyr::slice(-(1:8))
      
      pie_d <- if (nrow(rest) > 0) {
        dplyr::bind_rows(
          top8,
          tibble::tibble(short_label = "Andere Ursachen",
                         val = sum(rest$val, na.rm = TRUE))
        )
      } else top8
      
      total_val <- sum(pie_d$val, na.rm = TRUE)
      
      plotly::plot_ly(
        data           = pie_d,
        labels         = ~short_label,
        values         = ~val,
        type           = "pie",
        hole           = 0.45,
        sort           = FALSE,
        direction      = "clockwise",
        textinfo       = "percent",
        textposition   = "inside",
        hoverinfo      = "label+value+percent",
        textfont       = list(size = 11, color = "#ffffff"),
        marker         = list(
          line = list(color = if (is_light) "#ffffff" else "#172442", width = 2)
        ),
        domain         = list(x = c(0, 0.58), y = c(0, 1))
      ) |>
        plotly::layout(
          title = list(
            text = paste0("Verteilung der Todesursachen — ",
                          state_name(), " (", yr, ")"),
            font = list(color = if (is_light) "#0f172a" else "#f8fafc",
                        size = 13),
            x = 0.02, xanchor = "left"
          ),
          showlegend = TRUE,
          legend = list(
            orientation = "v",
            x = 0.62, xanchor = "left",
            y = 0.5,  yanchor = "middle",
            font      = list(size = 10, color = font_col),
            bgcolor   = "rgba(0,0,0,0)",
            itemsizing = "constant"
          ),
          annotations = list(
            list(
              text      = paste0("<b>", round(total_val, 0), "</b><br>",
                                 metric_lbl()),
              x = 0.29, y = 0.5,
              xref = "paper", yref = "paper",
              showarrow = FALSE,
              font = list(size = 11, color = font_col)
            )
          ),
          paper_bgcolor = paper_bg,
          plot_bgcolor  = paper_bg,
          font = list(color = font_col, family = "Hanken Grotesk, sans-serif"),
          margin = list(l = 10, r = 10, t = 40, b = 10)
        )
    })
    
    # ========================================================================
    # Donut interpretation
    # ========================================================================
    output$cv_pie_summary <- renderUI({
      yr <- as.integer(input$cv_year)
      sc <- selected_state()
      req(length(sc) > 0, !is.na(sc[1]))
      
      pie_full <- causes_data |>
        dplyr::filter(bundesland_code == sc[1], jahr == yr,
                      !is.na(icd_code), nzchar(icd_code)) |>
        dplyr::mutate(val = suppressWarnings(as.numeric(.data[[input$cv_metric]]))) |>
        dplyr::filter(!is.na(val), val > 0) |>
        dplyr::arrange(dplyr::desc(val))
      
      req(nrow(pie_full) > 0)
      
      top_row   <- pie_full |> dplyr::slice(1)
      total     <- sum(pie_full$val, na.rm = TRUE)
      top_share <- round(100 * top_row$val / total, 1)
      
      second_row <- if (nrow(pie_full) >= 2) pie_full |> dplyr::slice(2) else NULL
      second_txt <- if (!is.null(second_row)) {
        sprintf(" Zweitgrößte Gruppe: <b>%s</b> (%s%%).",
                second_row$icd_bezeichnung,
                round(100 * second_row$val / total, 1))
      } else ""
      
      txt <- sprintf(
        "Die größte Mortalitätslast entsteht durch <b>%s</b> — das sind <b>%s%%</b> aller Todesfälle in %s (%d).%s<br><br>Diese Diagnosegruppe sollte bei der Interpretation der Gesamtmortalität besonders berücksichtigt werden.",
        top_row$icd_bezeichnung,
        top_share,
        state_name(), yr,
        second_txt)
      
      interpretation_card(
        "Verteilung der Todesursachen",
        txt,
        icon = "chart-pie")
    })
    
    # ========================================================================
    # Ranking
    # ========================================================================
    output$cv_ranking <- renderGirafe({
      rt <- rank_tbl()
      req(nrow(rt) > 0)
      gr <- de_ref()
      
      code_sel <- selected_state()
      code_sel <- if (length(code_sel) == 0) NA_character_ else code_sel[1]
      rt <- rt |> dplyr::mutate(is_sel = bundesland_code == code_sel)
      
      sel_rank <- rt$rank[rt$is_sel]
      sel_rank_txt <- if (length(sel_rank) > 0) sel_rank[1] else "—"
      
      gg <- ggplot(rt, aes(x = value, y = reorder(region, value))) +
        geom_col_interactive(
          aes(fill = is_sel,
              tooltip = paste0("<b>", region, "</b><br>Rang ", rank, " / ", nrow(rt),
                               "<br>", metric_lbl(), ": ", round(value, 1))),
          width = 0.72) +
        geom_text(aes(label = rank), hjust = -0.3, size = 3,
                  fontface = "bold",
                  color = if (theme_mode() == "light") "#334155" else "#cbd5e1") +
        { if (!is.na(gr))
          geom_vline(xintercept = gr, color = "#f59e0b",
                     linetype = "dashed", linewidth = 1.1)
        } +
        scale_fill_manual(values = c("TRUE" = "#0d9488", "FALSE" = "#64748b"),
                          guide = "none") +
        scale_x_continuous(labels = scales::label_comma(),
                           expand = expansion(mult = c(0, .15))) +
        theme_clinical(base_size = 10) +
        labs(x = metric_lbl(), y = NULL,
             title = paste0("Nationales Ranking — ", state_name(),
                            " (Rang ", sel_rank_txt, "/", nrow(rt), ")"),
             caption = "─ ─ Orange gestrichelt = Bundesdurchschnitt") +
        theme(panel.grid.major.y = element_blank(),
              plot.caption = element_text(
                color = if (theme_mode() == "light") "#64748b" else "#94a3b8",
                size = 8, hjust = 0))
      
      girafe(ggobj = gg, width_svg = 8, height_svg = 6,
             options = list(
               opts_hover(css = "stroke:#2dd4bf;stroke-width:2;cursor:pointer;"),
               opts_toolbar(saveaspng = FALSE),
               opts_tooltip(css = "background:#0b1326;color:#f8fafc;padding:6px 10px;border-radius:6px;")))
    })
    
    # ========================================================================
    # Dual bar
    # ========================================================================
    output$cv_dual_bar <- renderGirafe({
      yr <- as.integer(input$cv_year); icd <- input$cv_icd; nm <- state_name()
      sc <- selected_state()
      req(length(sc) > 0, !is.na(sc[1]))
      
      sub <- causes_data |>
        dplyr::filter(icd_bezeichnung == icd |
                        ((is.na(icd_code) | !nzchar(icd_code)) & icd == ALL_LABEL),
                      bundesland_code %in% c(sc[1], "DE"),
                      jahr == yr) |>
        dplyr::mutate(
          crude  = suppressWarnings(as.numeric(sterbefaelle_je_100k)),
          std    = suppressWarnings(as.numeric(sterbefaelle_je_100k_altersstand)),
          entity = ifelse(bundesland_code == "DE",
                          "🇩🇪 Deutschland", paste0("📍 ", nm))) |>
        dplyr::select(entity, crude, std) |>
        tidyr::pivot_longer(c(crude, std), names_to = "type", values_to = "val") |>
        dplyr::mutate(type = ifelse(type == "crude", "Rohe Rate", "Altersstandardisiert"))
      req(nrow(sub) > 0)
      
      gg <- ggplot(sub, aes(x = entity, y = val, fill = type,
                            tooltip = paste0(entity, "\n", type, ": ", round(val, 1)))) +
        geom_col_interactive(position = position_dodge(0.7), width = 0.55) +
        scale_fill_manual(values = c("Rohe Rate" = "#38bdf8",
                                     "Altersstandardisiert" = "#0d9488")) +
        theme_clinical(base_size = 10) +
        labs(x = NULL, y = "Rate / 100k", fill = NULL,
             title = "Rohe vs. Standardisierte Raten")
      
      girafe(ggobj = gg, width_svg = 8, height_svg = 5,
             options = list(opts_toolbar(saveaspng = FALSE)))
    })
    
    output$cv_age_gap_kpi <- renderUI({
      d <- chapter_all_years() |>
        filter(bundesland_code == selected_state(),
               jahr == as.integer(input$cv_year))
      crude <- suppressWarnings(as.numeric(d$sterbefaelle_je_100k[1]))
      std   <- suppressWarnings(as.numeric(d$sterbefaelle_je_100k_altersstand[1]))
      if (is.na(crude) || is.na(std)) return(NULL)
      
      gap <- crude - std
      tone <- if (gap > 0) "kpi-diff-neg" else "kpi-diff-pos"
      txt <- if (gap > 0) {
        "Die rohe Rate liegt über der standardisierten — die Bevölkerung ist im Schnitt älter als der Bundesdurchschnitt."
      } else {
        "Die rohe Rate liegt unter der standardisierten — die Bevölkerung ist im Schnitt jünger als der Bundesdurchschnitt."
      }
      
      body <- sprintf(
        "Roh: <b>%s</b> · Standardisiert: <b>%s</b><br>Differenz: <span class='%s'><b>%s%s</b></span><br><br>%s",
        round(crude, 1), round(std, 1),
        tone, if (gap > 0) "+" else "", round(gap, 1), txt)
      
      interpretation_card("Einfluss der Altersstruktur", body, icon = "scale-balanced")
    })
    
    # ========================================================================
    # Trend + trend summary
    # ========================================================================
    output$cv_trend <- renderGirafe({
      nm <- state_name()
      sc <- selected_state()
      req(length(sc) > 0, !is.na(sc[1]))
      
      trend_d <- chapter_all_years() |>
        dplyr::filter(bundesland_code %in% c(sc[1], "DE")) |>
        dplyr::mutate(entity = ifelse(bundesland_code == "DE", "Deutschland", nm)) |>
        dplyr::arrange(jahr)
      req(nrow(trend_d) > 0)
      
      gg <- ggplot(trend_d, aes(x = jahr, y = value, color = entity,
                                group = entity, linetype = entity)) +
        geom_line_interactive(
          aes(tooltip = paste0(entity, " (", jahr, "): ", round(value, 1))),
          linewidth = 1.3) +
        geom_point_interactive(
          aes(tooltip = paste0(entity, " (", jahr, "): ", round(value, 1))),
          size = 2.8) +
        scale_color_manual(values = c("Deutschland" = "#f59e0b",
                                      setNames("#0d9488", nm))) +
        scale_linetype_manual(values = c("Deutschland" = "dashed",
                                         setNames("solid", nm))) +
        scale_x_continuous(breaks = c(2021, 2022, 2023, 2024)) +
        theme_clinical(base_size = 10) +
        labs(x = NULL, y = metric_lbl(), color = NULL, linetype = NULL,
             title = "Verlauf 2021–2024") +
        theme(legend.position = "top", panel.grid.minor = element_blank())
      
      girafe(ggobj = gg, width_svg = 8, height_svg = 5,
             options = list(opts_toolbar(saveaspng = FALSE)))
    })
    
    output$cv_trend_summary <- renderUI({
      sc <- selected_state()
      req(length(sc) > 0, !is.na(sc[1]))
      
      d <- chapter_all_years() |>
        dplyr::filter(bundesland_code == sc[1]) |>
        dplyr::arrange(jahr) |>
        dplyr::filter(!is.na(value))
      req(nrow(d) >= 2)
      
      start <- d$value[1]; end <- d$value[nrow(d)]
      change <- if (!is.na(start) && start != 0)
        round(100 * (end - start) / start, 1) else NA
      
      d_de <- chapter_all_years() |>
        dplyr::filter(bundesland_code == "DE") |>
        dplyr::arrange(jahr) |>
        dplyr::filter(!is.na(value))
      change_de <- if (nrow(d_de) >= 2 && d_de$value[1] != 0)
        round(100 * (d_de$value[nrow(d_de)] - d_de$value[1]) / d_de$value[1], 1) else NA
      
      if (is.na(change)) {
        return(interpretation_card("Trend interpretation",
                                   "Nicht genügend Daten für eine Trendaussage.",
                                   icon = "chart-line"))
      }
      
      direction <- if (change > 0) "gestiegen" else "gesunken"
      arrow     <- if (change > 0) "▲" else "▼"
      color     <- if (change > 0) "#ef4444" else "#10b981"
      
      comparison <- if (!is.na(change_de)) {
        if (change > change_de)
          "Der Anstieg fällt <b>stärker aus als im Bundesdurchschnitt</b> — die relative Position verschlechtert sich."
        else if (change < change_de)
          "Die Entwicklung verläuft <b>günstiger als im Bundesdurchschnitt</b> — die relative Position verbessert sich."
        else "Die Entwicklung entspricht dem Bundesdurchschnitt."
      } else ""
      
      de_txt <- if (!is.na(change_de))
        paste0(if (change_de > 0) "+" else "", change_de, "%") else "—"
      
      txt <- sprintf(
        "<b>%s</b> ist zwischen <b>%d</b> und <b>%d</b> um <span style='color:%s; font-weight:700;'>%s %.1f%%</span> %s.<br>Bundesdurchschnitt im selben Zeitraum: <b>%s</b>.<br><br>%s",
        state_name(), min(d$jahr), max(d$jahr),
        color, arrow, abs(change), direction,
        de_txt, comparison)
      
      interpretation_card("Trend interpretation", txt, icon = "chart-line")
    })
    
    # ========================================================================
    # Diagnosis info
    # ========================================================================
    output$cv_diagnosis_info <- renderUI({
      icd <- input$cv_icd
      if (is.null(icd) || !nzchar(icd)) return(NULL)
      
      if (icd == ALL_LABEL) {
        return(interpretation_card(
          "Gesamtmortalität",
          paste0("<ul style='margin-bottom:0; padding-left:18px;'>",
                 "<li>Gesamtmortalität umfasst alle registrierten Todesursachen.</li>",
                 "<li>Vergleiche sollten bevorzugt mit altersstandardisierten Raten durchgeführt werden.</li>",
                 "<li>Die rohe Rate ist anfällig für Altersstruktureffekte.</li>",
                 "</ul>"),
          icon = "circle-info"))
      }
      
      code <- if (icd %in% sapply(AVOIDABLE, `[[`, "code")) icd else NULL
      if (is.null(code)) return(NULL)
      
      text_de <- switch(code,
                        "F10-F19" = list(
                          title = "Warum ist Sucht relevant?",
                          bullets = c("Häufig mit Alkohol, Tabak und illegalen Substanzen verbunden.",
                                      "Ein grosser Teil ist durch Prävention vermeidbar.",
                                      "Frühzeitige Intervention reduziert Sterblichkeit deutlich.")),
                        "K70-K77" = list(
                          title = "Warum sind Lebererkrankungen relevant?",
                          bullets = c("Alkoholbedingte Lebererkrankungen sind weitgehend vermeidbar.",
                                      "Hepatitis-Impfung und Früherkennung senken die Sterblichkeit.",
                                      "Enge Verknüpfung mit sozioökonomischen Faktoren.")),
                        "J40-J47" = list(
                          title = "Warum ist COPD relevant?",
                          bullets = c("Stark mit Rauchen verbunden — teilweise vermeidbar.",
                                      "Frühzeitige Therapie und Raucherentwöhnung senken Sterblichkeit.",
                                      "Häufig unterdiagnostiziert.")),
                        "E10-E14" = list(
                          title = "Warum ist Diabetes relevant?",
                          bullets = c("Gute Blutzuckerkontrolle reduziert Folgeschäden deutlich.",
                                      "Strukturierte Disease-Management-Programme sind wirksam.",
                                      "Eng mit Adipositas und Bewegungsmangel verknüpft.")),
                        "S00-T98" = list(
                          title = "Warum sind Verletzungen relevant?",
                          bullets = c("Verkehr, Stürze und Suizide sind zentrale vermeidbare Ursachen.",
                                      "Präventionsprogramme zeigen schnelle Wirkung.",
                                      "Hoher Anteil bei jüngeren Altersgruppen.")),
                        NULL)
      
      if (is.null(text_de)) return(NULL)
      
      interpretation_card(
        text_de$title,
        paste0("<ul style='margin-bottom:0; padding-left:18px;'>",
               paste(sprintf("<li>%s</li>", text_de$bullets), collapse = ""),
               "</ul>"),
        icon = "circle-info")
    })
    
    # ========================================================================
    # Avoidable
    # ========================================================================
    output$cv_avoidable <- renderGirafe({
      yr <- as.integer(input$cv_year); nm <- state_name(); sc <- selected_state()
      req(length(sc) > 0, !is.na(sc[1]))
      
      avoid_codes  <- sapply(AVOIDABLE, `[[`, "code")
      avoid_colors <- sapply(AVOIDABLE, `[[`, "color")
      
      state_av <- causes_data |>
        dplyr::filter(bundesland_code == sc[1], jahr == yr,
                      icd_code %in% avoid_codes) |>
        dplyr::mutate(val = suppressWarnings(as.numeric(.data[[input$cv_metric]])))
      
      de_av <- causes_data |>
        dplyr::filter(bundesland_code == "DE", jahr == yr,
                      icd_code %in% avoid_codes) |>
        dplyr::mutate(de_val = suppressWarnings(as.numeric(.data[[input$cv_metric]]))) |>
        dplyr::select(icd_code, de_val)
      
      plot_d <- state_av |>
        dplyr::left_join(de_av, by = "icd_code") |>
        dplyr::mutate(
          short_label = substr(gsub("^[A-Z]\\d{2}-[A-Z]?\\d{2}\\s+", "",
                                    icd_bezeichnung), 1, 26),
          bar_color   = avoid_colors[match(icd_code, avoid_codes)])
      req(nrow(plot_d) > 0)
      
      gg <- ggplot(plot_d, aes(x = reorder(short_label, val))) +
        geom_col_interactive(
          aes(y = val, fill = bar_color,
              tooltip = paste0(icd_bezeichnung, "\n", nm, ": ", round(val, 1))),
          width = 0.55) +
        geom_point(aes(y = de_val), shape = 23, size = 3.5,
                   fill = "#ffffff", color = "#0b1326", stroke = 1.2) +
        scale_fill_identity() + coord_flip() +
        theme_clinical(base_size = 9) +
        labs(x = NULL, y = metric_lbl(),
             title = paste0("Vermeidbare Mortalität — ", nm),
             caption = "◇ = Bundesdurchschnitt") +
        theme(panel.grid.major.y = element_blank())
      
      girafe(ggobj = gg, width_svg = 8, height_svg = 4,
             options = list(opts_toolbar(saveaspng = FALSE)))
    })
    
    # ========================================================================
    # Executive Summary
    # ========================================================================
    output$cv_policy_insight <- renderUI({
      sv <- state_val(); dv <- de_ref(); nm <- state_name()
      if (is.na(sv) || is.na(dv)) return(NULL)
      
      diff_pct <- diff_pct_now()
      r        <- classify_risk(diff_pct)
      rk       <- current_rank()
      n_states <- nrow(rank_tbl())
      
      drv <- top10_data() |>
        dplyr::filter(!is.na(gap), gap > 0) |>
        dplyr::arrange(dplyr::desc(gap)) |>
        dplyr::slice_head(n = 3)
      
      main_driver <- if (nrow(drv) > 0) drv$short_label[1] else "Keine"
      main_driver_gap <- if (nrow(drv) > 0)
        paste0("+", round(drv$gap[1], 1), " / 100k") else "—"
      
      recommendation <- if (!is.na(diff_pct) && diff_pct > 5 && nrow(drv) > 0) {
        paste0("Präventionsstrategien sollten sich vor allem auf <b>",
               drv$short_label[1], "</b> konzentrieren, da diese Diagnose den",
               " grössten Beitrag zur erhöhten Mortalität leistet.")
      } else if (!is.na(diff_pct) && diff_pct > 0) {
        "Die Abweichung vom Bund ist moderat — bestehende Programme sollten gehalten, aber nicht ausgeweitet werden."
      } else {
        "Die Mortalität liegt unter dem Bundesdurchschnitt — die aktuelle Präventionsstrategie wirkt."
      }
      
      div(class = paste("executive-summary", paste0("exec-risk-", r$level)),
          tags$h4("📋 Executive Summary"),
          
          div(class = "executive-grid",
              div(class = "exec-cell",
                  div(class = "exec-cell-label", "Status"),
                  div(class = paste("exec-cell-value", r$css), r$label)),
              div(class = "exec-cell",
                  div(class = "exec-cell-label", "Abweichung vom Bund"),
                  div(class = paste("exec-cell-value", r$css),
                      paste0(if (!is.na(diff_pct) && diff_pct >= 0) "+" else "",
                             ifelse(is.na(diff_pct), "—", diff_pct), "%"))),
              div(class = "exec-cell",
                  div(class = "exec-cell-label", "Rang"),
                  div(class = "exec-cell-value",
                      ifelse(is.na(rk), "—", paste0(rk, " / ", n_states)))),
              div(class = "exec-cell",
                  div(class = "exec-cell-label", "Haupttreiber"),
                  div(class = "exec-cell-value", main_driver),
                  div(style = "font-size:0.78rem; color:#64748b; margin-top:2px;",
                      paste("Beitrag:", main_driver_gap))),
              div(class = "exec-cell",
                  div(class = "exec-cell-label", "Bundesdurchschnitt"),
                  div(class = "exec-cell-value",
                      paste0(round(dv, 1), " / 100k")))),
          
          div(class = "exec-recommendation",
              tags$b("Empfehlung: "),
              HTML(recommendation)))
    })
  })
}