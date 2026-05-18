# ============================================================
# global_additions.R
# Central dark-mode CSS + shared UI helpers
# ============================================================

dark_mode_css <- function() {
  tags$style(HTML("

    /* ── CSS custom properties (light defaults) ── */
    :root {
      --bg-page:        #f0f4f8;
      --bg-card:        #ffffff;
      --bg-card2:       #f8fafc;
      --bg-controls:    linear-gradient(135deg,#1a3a5c 0%,#2563a8 60%,#1e7a5e 100%);
      --bg-info-badge:  linear-gradient(135deg,#fffbeb 0%,#fff3cd 100%);
      --bg-kpi:         linear-gradient(135deg,#f0f6ff 0%,#e8f0fb 100%);
      --bg-plot-wrap:   #fafbff;
      --bg-table-head:  #1a3a5c;

      --txt-primary:    #1a3a5c;
      --txt-secondary:  #556677;
      --txt-muted:      #667788;
      --txt-card-head:  #1a3a5c;
      --txt-info-badge: #78350f;
      --txt-kpi-val:    #1a3a5c;
      --txt-kpi-lbl:    #556677;

      --border-card:    rgba(26,58,92,0.10);
      --border-kpi:     #c8d8f0;
      --border-info:    #fbbf24;
      --border-plot:    #e8eef8;
      --border-divider: #dde8f5;
      --border-lang:    #b0c4e0;

      --top-bar-blue:   #2563a8;
      --top-bar-green:  #1e7a5e;
      --top-bar-orange: #c05000;
      --top-bar-purple: #6d28d9;
      --top-bar-red:    #be123c;

      --shadow-card:    0 2px 14px rgba(26,58,92,0.08);
      --shadow-controls:0 4px 18px rgba(26,58,92,0.18);
    }

    /* ── Dark mode overrides ── */
    body.dark-mode {
      --bg-page:        #111827;
      --bg-card:        #1f2937;
      --bg-card2:       #1a2332;
      --bg-controls:    linear-gradient(135deg,#0f172a 0%,#1e3a5c 60%,#0f3528 100%);
      --bg-info-badge:  linear-gradient(135deg,#1c1500 0%,#1f1a00 100%);
      --bg-kpi:         linear-gradient(135deg,#0d1b2e 0%,#1a2744 100%);
      --bg-plot-wrap:   #151d2b;
      --bg-table-head:  #0f172a;

      --txt-primary:    #e2e8f0;
      --txt-secondary:  #94a3b8;
      --txt-muted:      #64748b;
      --txt-card-head:  #e2e8f0;
      --txt-info-badge: #fcd34d;
      --txt-kpi-val:    #f1f5f9;
      --txt-kpi-lbl:    #94a3b8;

      --border-card:    rgba(255,255,255,0.07);
      --border-kpi:     #334155;
      --border-info:    #92400e;
      --border-plot:    #1e293b;
      --border-divider: #334155;
      --border-lang:    #334155;

      --top-bar-blue:   #3b82f6;
      --top-bar-green:  #10b981;
      --top-bar-orange: #f97316;
      --top-bar-purple: #a78bfa;
      --top-bar-red:    #f87171;

      --shadow-card:    0 2px 14px rgba(0,0,0,0.35);
      --shadow-controls:0 4px 18px rgba(0,0,0,0.45);
    }

    /* ── Page & body background ── */
    body {
      background: var(--bg-page) !important;
      color: var(--txt-primary) !important;
      transition: background 0.3s, color 0.3s;
    }
    .tab-pane { background: var(--bg-page); padding: 16px 8px; }

    /* ── Dark mode toggle button ── */
    .dm-toggle-btn {
      background: var(--bg-card);
      border: 1.5px solid var(--border-lang);
      border-radius: 24px;
      padding: 5px 16px 5px 10px;
      font-size: 0.82rem;
      font-weight: 600;
      cursor: pointer;
      color: var(--txt-primary);
      transition: all 0.2s;
      display: inline-flex;
      align-items: center;
      gap: 7px;
      box-shadow: 0 1px 4px rgba(0,0,0,0.08);
    }
    .dm-toggle-btn:hover { border-color: var(--top-bar-blue); color: var(--top-bar-blue); }
    body.dark-mode .dm-toggle-btn { background: #1e293b; color: #fcd34d; border-color: #44403c; }
    body.dark-mode .dm-toggle-btn:hover { background: #27272a; border-color: #fcd34d; }

    /* ── Language toggle ── */
    .lang-toggle-wrap { display: flex; justify-content: flex-end; margin-bottom: 12px; }
    .lang-btn {
      background: var(--bg-card); border: 1.5px solid var(--border-lang);
      border-radius: 20px; padding: 4px 14px; font-size: 0.8rem; font-weight: 600;
      cursor: pointer; color: var(--txt-primary); transition: all 0.18s;
      display: flex; align-items: center; gap: 6px;
    }
    .lang-btn:hover { background: #1a3a5c; color: #fff; border-color: #1a3a5c; }
    body.dark-mode .lang-btn:hover { background: #3b82f6; color: #fff; border-color: #3b82f6; }

    /* ── Controls bar ── */
    .causes-controls {
      background: var(--bg-controls);
      border-radius: 14px;
      padding: 18px 22px 14px 22px;
      margin-bottom: 20px;
      box-shadow: var(--shadow-controls);
    }
    .causes-controls .form-label {
      font-size: 0.78rem; color: #c8daf4; margin-bottom: 3px; font-weight: 600;
      text-transform: uppercase; letter-spacing: 0.04em;
    }
    .causes-controls select,
    .causes-controls .selectize-input {
      border-radius: 8px; border: none; font-size: 0.88rem;
      background: rgba(255,255,255,0.95) !important; color: #1a3a5c !important; font-weight: 500;
    }
    .controls-title {
      color: #fff; font-size: 0.72rem; font-weight: 700;
      text-transform: uppercase; letter-spacing: 0.08em;
      margin-bottom: 12px; opacity: 0.8;
    }

    /* ── State pills ── */
    .state-pill-row { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 4px; }
    .state-pill-label {
      color: #c8daf4; font-size: 0.76rem; font-weight: 700;
      text-transform: uppercase; letter-spacing: 0.06em; margin-bottom: 5px; display: block;
    }
    .state-pill {
      background: rgba(255,255,255,0.15); color: #fff;
      border: 1.5px solid rgba(255,255,255,0.35);
      border-radius: 20px; padding: 4px 13px; font-size: 0.78rem;
      cursor: pointer; transition: all 0.16s; font-weight: 600; white-space: nowrap;
    }
    .state-pill:hover  { background: rgba(255,255,255,0.9); color: #1a3a5c; }
    .state-pill.active { background: #ffffff; color: #1a3a5c; border-color: #fff;
      box-shadow: 0 2px 8px rgba(0,0,0,0.18); }

    /* ── Section cards ── */
    .causes-card {
      background: var(--bg-card);
      border-radius: 14px;
      box-shadow: var(--shadow-card);
      padding: 20px 24px 18px 24px;
      margin-bottom: 20px;
      border-top: 4px solid var(--top-bar-blue);
    }
    .causes-card.card-green  { border-top-color: var(--top-bar-green); }
    .causes-card.card-orange { border-top-color: var(--top-bar-orange); }
    .causes-card.card-purple { border-top-color: var(--top-bar-purple); }
    .causes-card.card-red    { border-top-color: var(--top-bar-red); }

    .causes-card-header {
      font-size: 1.02rem; font-weight: 700; color: var(--txt-card-head);
      border-bottom: 2px solid var(--border-divider);
      padding-bottom: 9px; margin-bottom: 15px;
      display: flex; align-items: center; gap: 8px;
    }

    /* ── KPI boxes ── */
    .kpi-row { display: flex; gap: 12px; flex-wrap: wrap; margin-bottom: 8px; }
    .kpi-box {
      flex: 1; min-width: 120px;
      background: var(--bg-kpi);
      border: 1.5px solid var(--border-kpi); border-radius: 12px;
      padding: 12px 14px; text-align: center;
    }
    .kpi-box .kpi-val { font-size: 1.55rem; font-weight: 800; color: var(--txt-kpi-val); line-height: 1.1; }
    .kpi-box .kpi-lbl { font-size: 0.7rem; color: var(--txt-kpi-lbl); margin-top: 3px; line-height: 1.3; }
    .kpi-box .kpi-diff-pos { color: #f87171; font-size: 0.76rem; font-weight: 700; margin-top: 2px; }
    .kpi-box .kpi-diff-neg { color: #4ade80; font-size: 0.76rem; font-weight: 700; margin-top: 2px; }
    .kpi-box.kpi-gap { background: linear-gradient(135deg,#fff7ed 0%,#fef3c7 100%); border-color: #fbbf24; }
    body.dark-mode .kpi-box.kpi-gap { background: linear-gradient(135deg,#1c0e00 0%,#1f1500 100%); border-color: #92400e; }

    /* ── Info badge ── */
    .info-badge {
      background: var(--bg-info-badge); color: var(--txt-info-badge);
      border: 1px solid var(--border-info); border-radius: 10px; padding: 10px 14px;
      font-size: 0.81rem; margin-bottom: 8px; width: 100%; box-sizing: border-box;
    }
    .info-badge .badge-title { font-weight: 700; font-size: 0.84rem; margin-bottom: 4px; display: block; }

    /* ── Avoidable tags ── */
    .avoid-tag { display: inline-block; border-radius: 6px; padding: 2px 9px; font-size: 0.74rem; font-weight: 600; margin: 2px; }
    .avoid-tag-orange { background: #fff0e0; color: #c05000; border: 1px solid #ffb870; }
    .avoid-tag-blue   { background: #e8f0fe; color: #1a3a5c; border: 1px solid #b0c4e8; }
    body.dark-mode .avoid-tag-orange { background: #2c1500; color: #fb923c; border-color: #7c2d12; }
    body.dark-mode .avoid-tag-blue   { background: #0f1f3c; color: #93c5fd; border-color: #1e3a5c; }

    /* ── Plot wrapper ── */
    .causes-plot-wrap {
      background: var(--bg-plot-wrap); border-radius: 10px;
      border: 1px solid var(--border-plot); padding: 8px; min-height: 300px;
    }

    /* ── Section divider ── */
    .section-divider { border: none; border-top: 2px dashed var(--border-divider); margin: 14px 0; }
    .hint-text { font-size: 0.78rem; color: var(--txt-muted); margin-bottom: 6px; }

    /* ── Dashboard cards (main / mortality tabs) ── */
    .jh-panel.card {
      background: var(--bg-card) !important;
      border: 1px solid var(--border-card) !important;
      box-shadow: var(--shadow-card) !important;
    }
    .card-body { background: transparent !important; }
    .panel-title {
      font-size: 0.75rem; font-weight: 700; letter-spacing: 0.06em;
      text-transform: uppercase; color: var(--txt-muted); margin-bottom: 10px;
    }

    /* ── Dashboard header ── */
    .dashboard-title   { color: var(--txt-primary) !important; }
    .dashboard-subtitle { color: var(--txt-secondary) !important; }
    .main-header-border { border-bottom: 2px solid var(--border-divider); padding-bottom: 10px; }

    /* ── Mortality info box ── */
    .info-box {
      background: var(--bg-info-badge); color: var(--txt-info-badge);
      border: 1px solid var(--border-info); border-radius: 10px;
      padding: 10px 16px; font-size: 0.85rem;
    }

    /* ── bslib value boxes ── */
    .bslib-value-box { background: var(--bg-card) !important; border: 1px solid var(--border-card) !important; }
    .bslib-value-box .value-box-title,
    .bslib-value-box .value-box-value { color: var(--txt-primary) !important; }

    /* ── Navbar ── */
    .navbar {
      background: var(--bg-card) !important;
      border-bottom: 1px solid var(--border-card) !important;
      box-shadow: 0 2px 8px rgba(0,0,0,0.07);
    }
    .navbar-brand, .nav-link { color: var(--txt-primary) !important; }
    .nav-link.active, .nav-link:hover { color: var(--top-bar-blue) !important; }

    /* ── Select / Selectize inputs (dark mode) ── */
    body.dark-mode .selectize-input,
    body.dark-mode .selectize-dropdown,
    body.dark-mode select {
      background: #1e293b !important; color: #e2e8f0 !important; border-color: #334155 !important;
    }
    body.dark-mode .selectize-dropdown-content .option { color: #e2e8f0; }
    body.dark-mode .selectize-dropdown-content .option:hover,
    body.dark-mode .selectize-dropdown-content .option.active {
      background: #2563a8 !important; color: #fff !important;
    }
    body.dark-mode label, body.dark-mode .form-label { color: var(--txt-primary) !important; }

    /* ── DT tables dark mode ── */
    body.dark-mode .dataTables_wrapper { color: var(--txt-primary); }
    body.dark-mode table.dataTable thead th { background: #0f172a !important; color: #e2e8f0 !important; }
    body.dark-mode table.dataTable tbody tr { background: #1f2937 !important; color: #e2e8f0 !important; }
    body.dark-mode table.dataTable tbody tr:nth-child(even) { background: #1a2436 !important; }
    body.dark-mode table.dataTable tbody tr:hover { background: #2d3748 !important; }
    body.dark-mode .dataTables_filter input,
    body.dark-mode .dataTables_length select { background: #1e293b !important; color: #e2e8f0 !important; border-color: #334155 !important; }
    body.dark-mode .dataTables_info,
    body.dark-mode .dataTables_paginate { color: var(--txt-secondary) !important; }
    body.dark-mode .paginate_button { color: var(--txt-primary) !important; }
    body.dark-mode .paginate_button.current { background: #2563a8 !important; color: #fff !important; border-color: #2563a8 !important; }

    /* ── Smooth transitions ── */
    .causes-card, .kpi-box, .info-badge, .causes-plot-wrap,
    .jh-panel, .navbar, .selectize-input, select, body,
    .info-box, .bslib-value-box, label {
      transition: background 0.25s, color 0.25s, border-color 0.25s, box-shadow 0.25s;
    }

    /* ══════════════════════════════════════════════════════════
       GLOBAL CAROUSEL  — sits between navbar and tab content
    ══════════════════════════════════════════════════════════ */
    .global-carousel-wrap {
      width: 100%;
      background: var(--bg-page);
      padding: 0;
      position: relative;
      z-index: 10;
      overflow: hidden;
      border-bottom: 3px solid var(--border-divider);
      box-shadow: 0 4px 18px rgba(0,0,0,0.10);
      transition: background 0.25s, border-color 0.25s;
    }

    #globalCarousel,
    #globalCarousel .carousel-inner,
    #globalCarousel .carousel-item {
      overflow: hidden;
    }

    /* Show full infographic without cropping */
    .carousel-img {
      width: 100% !important;
      height: 280px !important;
      max-height: 280px;
      object-fit: contain;
      object-position: center;
      display: block;
      background: #ffffff;
    }

    body.dark-mode .carousel-img {
      background: #1f2937;
    }

    /* Caption box */
    #globalCarousel .carousel-caption {
      background: rgba(0, 0, 0, 0.52);
      border-radius: 10px;
      padding: 10px 20px;
      bottom: 28px;
      left: 50%;
      transform: translateX(-50%);
      width: fit-content;
      white-space: nowrap;
      backdrop-filter: blur(4px);
    }
    #globalCarousel .carousel-caption h5 {
      font-size: 1.05rem;
      font-weight: 700;
      margin: 0 0 2px 0;
      color: #fff;
    }
    #globalCarousel .carousel-caption p {
      font-size: 0.82rem;
      margin: 0;
      color: #e2e8f0;
    }

    /* Indicators — use the app's red accent */
    #globalCarousel .carousel-indicators [data-bs-slide-to] {
      background-color: rgba(255,255,255,0.5);
      width: 10px;
      height: 10px;
      border-radius: 50%;
      border: none;
    }
    #globalCarousel .carousel-indicators .active {
      background-color: #ff3b3b;
    }

    /* Arrow controls */
    #globalCarousel .carousel-control-prev,
    #globalCarousel .carousel-control-next {
      width: 42px;
      height: 42px;
      background: rgba(0,0,0,0.38);
      border-radius: 50%;
      top: 50%;
      transform: translateY(-50%);
      opacity: 0.8;
    }
    #globalCarousel .carousel-control-prev { left: 16px; }
    #globalCarousel .carousel-control-next { right: 16px; }
    #globalCarousel .carousel-control-prev:hover,
    #globalCarousel .carousel-control-next:hover { opacity: 1; background: rgba(255,59,59,0.72); }

    /* Dark mode: slightly darker overlay */
    body.dark-mode .global-carousel-wrap {
      border-bottom-color: #1e293b;
      box-shadow: 0 4px 24px rgba(0,0,0,0.38);
    }
  "))
}

dark_mode_js <- function() {
  tags$script(HTML("
    (function() {
      var saved = localStorage.getItem('shinyDarkMode');
      if (saved === 'true') {
        document.body.classList.add('dark-mode');
      }
    })();

    function toggleDarkMode(btn) {
      var isDark = document.body.classList.toggle('dark-mode');
      localStorage.setItem('shinyDarkMode', isDark);
      btn.querySelector('.dm-label').textContent = isDark ? 'Light Mode' : 'Dark Mode';
      btn.querySelector('.dm-icon').textContent   = isDark ? '\u2600\ufe0f' : '\U0001f319';
      Shiny.setInputValue('global_dark_mode', isDark, {priority: 'event'});
    }
  "))
}

dark_mode_toggle_btn <- function() {
  tags$button(
    class   = "dm-toggle-btn",
    onclick = "toggleDarkMode(this)",
    tags$span(class = "dm-icon", "\U0001f319"),
    tags$span(class = "dm-label", "Dark Mode")
  )
}