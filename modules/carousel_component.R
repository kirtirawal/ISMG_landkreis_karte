# ============================================================
#  IMAGE CAROUSEL — drop this block into any UI module
#  Place the two images in your www/ folder, e.g.:
#    www/slide1.png
#    www/slide2.png
# ============================================================

image_carousel <- function(
    images,          # character vector of paths relative to www/, e.g. c("slide1.png","slide2.png")
    captions = NULL, # optional character vector of captions (same length as images)
    height   = "400px",
    id       = "mainCarousel"
) {
  
  n <- length(images)
  
  # Build indicator buttons
  indicators <- lapply(seq_len(n), function(i) {
    tags$button(
      type              = "button",
      `data-bs-target`  = paste0("#", id),
      `data-bs-slide-to` = i - 1,
      class             = if (i == 1) "active" else "",
      `aria-label`      = paste("Slide", i),
      `aria-current`    = if (i == 1) "true" else NULL
    )
  })
  
  # Build slide items
  items <- lapply(seq_len(n), function(i) {
    div(
      class = paste("carousel-item", if (i == 1) "active" else ""),
      tags$img(
        src   = images[i],
        class = "d-block w-100",
        style = paste0("height:", height, "; object-fit: cover; border-radius: 8px;"),
        alt   = if (!is.null(captions)) captions[i] else paste("Slide", i)
      ),
      if (!is.null(captions)) {
        div(
          class = "carousel-caption d-none d-md-block",
          style = "background: rgba(0,0,0,0.45); border-radius: 6px; padding: 6px 12px;",
          tags$p(style = "margin:0; font-size:0.9rem;", captions[i])
        )
      }
    )
  })
  
  tagList(
    # Minimal extra CSS — blends with dark theme used in the app
    tags$style(HTML(sprintf("
      #%s { border-radius: 8px; overflow: hidden; }
      #%s .carousel-control-prev-icon,
      #%s .carousel-control-next-icon { filter: invert(0); }
      #%s .carousel-indicators [data-bs-slide-to] {
        background-color: #ff3b3b;
      }
    ", id, id, id, id))),
    
    div(
      id    = id,
      class = "carousel slide",
      `data-bs-ride` = "carousel",
      
      # Indicators
      div(class = "carousel-indicators", indicators),
      
      # Slides
      div(class = "carousel-inner", items),
      
      # Prev / Next controls
      tags$button(
        class            = "carousel-control-prev",
        type             = "button",
        `data-bs-target` = paste0("#", id),
        `data-bs-slide`  = "prev",
        tags$span(class = "carousel-control-prev-icon", `aria-hidden` = "true"),
        tags$span(class = "visually-hidden", "Previous")
      ),
      tags$button(
        class            = "carousel-control-next",
        type             = "button",
        `data-bs-target` = paste0("#", id),
        `data-bs-slide`  = "next",
        tags$span(class = "carousel-control-next-icon", `aria-hidden` = "true"),
        tags$span(class = "visually-hidden", "Next")
      )
    )
  )
}


# ============================================================
#  HOW TO USE — paste one of these blocks into your UI module
# ============================================================

# --- Example A: in mod_main_ui.R, add a new fluidRow ABOVE the maps ---
#
# fluidRow(class = "mb-3",
#   column(width = 12,
#     div(class = "jh-panel card",
#       div(class = "card-body p-0",
#         image_carousel(
#           images   = c("slide1.png", "slide2.png"),
#           captions = c("Landkreis Übersicht", "Regionale Analyse"),
#           height   = "380px",
#           id       = "mainCarousel"
#         )
#       )
#     )
#   )
# )


# --- Example B: in mod_mortality_ui.R, add after the header fluidRow ---
#
# fluidRow(
#   column(12,
#     image_carousel(
#       images   = c("slide1.png", "slide2.png"),
#       captions = c("Sterblichkeit Übersicht", "Zeitreihen"),
#       height   = "340px",
#       id       = "mortCarousel"
#     )
#   )
# )