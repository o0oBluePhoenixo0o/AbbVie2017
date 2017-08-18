# This is just a small test file for checking out how shiny works


# install.package(shiny)
# install.package(shinyBS)
# install.package(sentR)

library('shiny')
library('shinyBS')
library('sentR')

ui <- shinyUI(fluidPage(
  
  # Copy the line below to make a text input box
  textInput("text", label = h3("Text input"), value = "Enter text..."),
  
  hr(),
  fluidRow(column(3, verbatimTextOutput("value")))
  
))

server <- shinyServer(function(input, output) {
  
  # You can access the value of the widget with input$text, e.g.
  
  output$value <-renderText({ 
    sentR::classify.naivebayes(input$text)
  })
})

shinyApp(ui = ui, server = server)
