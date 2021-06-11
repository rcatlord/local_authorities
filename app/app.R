library(shiny) ; library(tidyverse) ; library(sf) ; library(leaflet) ; library(apexcharter)

# local authority indicators
df <- read_csv("data/indicators.csv")
# local authority boundaries
sf <- st_read("data/priority_places.geojson")
# local authority names
local_authorities <- sort(unique(sf$area_name))

ui <- fluidPage(
  includeCSS("www/styles.css"),
  br(),
  fluidRow(
    column(3, offset = 1,
           div(class = "nav",
               helpText("Visualise a range of indicators at local authority level"), 
               selectInput("lad", "Choose a local authority:", choices = local_authorities, selected = "Fareham")
               )
           ),
    column(6, offset = 1,
           fluidRow(
             htmlOutput("priority_place_text"),
             leafletOutput("map")
             ),
           fluidRow(
             h3("Deprivation"),
             htmlOutput("deprivation_text"),
             h3("Governance"),
             apexchartOutput("eu_referendum_chart"),
             h3("Labour market"),
             br(),
             apexchartOutput("employment_sector_chart"),
             h3("Demographics"),
             h3("Housing"),
             h3("Education"),
             h3("Health"),
             h3("Transport"),
             h3("Environment")
             )
           )
    )
  )

server <- function(input, output, session) {
  
  indicators <- reactive({
    filter(df, area_name == input$lad)
  })
  
  priority_place <- reactive({
    filter(sf, area_name == input$lad)
  })
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(urlTemplate = "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
               attribution = '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a> | <a href="https://www.ons.gov.uk/methodology/geography/licences">Contains OS data © Crown copyright and database right (2021)</a>') %>%
      addPolygons(data = priority_place(), fillColor = "transparent", weight = 1.5, opacity = 1, color = "#206095")
    
  })
  
  output$priority_place_text <- renderUI({
    HTML(paste0("<p><span class='lad_name'>", input$lad, "</span> is in priority category <strong>", pull(priority_place(), category), "</strong> of the <a href='https://www.gov.uk/government/collections/new-levelling-up-and-community-investments' target='_blank'>Levelling Up Fund</a>.</p>"))
  })
  
  output$deprivation_text <- renderUI({
    validate(need(str_detect(sf[sf$area_name == input$lad,]$area_code, "^E"), message = "No data are currently available for this area"))
    HTML(paste0("<p><span class='lad_name'>", input$lad, "</span> is ranked <strong>", pull(filter(indicators(), group == "Rank of average score"), value),
           "</strong> on the <a href='https://www.gov.uk/government/statistics/english-indices-of-deprivation-2019' target='_blank'>2019 Index of Multiple Deprivation</a> out of 317 local authority districts in England where 1 is the most deprived and 317 is the least deprived.
           The proportion of Lower-layer Super Output Areas in the most deprived 10% nationally was <strong>", round(pull(filter(indicators(), group == "Proportion of LSOAs in most deprived 10% nationally"), value)*100,1), "%</strong>.</p>"))
  })
  
  output$eu_referendum_chart <- renderApexchart({
    filter(indicators(), indicator == "Voted leave in EU referendum") %>% 
      mutate(value = round(value,1)) %>% 
      apex(type = "radialBar", mapping = aes(x = "Voted leave", y = value), auto_update = FALSE) %>% 
      ax_colors("#1F6095") %>% 
      ax_stroke(dashArray = 4) %>% 
      ax_labs(title = paste0("EU referendum result in ", input$lad),
              subtitle = "Source: Electoral Commission") %>% 
      ax_title(style = list(fontSize = "18px")) %>% 
      ax_subtitle(style = list(fontWeight = "bold", fontSize = "12px", color = "#bdbdbd"))
  })
  
  output$employment_sector_chart <- renderApexchart({
    filter(indicators(), indicator == "Employment by sector") %>% 
      arrange(desc(value)) %>% 
      apex(mapping = aes(x = group, y = value), type = "bar", auto_update = FALSE) %>% 
      ax_colors("#1F6095") %>% 
      ax_xaxis(labels = list(formatter = format_num(",", suffix = "%"))) %>% 
      ax_labs(title = paste0("Employment in ", input$lad, " by sector (2019)"),
              subtitle = "Source: ONS Business Register and Employment Survey") %>% 
      ax_tooltip(y = list(formatter = JS("function(value) {return value + '%'}"))) %>%
      ax_title(style = list(fontSize = "18px")) %>% 
      ax_subtitle(style = list(fontWeight = "bold", fontSize = "12px", color = "#bdbdbd")) %>% 
      ax_states(hover = list(filter = list(type = "darken"))) 
  })
}

shinyApp(ui, server)