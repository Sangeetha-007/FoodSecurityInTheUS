library(shiny)
library(leaflet)
library(readxl)
library(tigris)
library(sf)

# Specify the path to the Excel file
excel_file <- '/Users/Sangeetha/Downloads/foodsecurity_data_file_2022.xlsx'

# Specify the name of the sheet you want to read
sheet_name <- "Food security by State"  # Replace with the actual name of your sheet

# Read the specific sheet into a data frame
data <- read_excel(excel_file, sheet = sheet_name)

# Get US state boundaries data
shapefile <- tigris::states()
shapefile <- st_transform(shapefile, crs = 4326)  # Transform to WGS84 (EPSG code 4326)


# Define a color palette based on food insecurity prevalence
pal <- colorNumeric(
  palette = "Blues",
  domain = data$"Food insecurity prevalence"
)

ui <- fluidPage(
  titlePanel("Food Security and Nutrition in the US Map"),
  selectInput("select", label = h3("Food Security"), 
              choices = list("Insecurity By State" = 1, "Choice 2" = 2, "Choice 3" = 3), 
              selected = 1),
  hr(),
  fluidRow(column(12, leafletOutput("map")))
)

server <- function(input, output) {
  observe({
    if (input$select == 1) {
      output$map <- renderLeaflet({
        leaflet() %>%
          addProviderTiles("CartoDB.Positron") %>%
          addPolygons(data = shapefile,
                      fillColor = ~pal(data$"Food insecurity prevalence"),
                      fillOpacity = 0.7,
                      color = "white",
                      stroke = TRUE,
                      weight = 1,
                      popup = ~paste("<strong>State:</strong>", NAME, "<br>",
                                     "<strong>Food Insecurity Prevalence:</strong>", data$"Food insecurity prevalence", "%"))
      })
    }
  })
}

shinyApp(ui, server)
