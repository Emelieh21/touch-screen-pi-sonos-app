library(shiny)

ui <- fluidPage(
  # Js scripts needed for the touch screen keyboard
  includeScript("www/js/jquery-latest.min.js"),
  includeScript("www/js/jquery-ui.min.js"),
  includeScript("www/js/jquery.keyboard.js"),
  includeScript("www/js/demo.js"),
  includeCSS("www/css/keyboard.css"),
  includeCSS("www/css/jquery-ui.min.css"),
  tags$br(),
  div(tags$img(src="logo.jpg", width="auto",height="70px"),style="text-align:center;"),
  tags$hr(),
  actionButton("f11","Fullscreen", style='padding:4px; font-size:150%'),
  actionButton("play","Play", icon = icon("play"), style='padding:4px; font-size:150%'),
  actionButton("pause","Pause", icon = icon("pause"), style='padding:4px; font-size:150%'),
  actionButton("next_song","Next", icon = icon("step-forward"), style='padding:4px; font-size:150%'),
  actionButton("radio10","Radio10", style='padding:4px; font-size:150%'),
  actionButton("m80","M80", style='padding:4px; font-size:150%'),
  actionButton("quit","", icon = icon("power-off")),
  tags$hr(),
  fluidRow(style='padding:4px; font-size:150%',
           # the text input did not update with the input from the touch screen
           # keyboard. For now fixed with an updateTextInput in the server.
           column(3,textInput("text","Search: ")),
           column(6,radioButtons("type", "", inline = TRUE, choices = c("song","album","playlist"))),
           column(3,tags$br(),actionButton("go","Go!",icon = icon("music"), style='padding:4px; font-size:100%'))
  ),
  tags$br(),
  div(style='padding:4px; font-size:100%',
      sliderInput("volume","Volume",min=0,max=100,value=c(0,20),ticks = FALSE, width = "85%")
  ))

server <- function(input, output, session){
  observeEvent(input$play,  {
    system('curl "http://localhost:5005/play"')
  })
  observeEvent(input$pause,  {
    system('curl "http://localhost:5005/pause"')
  })
  observeEvent(input$next_song, {
    system('curl "http://localhost:5005/next"')
  })
  observeEvent(input$radio10, {
    system('curl "http://localhost:5005/tunein/play/74982"')
  })
  observeEvent(input$m80, {
    system('curl "http://localhost:5005/tunein/play/48753"')
  })
  observeEvent(input$go, {
    # forcing shiny to get the latest input from the textInput
    updateTextInput(session, "text", label="Search: ")
  })
  observeEvent(input$text, {
    type <- input$type
    term <- gsub("\\ ","+",input$text)
    req = paste0('curl "','http://localhost:5005/musicsearch/spotify/',
                 as.character(type),'/',term,'"')
    system(req)
  })
  observeEvent(input$volume, {
    vol = input$volume[2]
    req = paste0('curl "','http://localhost:5005/volume/',
                 as.character(vol),'"')
    system(req)
  })
  observe(if (input$f11 > 0) { 
    system("xdotool key F11")
  })
  observe(
    if (input$quit > 0) { 
      system("xdotool key F11")
      stopApp() 
    })
  
}

shinyApp(ui,server)