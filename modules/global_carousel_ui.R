global_carousel_ui <- function() {
  
  div(
    class = "global-carousel-wrap",
    
    div(
      id = "globalCarousel",
      class = "carousel slide",
      `data-bs-ride` = "carousel",
      `data-bs-interval` = "5000",
      
      # Indicators
      div(
        class = "carousel-indicators",
        
        tags$button(
          type = "button",
          `data-bs-target` = "#globalCarousel",
          `data-bs-slide-to` = "0",
          class = "active",
          `aria-current` = "true"
        ),
        
        tags$button(
          type = "button",
          `data-bs-target` = "#globalCarousel",
          `data-bs-slide-to` = "1"
        ),
        
        tags$button(
          type = "button",
          `data-bs-target` = "#globalCarousel",
          `data-bs-slide-to` = "2"
        )
      ),
      
      # Slides
      div(
        class = "carousel-inner",
        
        div(
          class = "carousel-item active",
          
          tags$img(
            src = "images/picture-3.PNG",
            class = "d-block w-100 carousel-img",
            alt = "Slide 1"
          )
        ),
        
        div(
          class = "carousel-item",
          
          tags$img(
            src = "images/picture-2.PNG",
            class = "d-block w-100 carousel-img",
            alt = "Slide 2"
          )
        ),
        
        div(
          class = "carousel-item",
          
          tags$img(
            src = "images/picture-1.PNG",
            class = "d-block w-100 carousel-img",
            alt = "Slide 3"
          )
        )
      ),
      
      # Previous button
      tags$button(
        class = "carousel-control-prev",
        type = "button",
        `data-bs-target` = "#globalCarousel",
        `data-bs-slide` = "prev",
        
        tags$span(
          class = "carousel-control-prev-icon"
        )
      ),
      
      # Next button
      tags$button(
        class = "carousel-control-next",
        type = "button",
        `data-bs-target` = "#globalCarousel",
        `data-bs-slide` = "next",
        
        tags$span(
          class = "carousel-control-next-icon"
        )
      )
    )
  )
}