library('shiny')
library('shinyBS')


ui <- shinyUI(fluidPage(
  
  # input control for first choice
  
  selectInput("first_choice", 
              label = h1("First Answer a General Question"),
              choices = list("select","A","B","C"),
              selected = "select"
  ),
  
  #collapsable panel for second choice
  
  h1("then get into details"),
  
  bsCollapse(
    bsCollapsePanel( title = "details",
                     uiOutput("second_choice")
    ),
    id = "collapser", multiple = FALSE, open = NULL
  ),
  h2("first answer"),
  h3(textOutput("first_answer")),
  h2("second answer"),
  h3(textOutput("second_answer"))
  
))

server <- shinyServer(function(input, output,session) {
  
  #retrieve selected values and render text from selection
  
  output$first_answer  <- renderText({input$first_choice})
  output$second_answer <- renderText({input$dynamic})
  output$second_choice <- renderUI({
    
    switch(input$first_choice,
           "A" = checkboxGroupInput("dynamic", "Dynamic",
                                    choices = c("Aragon","Frodo"),
                                    selected = "option2"),
           "B" = checkboxGroupInput("dynamic", "Dynamic",
                                    choices = c("Bilbo","Gandalf","Sauron"),
                                    selected = "option2"),
           "C" = checkboxGroupInput("dynamic", "Dynamic",
                                    choices = c("Boromir","Legolas"),
                                    selected = "option2")
           
    )
    
  })
  
  #observe function in order to open the collapsable panel when the first answer is given
  
  
  observe({
    if (input$first_choice != "select") {
      updateCollapse(session,"collapser",open = c('details'))
      
    }
  })
  
})

shinyApp(ui = ui, server = server)
