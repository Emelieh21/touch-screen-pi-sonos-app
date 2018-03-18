library(shiny)
library(jsonlite)

#### Set reactiveValues for currenct track information ####
values <- reactiveValues(track = NULL,
                         artist = NULL, 
                         album = NULL, 
                         image = NULL,
                         time_left = NULL,
                         type = NULL)

#### Set IP/or assign localhost ####
#ip_addr = "localhost"
ip_addr = "192.168.178.45"

#### UI ####
ui <- fluidPage(
  # Include JS scripts ####
  includeScript("www/js/jquery-latest.min.js"),
  includeScript("www/js/jquery-ui.min.js"),
  includeScript("www/js/jquery.keyboard.js"),
  includeScript("www/js/demo.js"),
  includeCSS("www/css/keyboard.css"),
  includeCSS("www/css/jquery-ui.min.css"),
  tags$br(),
  #### Sonos logo ####
  div(tags$img(src="logo.jpg", width="auto",height="70px"),style="text-align:center;"),
  tags$hr(),
  #### Fullscreen ####
  actionButton("f11","Fullscreen", style='padding:4px; font-size:150%'),
  #### General control buttons ####
  actionButton("play","Play", icon = icon("play"), style='padding:4px; font-size:150%'),
  actionButton("pause","Pause", icon = icon("pause"), style='padding:4px; font-size:150%'),
  actionButton("next_song","Next", icon = icon("step-forward"), style='padding:4px; font-size:150%'),
  #### Favorite radiostations ####
  actionButton("radio10","Radio10", style='padding:4px; font-size:150%'),
  actionButton("m80","M80", style='padding:4px; font-size:150%'),
  #### Quit ####
  actionButton("quit","", icon = icon("power-off")),
  tags$hr(),
  #### Music search ####
  fluidRow(style='padding:4px; font-size:150%',
           column(3,textInput("text","Search: ")),
           column(6,radioButtons("type", "", inline = TRUE, choices = c("song","album","playlist"))),
           column(3,tags$br(),actionButton("go","Go!",icon = icon("music"), style='padding:4px; font-size:100%'))
  ),
  tags$hr(),
  fluidRow(style='padding:4px; font-size:100%',
      #### Volume control ####     
      column(5,sliderInput("volume","Volume",min=0,max=100,value=c(0,20),ticks = FALSE)),
      #### Current track information ####
      column(7,uiOutput("now_playing"))
  ))

#### SERVER ####
server <- function(input, output, session){
  #### General control buttons ####
  observeEvent(input$play,  {
    system(paste0('curl "','http://',ip_addr,':5005/play"'))
  })
  observeEvent(input$pause,  {
    system(paste0('curl "','http://',ip_addr,':5005/pause"')
  })
  observeEvent(input$next_song, {
    system(paste0('curl "','http://',ip_addr,':5005/next"')
  })
  #### Favorite radiostations ####
  observeEvent(input$radio10, {
    system(paste0('curl "','http://',ip_addr,':5005/tunein/play/74982"')
  })
  observeEvent(input$m80, {
    system(paste0('curl "','http://',ip_addr,':5005/tunein/play/48753"')
  })
  #### Music search ####
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
  #### Volume control ####
  observeEvent(input$volume, {
    vol = input$volume[2]
    req = paste0('curl "','http://localhost:5005/volume/',
                 as.character(vol),'"')
    system(req)
  })
  #### Fullscreen ####
  observe(if (input$f11 > 0) { 
    system("xdotool key F11")
  })
  #### Quit ####
  observe(
    if (input$quit > 0) { 
      system("xdotool key F11")
      stopApp() 
    })
  #### Current track information ####
  getCurrent <- reactive({
    current <- fromJSON("http://localhost:5005/state")
    values$time_left <- (current$currentTrack$duration-current$elapsedTime)*1000
    invalidateLater(values$time_left)
    values$track <- current$currentTrack$title
    values$artist <- current$currentTrack$artist
    values$album <- current$currentTrack$album
    values$image <- current$currentTrack$absoluteAlbumArtUri
    values$type <- current$currentTrack$type
  })
  observeEvent(input$refresh, {
    current <- fromJSON("http://localhost:5005/state")
    values$time_left <- (current$currentTrack$duration-current$elapsedTime)*1000
    values$track <- current$currentTrack$title
    values$artist <- current$currentTrack$artist
    values$album <- current$currentTrack$album
    values$image <- current$currentTrack$absoluteAlbumArtUri
    values$type <- current$currentTrack$type
  })
  output$now_playing <- renderUI({
    getCurrent()
    if (values$type != "radio"){ # display artist, track & album for tracks
      tags$table(
        tags$tr(
          tags$td(tags$img(src=values$image, width="100px")),
          tags$td(tags$br()),
          tags$td(style = "padding:10px;", div(
            tags$b(values$artist),tags$br(),
            tags$b(values$track),tags$br(),
            tags$b(values$album),tags$br(),
            tags$b(actionButton("refresh",label="",icon=icon("refresh")))
          ))
        )
      )
    } else { # display just the radio station and track for (unpaused) radio
      if (!grepl("x-sonosapi-stream",values$track)){
        tags$table(
          tags$tr(
            tags$td(tags$img(src=values$image, width="100px")),
            tags$td(tags$br()),
            tags$td(style = "padding:10px;", div(
              tags$b(values$artist),tags$br(),
              tags$b(values$track),tags$br(),
              tags$b(actionButton("refresh",label="",icon=icon("refresh")))
            ))
          )
        )
      }  
    }
  })
}

shinyApp(ui,server)
