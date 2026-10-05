# ============================================================
# LäKoSA Server — Version 2 (mit Median-Fix)
# ============================================================

mod_lakosa_server <- function(
    id,
    lakosa_data = NULL,
    lakosa_dict = NULL
) {
  
  moduleServer(id, function(input, output, session) {
    
    ns <- session$ns
    
    SPECIAL_CODES <- c(900, 995, 996, 997, 998)
    
    has_data <- reactive({
      !is.null(lakosa_data) &&
        is.data.frame(lakosa_data) &&
        nrow(lakosa_data) > 0
    })
    
    clean_num <- function(x) {
      v <- suppressWarnings(as.numeric(x))
      v[v %in% SPECIAL_CODES] <- NA
      v
    }
    
    find_col <- function(candidates) {
      hit <- intersect(candidates, names(lakosa_data))
      if (length(hit) == 0) NA_character_ else hit[1]
    }
    
    # --------------------------------------------------------
    # Human-readable labels
    # --------------------------------------------------------
    translate_labels <- function(x, variable) {
      chr <- as.character(x)
      
      if (variable == "Per_Geschlecht") {
        return(dplyr::recode(chr,
                             "1" = "Weiblich",
                             "2" = "Männlich",
                             .default = chr
        ))
      }
      
      if (variable == "Per_KV") {
        return(dplyr::recode(chr,
                             "0" = "Keine Angabe",
                             "1" = "Gesetzlich",
                             "2" = "Privat",
                             .default = chr
        ))
      }
      
      if (variable == "Per_Erwerbssit") {
        return(dplyr::recode(chr,
                             "0" = "Keine Angabe",
                             "1" = "Vollzeit",
                             "2" = "Teilzeit",
                             "3" = "Geringfügig",
                             "4" = "Rentner:in",
                             "5" = "Arbeitssuchend",
                             "6" = "Sonstige",
                             .default = chr
        ))
      }
      
      if (variable == "Per_Wohnsit") {
        return(dplyr::recode(chr,
                             "1" = "Allein",
                             "2" = "Mit Partner:in",
                             "3" = "Mit Familie",
                             "5" = "Betreutes Wohnen",
                             "7" = "Sonstige",
                             .default = chr
        ))
      }
      
      chr
    }
    
    empty_plot <- function(msg) {
      ggplot2::ggplot() +
        ggplot2::annotate("text", x = 0, y = 0, label = msg,
                          size = 5, color = "#64748b") +
        ggplot2::theme_void()
    }
    
    # ========================================================
    # 1. DATASET SUMMARY
    # ========================================================
    output$dataset_summary <- renderUI({
      if (!has_data()) {
        return(div(class = "overview-card",
                   h2("Datensatz nicht verfügbar")))
      }
      
      age_col <- find_col(c("_derived_age_2024", "Per_Alter", "Per_Age", "Alter"))
      avg_age <- if (!is.na(age_col))
        round(mean(clean_num(lakosa_data[[age_col]]), na.rm = TRUE), 1) else NA
      
      div(
        class = "lakosa-summary-grid",
        div(class = "summary-card",
            h2(format(nrow(lakosa_data), big.mark = ".")),
            p("Teilnehmende")),
        div(class = "summary-card",
            h2(format(ncol(lakosa_data), big.mark = ".")),
            p("Variablen")),
        div(class = "summary-card",
            h2(if (is.na(avg_age)) "–" else avg_age),
            p("Ø Alter (Jahre)"))
      )
    })
    
    # ========================================================
    # 2. STUDY HIGHLIGHTS
    # ========================================================
    output$study_highlights <- renderUI({
      if (!has_data()) return(NULL)
      
      safe_mean <- function(col) {
        if (is.na(col) || !(col %in% names(lakosa_data))) return(NA)
        round(mean(clean_num(lakosa_data[[col]]), na.rm = TRUE), 2)
      }
      
      safe_median <- function(col) {
        if (is.na(col) || !(col %in% names(lakosa_data))) return(NA)
        round(stats::median(clean_num(lakosa_data[[col]]), na.rm = TRUE), 1)
      }
      
      fmt <- function(v, suffix = "") if (is.na(v)) "–" else paste0(v, suffix)
      
      div(
        class = "highlight-grid",
        div(class = "highlight-card",
            h2(fmt(safe_mean("MV_Zufr_HA finden"))),
            p("Ø Hausarztzufriedenheit")),
        div(class = "highlight-card",
            h2(fmt(safe_mean("MV_Zufr_FA finden"))),
            p("Ø Facharztzufriedenheit")),
        div(class = "highlight-card",
            h2(fmt(safe_median("MV_dur_HA"), " min")),
            p("Mediane Fahrzeit Hausarzt")),
        div(class = "highlight-card",
            h2(fmt(safe_mean("MV_freq_Notfall"))),
            p("Ø Notfallnutzung"))
      )
    })
    
    # ========================================================
    # 3. MEDICAL CARE — KPI CARDS
    # ========================================================
    output$care_kpi_cards <- renderUI({
      req(has_data())
      
      avg_of <- function(name) {
        if (!(name %in% names(lakosa_data))) return(NA)
        round(mean(clean_num(lakosa_data[[name]]), na.rm = TRUE), 2)
      }
      
      fmt <- function(v) if (is.na(v)) "–" else format(v, nsmall = 2)
      
      div(
        class = "lakosa-summary-grid",
        div(class = "summary-card",
            h2(fmt(avg_of("MV_Zust"))),
            p("Ø Zugang zur Versorgung")),
        div(class = "summary-card",
            h2(fmt(avg_of("MV_Zufr_HA finden"))),
            p("Ø Zufriedenheit Hausarzt")),
        div(class = "summary-card",
            h2(fmt(avg_of("MV_Zufr_FA finden"))),
            p("Ø Zufriedenheit Facharzt"))
      )
    })
    
    # ========================================================
    # 4. CARE ACCESS PLOT
    # ========================================================
    output$care_access_plot <- renderPlot({
      req(has_data())
      
      items <- c(
        "Hausarzt"      = "MV_Zufr_HA finden",
        "Facharzt"      = "MV_Zufr_FA finden",
        "Informationen" = "MV_Zufr_Zugang Infos",
        "Notfall"       = "MV_Zufr_Erhalt Notfall"
      )
      
      df <- do.call(rbind, lapply(names(items), function(label) {
        col <- items[[label]]
        if (!(col %in% names(lakosa_data))) return(NULL)
        data.frame(item = label,
                   value = clean_num(lakosa_data[[col]]),
                   stringsAsFactors = FALSE)
      }))
      
      if (is.null(df) || nrow(df) == 0)
        return(empty_plot("Keine Versorgungsdaten gefunden."))
      
      agg <- aggregate(value ~ item, data = df,
                       FUN = function(x) mean(x, na.rm = TRUE))
      
      ggplot2::ggplot(agg,
                      ggplot2::aes(x = stats::reorder(item, value), y = value, fill = item)) +
        ggplot2::geom_col(width = 0.6, show.legend = FALSE) +
        ggplot2::geom_text(ggplot2::aes(label = round(value, 2)),
                           vjust = -0.4, size = 4.2, fontface = "bold") +
        ggplot2::scale_fill_manual(
          values = c("#005ca9", "#087dc2", "#5dd1ff", "#0d9488")) +
        ggplot2::labs(x = NULL, y = "Mittlere Bewertung",
                      title = "Zugang zur Versorgung im Vergleich") +
        ggplot2::theme_minimal(base_size = 13) +
        ggplot2::theme(plot.title = ggplot2::element_text(
          face = "bold", color = "#153b5b"))
    })
    
    # ========================================================
    # 5. GP vs SPECIALIST
    # ========================================================
    output$gp_specialist_plot <- renderPlot({
      req(has_data())
      
      ha <- if ("MV_Zufr_HA finden" %in% names(lakosa_data))
        clean_num(lakosa_data[["MV_Zufr_HA finden"]]) else numeric(0)
      fa <- if ("MV_Zufr_FA finden" %in% names(lakosa_data))
        clean_num(lakosa_data[["MV_Zufr_FA finden"]]) else numeric(0)
      
      df <- rbind(
        data.frame(group = "Hausarzt", value = ha),
        data.frame(group = "Facharzt", value = fa)
      )
      df <- df[!is.na(df$value), ]
      
      if (nrow(df) == 0) return(empty_plot("Keine Vergleichsdaten verfügbar."))
      
      ggplot2::ggplot(df, ggplot2::aes(x = group, y = value, fill = group)) +
        ggplot2::geom_boxplot(width = 0.5, show.legend = FALSE) +
        ggplot2::scale_fill_manual(values = c("#005ca9", "#087dc2")) +
        ggplot2::labs(x = NULL, y = "Zufriedenheit",
                      title = "Zufriedenheit: Hausarzt vs. Facharzt") +
        ggplot2::theme_minimal(base_size = 13) +
        ggplot2::theme(plot.title = ggplot2::element_text(
          face = "bold", color = "#153b5b"))
    })
    
    # ========================================================
    # 6. TRAVEL TIME
    # ========================================================
    output$travel_time_plot <- renderPlot({
      req(has_data())
      
      items <- c(
        "Hausarzt"       = "MV_dur_HA",
        "Internist"      = "MV_dur_Int",
        "Kardiologie"    = "MV_dur_Kard",
        "Augenarzt"      = "MV_dur_Auge",
        "Orthopädie"     = "MV_dur_Ortho",
        "Physiotherapie" = "MV_dur_PPT"
      )
      
      df <- do.call(rbind, lapply(names(items), function(label) {
        col <- items[[label]]
        if (!(col %in% names(lakosa_data))) return(NULL)
        data.frame(item = label,
                   value = clean_num(lakosa_data[[col]]),
                   stringsAsFactors = FALSE)
      }))
      
      if (is.null(df) || nrow(df) == 0)
        return(empty_plot("Keine Fahrzeitdaten gefunden."))
      
      agg <- aggregate(value ~ item, data = df,
                       FUN = function(x) stats::median(x, na.rm = TRUE))
      
      ggplot2::ggplot(agg,
                      ggplot2::aes(x = stats::reorder(item, value), y = value, fill = item)) +
        ggplot2::geom_col(width = 0.6, show.legend = FALSE) +
        ggplot2::geom_text(ggplot2::aes(label = round(value, 1)),
                           hjust = -0.15, size = 4.2, fontface = "bold") +
        ggplot2::scale_fill_manual(
          values = c("#005ca9", "#087dc2", "#2dd4bf",
                     "#0d9488", "#5dd1ff", "#7c3aed")) +
        ggplot2::coord_flip() +
        ggplot2::labs(x = NULL, y = "Mediane Fahrzeit (Minuten)",
                      title = "Fahrzeiten nach medizinischer Einrichtung") +
        ggplot2::theme_minimal(base_size = 13) +
        ggplot2::theme(plot.title = ggplot2::element_text(
          face = "bold", color = "#153b5b"))
    })
    
    # ========================================================
    # 7. UTILISATION
    # ========================================================
    output$utilisation_plot <- renderPlot({
      req(has_data())
      
      items <- c(
        "Notfallversorgung" = "MV_freq_Notfall",
        "Stationär"         = "MV_freq_Station",
        "Ambulanz"          = "MV_Ambulanz"
      )
      
      df <- do.call(rbind, lapply(names(items), function(label) {
        col <- items[[label]]
        if (!(col %in% names(lakosa_data))) return(NULL)
        data.frame(item = label,
                   value = clean_num(lakosa_data[[col]]),
                   stringsAsFactors = FALSE)
      }))
      
      if (is.null(df) || nrow(df) == 0)
        return(empty_plot("Keine Nutzungsdaten gefunden."))
      
      agg <- aggregate(value ~ item, data = df,
                       FUN = function(x) mean(x, na.rm = TRUE))
      
      ggplot2::ggplot(agg,
                      ggplot2::aes(x = stats::reorder(item, value), y = value, fill = item)) +
        ggplot2::geom_col(width = 0.6, show.legend = FALSE) +
        ggplot2::geom_text(ggplot2::aes(label = round(value, 2)),
                           vjust = -0.4, size = 4.2, fontface = "bold") +
        ggplot2::scale_fill_manual(
          values = c("#0d9488", "#087dc2", "#005ca9")) +
        ggplot2::labs(x = NULL, y = "Mittlere Nutzung",
                      title = "Inanspruchnahme medizinischer Leistungen") +
        ggplot2::theme_minimal(base_size = 13) +
        ggplot2::theme(plot.title = ggplot2::element_text(
          face = "bold", color = "#153b5b"))
    })
    
    # ========================================================
    # 7b. WAITING TIME
    # ========================================================
    output$waiting_time_plot <- renderPlot({
      req(has_data())
      
      items <- c(
        "Hausarzt" = "MV_Bew_HA_Termin",
        "Facharzt" = "MV_Bew_FA_Termin"
      )
      
      df <- do.call(rbind, lapply(names(items), function(label) {
        col <- items[[label]]
        if (!(col %in% names(lakosa_data))) return(NULL)
        data.frame(item = label,
                   value = clean_num(lakosa_data[[col]]),
                   stringsAsFactors = FALSE)
      }))
      
      if (is.null(df) || nrow(df) == 0)
        return(empty_plot("Keine Wartezeitdaten gefunden."))
      
      df <- df[!is.na(df$value), ]
      
      ggplot2::ggplot(df, ggplot2::aes(x = item, y = value, fill = item)) +
        ggplot2::geom_boxplot(width = 0.5, show.legend = FALSE) +
        ggplot2::scale_fill_manual(values = c("#005ca9", "#087dc2")) +
        ggplot2::labs(x = NULL, y = "Bewertung Wartezeit",
                      title = "Wartezeiten auf Termine") +
        ggplot2::theme_minimal(base_size = 13) +
        ggplot2::theme(plot.title = ggplot2::element_text(
          face = "bold", color = "#153b5b"))
    })
    
    # ========================================================
    # 8. PARTICIPANT PROFILE — bar helper
    # ========================================================
    bar_categorical <- function(x, variable, title) {
      df <- data.frame(value = as.character(x), stringsAsFactors = FALSE)
      df <- df[
        !is.na(df$value) &
          !(suppressWarnings(as.numeric(df$value)) %in% SPECIAL_CODES),
        , drop = FALSE
      ]
      if (nrow(df) == 0) return(empty_plot("Keine gültigen Werte."))
      
      df$value <- translate_labels(df$value, variable)
      
      ggplot2::ggplot(df, ggplot2::aes(x = forcats::fct_infreq(value))) +
        ggplot2::geom_bar(fill = "#005ca9") +
        ggplot2::labs(title = title, x = NULL, y = "Häufigkeit") +
        ggplot2::theme_minimal(base_size = 13) +
        ggplot2::theme(
          plot.title = ggplot2::element_text(face = "bold", color = "#153b5b"),
          axis.text.x = ggplot2::element_text(angle = 30, hjust = 1)
        )
    }
    
    # --- AGE ---
    output$age_plot <- renderPlot({
      req(has_data())
      col <- find_col(c("_derived_age_2024", "Per_Alter", "Per_Age", "Alter"))
      if (is.na(col)) return(empty_plot("Keine Altersvariable gefunden."))
      
      v <- clean_num(lakosa_data[[col]])
      df <- data.frame(age = v[!is.na(v)])
      
      ggplot2::ggplot(df, ggplot2::aes(x = age)) +
        ggplot2::geom_histogram(bins = 20, fill = "#005ca9", color = "white") +
        ggplot2::labs(title = "Altersverteilung der Teilnehmenden",
                      x = "Alter (Jahre)", y = "Häufigkeit") +
        ggplot2::theme_minimal(base_size = 13) +
        ggplot2::theme(plot.title = ggplot2::element_text(
          face = "bold", color = "#153b5b"))
    })
    
    # --- GENDER ---
    output$gender_plot <- renderPlot({
      req(has_data())
      col <- find_col(c("Per_Geschlecht", "Per_Gender", "Geschlecht"))
      if (is.na(col)) return(empty_plot("Keine Geschlechtsvariable gefunden."))
      bar_categorical(lakosa_data[[col]], col, "Geschlechterverteilung")
    })
    
    # --- EMPLOYMENT ---
    output$employment_plot <- renderPlot({
      req(has_data())
      col <- find_col(c("Per_Erwerbssit", "Per_Erwerb", "Erwerbssituation"))
      if (is.na(col)) return(empty_plot("Keine Erwerbsvariable gefunden."))
      bar_categorical(lakosa_data[[col]], col, "Erwerbssituation")
    })
    
    # --- INSURANCE ---
    output$insurance_plot <- renderPlot({
      req(has_data())
      col <- find_col(c("Per_KV", "Per_Krankenversicherung", "KV"))
      if (is.na(col)) return(empty_plot("Keine Versicherungsvariable gefunden."))
      bar_categorical(lakosa_data[[col]], col, "Krankenversicherung")
    })
    
    # --- LIVING SITUATION (multi-select) ---
    output$living_plot <- renderPlot({
      req(has_data())
      col <- find_col(c("Per_Wohnsit", "Per_Wohnsituation", "Wohnsituation"))
      if (is.na(col)) return(empty_plot("Keine Wohnsituationsvariable gefunden."))
      
      raw <- as.character(lakosa_data[[col]])
      raw <- raw[!is.na(raw)]
      
      codes <- unlist(strsplit(raw, "\\s+"))
      codes <- codes[nzchar(codes)]
      codes <- codes[!(suppressWarnings(as.numeric(codes)) %in% SPECIAL_CODES)]
      
      if (length(codes) == 0)
        return(empty_plot("Keine gültigen Werte."))
      
      labels <- translate_labels(codes, col)
      df <- data.frame(value = labels, stringsAsFactors = FALSE)
      
      ggplot2::ggplot(df, ggplot2::aes(x = forcats::fct_infreq(value))) +
        ggplot2::geom_bar(fill = "#005ca9") +
        ggplot2::labs(title = "Wohnsituation (Mehrfachauswahl)",
                      x = NULL, y = "Anzahl Nennungen") +
        ggplot2::theme_minimal(base_size = 13) +
        ggplot2::theme(
          plot.title = ggplot2::element_text(face = "bold", color = "#153b5b"),
          axis.text.x = ggplot2::element_text(angle = 30, hjust = 1)
        )
    })
    
  })
}