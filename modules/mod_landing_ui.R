# ============================================================
# Landing Page UI
# ============================================================

mod_landing_ui <- function(id) {
  module_card <- function(
    target,
    image,
    title
  ){
    
    tags$div(
      
      class = "module-card navigation-card",
      
      `data-target` = target,
      
      tags$img(
        src = image,
        alt = title,
        style = "
        width:100%;
        height:280px;
        object-fit:cover;
        display:block;
      "
      ),
      
      tags$div(
        
        style = "
        position:absolute;
        left:30px;
        bottom:0;
        width:82%;
        background:#003b7a;
        color:white;
        padding:24px;
      ",
        
        tags$h3(
          style = "
          margin:0;
          color:white;
        ",
          title
        )
      )
    )
  }
  
  tagList(
    
    # ========================================================
    # CAROUSEL
    # ========================================================
    
    global_carousel_ui(),
    
    
    # ========================================================
    # LANDING PAGE CONTENT
    # ========================================================
    
    div(
      class = "landing-content",
      
      
      # ======================================================
      # PAGE INTRODUCTION
      # ======================================================
      
      div(
        class = "landing-intro",
        
        tags$span(
          class = "landing-eyebrow",
          "GESUNDHEITSFORSCHUNG IN SACHSEN-ANHALT"
        ),
        
        tags$h1(
          class = "landing-title",
          "Datenvisualisierungen und Dashboards"
        ),
        
        tags$p(
          class = "landing-subtitle",
          paste(
            "Gesundheits- und Bevölkerungsdaten verständlich",
            "visualisieren, Forschungsergebnisse sichtbar machen",
            "und den Wissenstransfer unterstützen."
          )
        )
      ),
      
      
      # ======================================================
      # ABOUT THE PLATFORM
      # ======================================================
      
      div(
        class = "about-platform-section",
        
        div(
          class = "about-platform-grid",
          
          
          # ==================================================
          # LEFT COLUMN
          # ==================================================
          
          div(
            class = "about-platform-content",
            
            tags$span(
              class = "content-kicker",
              "ÜBER DIE PLATTFORM"
            ),
            
            tags$h2(
              class = "about-platform-title",
              "Forschung sichtbar machen. Versorgung verbessern."
            ),
            
            tags$p(
              class = "about-platform-lead",
              paste(
                "Der Gesundheits- und Bevölkerungsmonitor Sachsen-Anhalt wurde entwickelt,",
                "um öffentlich zugängliche Daten der Gesundheitsberichterstattung sowie",
                "Forschungsergebnisse in verständliche, interaktive und praxisnahe Visualisierungen zu überführen."
              )
            ),
            
            tags$p(
              class = "about-platform-text",
              paste(
                "Gleichzeitig öffnet sich die Plattform für die",
                "breite Bevölkerung. Unser Ziel ist es, allen",
                "Bürgerinnen und Bürgern einen erleichterten",
                "Zugang zu verlässlichen Gesundheitsinformationen",
                "zu bieten und die allgemeine Gesundheitskompetenz",
                "durch verständlich aufbereitete Inhalte",
                "nachhaltig zu stärken."
                
              )
            ),
            
            tags$p(
              class = "about-platform-text",
              paste(
                "Interaktive Karten, Zeitreihenanalysen und",
                "datenbasierte Visualisierungen ermöglichen",
                "einen schnellen Einblick in regionale",
                "Unterschiede, Versorgungstrends und",
                "gesundheitsbezogene Entwicklungen."
              )
            ),
            
            
            # ================================================
            # OFFICIAL PROJECT LINK
            # ================================================
            
            tags$a(
              href = "https://isa-ummd.de/notfall-und-intensivmedizin/#w-tabs-0-data-w-pane-0",
              target = "_blank",
              rel = "noopener noreferrer",
              
              tags$img(
                src = "images/isa-logo.png",
                class = "isa-logo-large",
                alt = "ISA"
              )
            )
          ),
          
          
          # ==================================================
          # RIGHT COLUMN: PROJECT CONTEXT
          # ==================================================
          
          div(
            class = "project-context-card",
            
            div(
              class = "project-context-icon",
              
              tags$img(
                src = "images/isa-logo.png",
                alt = "ISA Logo",
                style = "
      width: 55px;
      height: 55px;
      object-fit: contain;
    "
              )
            ),
            
            tags$span(
              class = "project-context-label",
              "PROJEKTKONTEXT"
            ),
            
            tags$h3(
              "ISA-Implementierungsforschung"
            ),
            
            tags$p(
              paste(
                "Die Plattform steht im Zusammenhang mit dem",
                "ISA-Forschungsverbund und unterstützt die",
                "verständliche Darstellung regionaler",
                "Gesundheits- und Versorgungsdaten."
              )
            ),
            
            tags$p(
              paste(
                "Im Bereich Notfall- und Intensivmedizin wird",
                "untersucht, wie wissenschaftliche Erkenntnisse",
                "nachhaltig in die Versorgungspraxis übertragen",
                "werden können."
              )
            ),
            
            div(
              class = "project-context-divider"
            ),
            
            div(
              class = "institution-row",
              
              div(
                class = "institution-icon",
                icon("hospital")
              ),
              
              div(
                tags$strong(
                  "Institut für Sozialmedizin und ",
                  "Gesundheitssystemforschung"
                ),
                
                tags$span(
                  "Universitätsmedizin Magdeburg"
                )
              )
            )
          )
        )
      ),
      
      
      # ======================================================
      # PLATFORM PURPOSES
      # ======================================================
      
      div(
        class = "platform-purpose-section",
        
        div(
          class = "purpose-card",
          
          div(
            class = "purpose-icon",
            icon("chart-line")
          ),
          
          tags$h3(
            "Ergebnisse visualisieren"
          ),
          
          tags$p(
            paste(
              "Komplexe Forschungs- und Gesundheitsdaten werden",
              "in verständliche Karten, Diagramme und",
              "interaktive Analysen überführt."
            )
          )
        ),
        
        div(
          class = "purpose-card",
          
          div(
            class = "purpose-icon",
            icon("people-arrows")
          ),
          
          tags$h3(
            "Wissen transferieren"
          ),
          
          tags$p(
            paste(
              "Forschungsergebnisse werden für Stakeholder,",
              "Versorgungseinrichtungen und öffentliche",
              "Entscheidungsträger:innen zugänglich gemacht."
            )
          )
        ),
        
        div(
          class = "purpose-card",
          
          div(
            class = "purpose-icon",
            icon("map-location-dot")
          ),
          
          tags$h3(
            "Regionale Unterschiede erkennen"
          ),
          
          tags$p(
            paste(
              "Geografische Darstellungen unterstützen die",
              "Analyse von regionalen Entwicklungen und",
              "Versorgungsstrukturen in Sachsen-Anhalt."
            )
          )
        )
      ),
      
      
      # ======================================================
      # TOPICS HEADER
      # ======================================================
      
      div(
        class = "topics-section",
        
        div(
          class = "topics-heading",
          
          div(
            tags$span(
              class = "content-kicker",
              "DASHBOARD-BEREICHE"
            ),
            
            tags$h2(
              class = "section-title",
              "Themen"
            )
          ),
          
          tags$p(
            class = "topics-description",
            
            paste(
              "Wählen Sie einen Themenbereich aus, um",
              "interaktive Karten, Visualisierungen und",
              "Analysen zu öffnen."
            )
          )
        ),
        
        # ====================================================
        # DASHBOARD CARDS
        # ====================================================
        
        div(
          class = "dashboard-grid",
          
          module_card(
            target = "demographics",
            image = "images/picture-4.png",
            title = "Demografie & Bevölkerung"
          ),
          
          module_card(
            target = "causes",
            image = "images/picture-5.png",
            title = "Todesursachen"
          ),
          
          module_card(
            target = "gallery",
            image = "images/picture-6.png",
            title = "Visualisierungsgalerie"
          ),
          
          module_card(
            target = "python_tab",
            image = "images/picture-7.png",
            title = "LäKoSA"
          ),
          
          module_card(
            target = "heat_emissions",
            image = "images/heat-dashboard.jpg",
            title = "Urban Heat Emissions"
          )
          
        )
        
      ),
      
      # ======================================================
      # FOOTER INFO
      # ======================================================
      
      div(
        class = "landing-footer",
        
        tags$p(
          HTML(
            paste0(
              "&copy; ",
              format(Sys.Date(), "%Y"),
              " Institut für Sozialmedizin und Gesundheitssystemforschung (ISMG), Otto-von-Guericke-Universität Magdeburg. Alle Rechte vorbehalten."
            )
          )
        )
      )
      
    ) # end landing-content
    
  ) # end tagList
  
}