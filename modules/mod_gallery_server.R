mod_gallery_server <- function(id, is_dark = reactive(FALSE)) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # --------------------------------------------------------------------------
    # DATA – Use existing Daten_long from global.R
    # --------------------------------------------------------------------------
    gallery_data <- local({
      if (exists("Daten_long")) {
        d <- Daten_long
        if (inherits(d, "sf")) d <- sf::st_drop_geometry(d)
        d %>%
          mutate(
            year  = suppressWarnings(as.integer(year)),
            value = suppressWarnings(as.numeric(value))
          ) %>%
          filter(!is.na(year), !is.na(value))
      } else {
        stop("Daten_long not found in global environment.")
      }
    })
    
    # --------------------------------------------------------------------------
    # Latitude / zone lookup – use actual centroids from germany_districts
    # --------------------------------------------------------------------------
    # The global object germany_districts exists (from global.R)
    if (exists("germany_districts")) {
      district_centroids <- germany_districts %>%
        sf::st_centroid() %>%
        mutate(lat = sf::st_coordinates(.)[,2]) %>%
        sf::st_drop_geometry() %>%
        select(nuts_id, lat)
    } else {
      # fallback hard-coded table (ensure nuts_id matches)
      district_centroids <- tibble::tibble(
        nuts_id = c("DEE04", "DEE05", "DEE07", "DEE08", "DEE01", "DEE02",
                    "DEE09", "DEE06", "DEE03", "DEE0A", "DEE0B", "DEE0C",
                    "DEE0D", "DEE0E"),
        lat = c(52.85, 51.62, 52.05, 51.15, 51.83, 51.48,
                51.75, 52.20, 52.13, 51.55, 51.45, 51.80,
                52.60, 51.87)
      )
    }
    
    # Add a zone column based on latitude
    zone_lookup <- district_centroids %>%
      mutate(zone = case_when(
        lat > 52.0 ~ "North",
        lat > 51.6 ~ "Mid",
        TRUE ~ "South"
      ))
    
    # Helper to join latitude/zone by nuts_id
    with_lat <- function(d) {
      d %>%
        left_join(zone_lookup, by = "nuts_id")
    }
    
    # --------------------------------------------------------------------------
    # i18n labels – updated to match real indicators
    # --------------------------------------------------------------------------
    i18n <- list(
      en = list(
        ind_pop      = "Population",
        ind_popchg5  = "Pop. change (5yr %)",
        ind_popchg11 = "Pop. change since 2011 (%)",
        ind_births   = "Births (per 1,000)",
        ind_deaths   = "Deaths (per 1,000)",
        ind_natbal   = "Natural balance (per 1,000)",
        ind_inflow   = "In‑migration (per 1,000)",
        ind_outflow  = "Out‑migration (per 1,000)",
        ind_edumig   = "Education migration (per 1,000)",
        note_p1 = "Select an indicator and hover over lines to compare all 14 districts.",
        note_p2 = "Select an indicator and year. Blue = positive, coral = negative. Sorted north–south.",
        note_p3 = "Color intensity shows value magnitude over time. Darker = higher value.",
        note_p4 = "Bubble: X = births per 1,000, Y = pop. change since 2011, size = population.",
        note_p5 = "Lines rise (increase) or fall (decrease) between 2006 and the chosen year.",
        note_p7 = "14 mini‑charts, one per district. Blue = North, Purple = Mid, Red = South.",
        note_p8 = "Sorted geographically. Blue = north, coral = south. Bar length = value.",
        color_type = "Type (city / district)",
        color_ns   = "North–South gradient",
        year_lbl = "Year",
        indicator = "Indicator",
        colour_by = "Colour by",
        right_yr = "Right anchor year"
      ),
      de = list(
        ind_pop      = "Bevölkerung",
        ind_popchg5  = "Bev.-entwicklung (5 J. %)",
        ind_popchg11 = "Bev.-entwicklung seit 2011 (%)",
        ind_births   = "Geburten (je 1.000)",
        ind_deaths   = "Sterbefälle (je 1.000)",
        ind_natbal   = "Natürlicher Saldo (je 1.000)",
        ind_inflow   = "Zuzüge (je 1.000)",
        ind_outflow  = "Fortzüge (je 1.000)",
        ind_edumig   = "Bildungswanderung (je 1.000)",
        note_p1 = "Indikator wählen und über Linien fahren, um alle 14 Kreise zu vergleichen.",
        note_p2 = "Indikator und Jahr wählen. Blau = positiv, Koralle = negativ. Nord–Süd sortiert.",
        note_p3 = "Farbintensität zeigt Wertgröße über Zeit. Dunkler = höherer Wert.",
        note_p4 = "Blase: X = Geburten pro 1.000, Y = Bev.-entwicklung seit 2011, Größe = Bevölkerung.",
        note_p5 = "Linien steigen (Zunahme) oder fallen (Abnahme) zwischen 2006 und dem gewählten Jahr.",
        note_p7 = "14 Mini‑Charts, einer pro Kreis. Blau = Nord, Lila = Mitte, Rot = Süd.",
        note_p8 = "Geografisch sortiert. Blau = Norden, Koralle = Süden. Balkenlänge = Wert.",
        color_type = "Typ (Stadt / Landkreis)",
        color_ns   = "Nord–Süd-Gradient",
        year_lbl = "Jahr",
        indicator = "Indikator",
        colour_by = "Farbe nach",
        right_yr = "Rechter Ankerpunkt"
      )
    )
    
    # Indicator name map – only those present in the Excel file
    IND <- list(
      ind_pop      = "Bevölkerung (Anzahl)",
      ind_popchg11 = "Bevölkerungsentwicklung seit 2011 (%)",
      ind_popchg5  = "Bevölkerungsentwicklung über die letzten 5 Jahre (%)",
      ind_births   = "Geburten (je 1.000 Einwohner:innen)",
      ind_deaths   = "Sterbefälle (je 1.000 Einwohner:innen)",
      ind_natbal   = "Natürlicher Saldo (je 1.000 Einwohner:innen)",
      ind_inflow   = "Zuzüge (je 1.000 Einwohner:innen)",
      ind_outflow  = "Fortzüge (je 1.000 Einwohner:innen)",
      ind_edumig   = "Bildungswanderung (je 1.000 Einwohner:innen)"
    )
    
    # Reactive helpers
    lang <- reactive({ input$lang %||% "en" })
    L    <- reactive({ i18n[[lang()]] })
    
    make_choices <- function(keys, lang_list) {
      setNames(unlist(IND[keys]), unlist(lang_list[keys]))
    }
    
    th <- reactive({
      dark <- isTRUE(is_dark())
      list(
        bg      = if (dark) "#1f2937" else "#ffffff",
        bg2     = if (dark) "#151d2b" else "#fafbff",
        txt     = if (dark) "#e2e8f0" else "#1a3a5c",
        grid    = if (dark) "#334155" else "#e9ecef",
        muted   = if (dark) "#64748b" else "#94a3b8",
        tt_bg   = if (dark) "#0f172a" else "#ffffff",
        tt_txt  = if (dark) "#e2e8f0" else "#1a3a5c",
        na_fill = if (dark) "#374151" else "#e5e7eb"
      )
    })
    
    tt_css <- reactive({
      t <- th()
      paste0("background-color:", t$tt_bg, ";color:", t$tt_txt,
             ";border:1.5px solid #ccc;border-radius:8px;",
             "padding:10px 14px;font-family:sans-serif;font-size:13px;",
             "box-shadow:0 4px 16px rgba(0,0,0,0.18);min-width:140px;")
    })
    
    base_theme <- reactive({
      t <- th()
      theme_minimal(base_size = 11) +
        theme(
          plot.background   = element_rect(fill = t$bg, color = NA),
          panel.background  = element_rect(fill = t$bg, color = NA),
          panel.grid.major  = element_line(color = t$grid, linewidth = 0.4),
          panel.grid.minor  = element_blank(),
          axis.text         = element_text(color = t$txt),
          axis.title        = element_text(color = t$txt, face = "bold", size = 10),
          plot.title        = element_text(color = t$txt, face = "bold", size = 12),
          plot.subtitle     = element_text(color = t$muted, size = 9),
          legend.background = element_rect(fill = t$bg, color = NA),
          legend.text       = element_text(color = t$txt, size = 9),
          legend.title      = element_text(color = t$txt, size = 9),
          strip.text        = element_text(color = t$txt, size = 8.5, face = "bold"),
          strip.background  = element_rect(fill = t$bg2, color = NA)
        )
    })
    
    # Safe data retrieval
    gd <- function(variable_str, yr = NULL) {
      d <- gallery_data %>% filter(variable == variable_str)
      if (!is.null(yr)) d <- d %>% filter(year == as.integer(yr))
      d
    }
    
    ns_pal <- function(n) colorRampPalette(c("#D85A30", "#378ADD"))(n)
    
    girafe_opts <- function() list(
      opts_hover(css = "fill-opacity:0.75;stroke-width:1.5;cursor:pointer;"),
      opts_tooltip(css = tt_css(), use_fill = FALSE,
                   use_cursor_pos = FALSE, offx = 10, offy = -40,
                   delay_mouseover = 0, delay_mouseout = 800),
      opts_toolbar(saveaspng = FALSE),
      opts_sizing(rescale = TRUE)
    )
    
    # Update selects on language change
    observeEvent(lang(), {
      l <- L()
      updateSelectInput(session, "p1_indicator",
                        choices = make_choices(names(IND), l),
                        selected = IND$ind_pop)
      updateSelectInput(session, "p2_indicator",
                        choices = make_choices(c("ind_inflow"), l),
                        selected = IND$ind_inflow)
      updateSelectInput(session, "p3_indicator",
                        choices = make_choices(c("ind_pop", "ind_births", "ind_deaths", "ind_natbal"), l),
                        selected = IND$ind_pop)
      updateSelectInput(session, "p5_indicator",
                        choices = make_choices(c("ind_pop", "ind_births", "ind_deaths"), l),
                        selected = IND$ind_pop)
      updateSelectInput(session, "p7_indicator",
                        choices = make_choices(names(IND), l),
                        selected = IND$ind_pop)
      updateSelectInput(session, "p8_indicator",
                        choices = make_choices(names(IND), l),
                        selected = IND$ind_pop)
      updateSelectInput(session, "p4_color",
                        choices = setNames(c("type", "ns"), c(l$color_type, l$color_ns)))
    })
    
    # Note outputs (skip note_p6)
    for (i in c(1,2,3,4,5,7,8)) {
      local({
        ii <- i
        output[[paste0("note_p", ii)]] <- renderUI({
          key <- paste0("note_p", ii)
          tags$p(style = "font-size:0.78rem;color:#667788;font-style:italic;margin:4px 0 10px 0;",
                 L()[[key]])
        })
      })
    }
    
    # --------------------------------------------------------------------------
    # PLOT 1 – Multi-line trend
    # --------------------------------------------------------------------------
    output$p1_plot <- renderGirafe({
      req(input$p1_indicator)
      d <- gd(input$p1_indicator)
      validate(need(nrow(d) > 0, "No data for this indicator."))
      
      pal14 <- c("#1565C0","#D84315","#2E7D32","#6A1B9A","#00838F",
                 "#F57F17","#4527A0","#AD1457","#00695C","#37474F",
                 "#1976D2","#C62828","#558B2F","#4E342E")
      regions <- sort(unique(d$nuts_name))
      col_map <- setNames(pal14[seq_along(regions)], regions)
      
      gg <- ggplot(d, aes(x = year, y = value, color = nuts_name, group = nuts_name)) +
        geom_line_interactive(aes(tooltip = paste0("<b>", nuts_name, "</b><br>", year, ": ", round(value, 1)),
                                  data_id = nuts_name), linewidth = 1.1) +
        geom_point_interactive(aes(tooltip = paste0("<b>", nuts_name, "</b><br>", year, ": ", round(value, 1)),
                                   data_id = nuts_name), size = 2) +
        scale_color_manual(values = col_map) +
        scale_x_continuous(breaks = seq(2006, 2023, 3)) +
        scale_y_continuous(labels = scales::comma) +
        base_theme() +
        theme(legend.position = "right", legend.key.height = unit(0.45, "cm")) +
        labs(title = names(which(unlist(IND) == input$p1_indicator)),
             subtitle = "2006–2023", x = NULL, y = NULL, color = NULL)
      
      girafe(ggobj = gg, width_svg = 11, height_svg = 5, options = girafe_opts())
    })
    
    # --------------------------------------------------------------------------
    # PLOT 2 – Diverging bar (using migration inflow)
    # --------------------------------------------------------------------------
    output$p2_plot <- renderGirafe({
      req(input$p2_indicator, input$p2_year)
      d <- gd(input$p2_indicator, input$p2_year) %>% with_lat()
      validate(need(nrow(d) > 0 && any(!is.na(d$value)), "No data for this indicator/year."))
      d <- d[order(-d$lat), ]
      d$nuts_name <- factor(d$nuts_name, levels = d$nuts_name)
      d$bar_col <- ifelse(d$value >= 0, "#378ADD", "#D85A30")
      
      gg <- ggplot(d, aes(x = value, y = nuts_name)) +
        geom_vline(xintercept = 0, color = "#94a3b8", linewidth = 0.8) +
        geom_col_interactive(aes(fill = bar_col,
                                 tooltip = paste0("<b>", nuts_name, "</b><br>", round(value, 2)),
                                 data_id = as.character(nuts_name)), width = 0.72) +
        geom_text(aes(label = round(value, 1), hjust = ifelse(value >= 0, -0.2, 1.2)),
                  color = th()$txt, size = 3) +
        scale_fill_identity() +
        base_theme() +
        theme(panel.grid.major.y = element_blank(), legend.position = "none") +
        labs(title = paste(input$p2_year), subtitle = "▲ North — ▼ South", x = NULL, y = NULL)
      
      girafe(ggobj = gg, width_svg = 10, height_svg = 6, options = girafe_opts())
    })
    
    # --------------------------------------------------------------------------
    # PLOT 3 – Heatmap (simple – works for any indicator)
    # --------------------------------------------------------------------------
    output$p3_plot <- renderGirafe({
      req(input$p3_indicator)
      d <- gd(input$p3_indicator) %>% with_lat()
      validate(need(nrow(d) > 0, "No data for this indicator."))
      d <- d[order(-d$lat), ]
      d$nuts_name <- factor(d$nuts_name, levels = unique(d$nuts_name))
      
      gg <- ggplot(d, aes(x = year, y = nuts_name, fill = value)) +
        geom_tile_interactive(aes(tooltip = paste0("<b>", nuts_name, "</b><br>", year, ": ", round(value, 1)),
                                  data_id = paste0(nuts_name, year)),
                              color = th()$bg, linewidth = 0.4) +
        scale_fill_viridis_c(option = "inferno", na.value = th()$na_fill, labels = scales::comma) +
        scale_x_continuous(breaks = seq(2006, 2023, 2)) +
        base_theme() +
        theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45, hjust = 1)) +
        labs(title = NULL, subtitle = "▲ North → ▼ South", x = NULL, y = NULL, fill = NULL)
      
      girafe(ggobj = gg, width_svg = 11, height_svg = 6, options = girafe_opts())
    })
    
    # --------------------------------------------------------------------------
    # PLOT 4 – Bubble chart (X = births, Y = pop change since 2011, size = population)
    # --------------------------------------------------------------------------
    output$p4_plot <- renderGirafe({
      req(input$p4_year, input$p4_color)
      yr <- as.integer(input$p4_year)
      
      pop_d <- gd(IND$ind_pop, yr) %>% select(nuts_id, nuts_name, value) %>% rename(pop = value)
      births_d <- gd(IND$ind_births, yr) %>% select(nuts_id, value) %>% rename(birth_rate = value)
      chg_d <- gd(IND$ind_popchg11, yr) %>% select(nuts_id, value) %>% rename(pop_chg = value)
      
      validate(need(nrow(pop_d) > 0 && nrow(births_d) > 0, "No data for this year."))
      
      d <- pop_d %>%
        left_join(births_d, by = "nuts_id") %>%
        left_join(chg_d, by = "nuts_id") %>%
        with_lat()
      d <- d[!is.na(d$lat), ]
      
      d$vtype <- ifelse(d$nuts_name %in% c("Magdeburg", "Halle (Saale)", "Dessau-Roßlau"), "City", "Landkreis")
      d$lat_norm <- (d$lat - min(d$lat, na.rm = TRUE)) / (max(d$lat, na.rm = TRUE) - min(d$lat, na.rm = TRUE))
      d$fill_col <- if (input$p4_color == "type") {
        ifelse(d$vtype == "City", "#D84315", "#1565C0")
      } else {
        colorRampPalette(c("#D85A30", "#378ADD"))(100)[pmax(1, round(d$lat_norm * 99) + 1)]
      }
      
      gg <- ggplot(d, aes(x = birth_rate, y = pop_chg)) +
        geom_hline(yintercept = 0, color = "#94a3b8", linewidth = 0.8, linetype = "dashed") +
        geom_point_interactive(aes(size = pop / 1000, fill = fill_col,
                                   tooltip = paste0("<b>", nuts_name, "</b><br>",
                                                    "Birth rate: ", round(birth_rate, 1), " per 1,000<br>",
                                                    "Pop. change: ", round(pop_chg, 1), "%<br>",
                                                    "Population: ", scales::comma(round(pop)))),
                               shape = 21, color = "white", stroke = 0.8, alpha = 0.85) +
        geom_text(aes(label = nuts_name), size = 2.6, vjust = -1.2, color = th()$muted, check_overlap = TRUE) +
        scale_fill_identity() +
        scale_size_continuous(range = c(4, 18), labels = function(x) paste0(x, "k")) +
        base_theme() +
        theme(legend.position = "bottom") +
        labs(title = as.character(yr),
             subtitle = "Bubble = population size | X = births per 1,000 | Y = % change since 2011",
             x = "Births (per 1,000 population)", y = "Pop. change since 2011 (%)", size = "Pop. (thousands)")
      
      girafe(ggobj = gg, width_svg = 10, height_svg = 6, options = girafe_opts())
    })
    
    # --------------------------------------------------------------------------
    # PLOT 5 – Slope chart (using pivot_longer instead of reshape)
    # --------------------------------------------------------------------------
    output$p5_plot <- renderGirafe({
      req(input$p5_indicator, input$p5_year)
      right_yr <- as.integer(input$p5_year)
      
      d_l <- gd(input$p5_indicator, 2006) %>% select(nuts_name, nuts_id, value) %>% rename(v2006 = value)
      d_r <- gd(input$p5_indicator, right_yr) %>% select(nuts_name, nuts_id, value) %>% rename(vend = value)
      
      d <- d_l %>% left_join(d_r, by = c("nuts_name", "nuts_id"))
      d <- d[!is.na(d$v2006) & !is.na(d$vend), ]
      d$chg <- d$vend - d$v2006
      validate(need(nrow(d) > 0, "No data for this combination."))
      
      # Pivot longer to create two rows per district
      slope_df <- d %>%
        tidyr::pivot_longer(cols = c(v2006, vend),
                            names_to = "side",
                            values_to = "val") %>%
        mutate(x_pos = ifelse(side == "vend", 1L, 0L))
      
      # Extract vectors for tooltips
      chg_vec  <- setNames(d$chg, d$nuts_name)
      v06_vec  <- setNames(d$v2006, d$nuts_name)
      vend_vec <- setNames(d$vend, d$nuts_name)
      
      gg <- ggplot(slope_df, aes(x = x_pos, y = val, group = nuts_name, color = chg_vec[nuts_name])) +
        geom_line_interactive(aes(tooltip = paste0("<b>", nuts_name, "</b><br>",
                                                   "2006: ", round(v06_vec[nuts_name], 1), "<br>",
                                                   right_yr, ": ", round(vend_vec[nuts_name], 1), "<br>",
                                                   "Δ ", round(chg_vec[nuts_name], 1)),
                                  data_id = nuts_name), linewidth = 1.3) +
        geom_point(size = 2.8) +
        geom_text(data = slope_df[slope_df$x_pos == 0, ], aes(label = nuts_name, x = -0.06),
                  hjust = 1, size = 2.6, color = th()$txt) +
        geom_text(data = slope_df[slope_df$x_pos == 1, ],
                  aes(label = paste0(round(val, 1), " (", ifelse(chg_vec[nuts_name] > 0, "+", ""),
                                     round(chg_vec[nuts_name], 1), ")"), x = 1.06),
                  hjust = 0, size = 2.6, color = th()$txt) +
        scale_color_gradient2(low = "#D85A30", mid = "#94a3b8", high = "#378ADD", midpoint = 0) +
        scale_x_continuous(limits = c(-0.7, 1.75), breaks = c(0L, 1L), labels = c("2006", as.character(right_yr))) +
        base_theme() +
        theme(panel.grid.major.x = element_blank(), legend.position = "right") +
        labs(title = paste("2006 vs", right_yr), subtitle = "Blue = increase | Coral = decrease",
             x = NULL, y = NULL, color = "Δ")
      
      girafe(ggobj = gg, width_svg = 10, height_svg = 6, options = girafe_opts())
    })
    
    # PLOT 6 – REMOVED
    
    # --------------------------------------------------------------------------
    # PLOT 7 – Small multiples
    # --------------------------------------------------------------------------
    output$p7_plot <- renderPlot({
      req(input$p7_indicator)
      d <- gd(input$p7_indicator) %>% with_lat()
      validate(need(nrow(d) > 0, "No data for this indicator."))
      d <- d[order(-d$lat), ]
      d$nuts_short <- sub(", LK$", "", d$nuts_name)
      d$nuts_short <- factor(d$nuts_short, levels = unique(d$nuts_short))
      zone_cols <- c("North" = "#1565C0", "Mid" = "#5E35B1", "South" = "#D84315")
      d$zone[is.na(d$zone)] <- "Mid"
      
      ggplot(d, aes(x = year, y = value, color = zone, group = nuts_short)) +
        geom_area(aes(fill = zone), alpha = 0.12) +
        geom_line(linewidth = 0.9) +
        geom_point(size = 1.2) +
        scale_color_manual(values = zone_cols, guide = "none") +
        scale_fill_manual(values = zone_cols, guide = "none") +
        scale_x_continuous(breaks = c(2006, 2012, 2018, 2023), labels = c("'06", "'12", "'18", "'23")) +
        scale_y_continuous(labels = scales::comma) +
        facet_wrap(~nuts_short, ncol = 4, scales = "free_y") +
        base_theme() +
        theme(strip.text = element_text(size = 7.5, face = "bold"), axis.text = element_text(size = 7)) +
        labs(title = NULL, subtitle = "Blue=North | Purple=Mid | Red=South", x = NULL, y = NULL)
    }, res = 120, bg = "transparent")
    
    # --------------------------------------------------------------------------
    # PLOT 8 – North-South ranked bar
    # --------------------------------------------------------------------------
    output$p8_plot <- renderGirafe({
      req(input$p8_indicator, input$p8_year)
      d <- gd(input$p8_indicator, input$p8_year) %>% with_lat()
      validate(need(nrow(d) > 0, "No data for this combination."))
      d <- d[order(-d$lat), ]
      d$nuts_name <- factor(d$nuts_name, levels = d$nuts_name)
      d$fill_col <- ns_pal(nrow(d))[rev(seq_len(nrow(d)))]
      
      gg <- ggplot(d, aes(x = value, y = nuts_name, fill = fill_col)) +
        geom_col_interactive(aes(tooltip = paste0("<b>", nuts_name, "</b><br>", round(value, 2)),
                                 data_id = as.character(nuts_name)), width = 0.72) +
        geom_text(aes(label = round(value, 1), x = value + max(abs(d$value), na.rm = TRUE) * 0.025),
                  hjust = 0, size = 3, color = th()$txt) +
        scale_fill_identity() +
        annotate("text", x = Inf, y = nrow(d) * 0.96, label = "▲ North", hjust = 1.2, vjust = 1,
                 size = 3.5, color = "#378ADD", fontface = "bold") +
        annotate("text", x = Inf, y = nrow(d) * 0.04, label = "▼ South", hjust = 1.2, vjust = 0,
                 size = 3.5, color = "#D85A30", fontface = "bold") +
        base_theme() +
        theme(panel.grid.major.y = element_blank(), legend.position = "none") +
        labs(title = as.character(input$p8_year), subtitle = "▲ North (blue) → ▼ South (coral)",
             x = NULL, y = NULL)
      
      girafe(ggobj = gg, width_svg = 10, height_svg = 6, options = girafe_opts())
    })
    
    # Selection handling
    selected_proto <- reactiveVal(NULL)
    lapply(c(1,2,3,4,5,7,8), function(i) {
      observeEvent(input[[paste0("select_", i)]], {
        selected_proto(as.character(i))
        session$sendCustomMessage(ns("highlight_selected"), as.character(i))
      })
    })
    
    output$selected_label <- renderUI({
      req(selected_proto())
      tags$span(style = "color:#1e7a5e;font-weight:700;font-size:0.95rem;",
                paste0("Selected prototype ", selected_proto()))
    })
    
    return(reactive(selected_proto()))
  })
}