library(shiny)

ui <- fluidPage(
  actionButton("play","Play", icon = icon("play")),
  actionButton("pause","Pause", icon = icon("pause")),
  div(sliderInput("volume","Volume",
                  min=0, max=100, value=c(0,20),
                  ticks = FALSE)
  )
)

server <- function(input, output){
  observeEvent(input$play,  {
    system('curl "http://localhost:5005/play"')
  })
  observeEvent(input$pause,  {
    system('curl "http://localhost:5005/pause"')
  })
  observeEvent(input$volume, {
    vol = input$volume[2]
    req = paste0('curl "','http://localhost:5005/volume/',
                 as.character(vol),'"')
    system(req)
  })
}

shinyApp(ui,server)