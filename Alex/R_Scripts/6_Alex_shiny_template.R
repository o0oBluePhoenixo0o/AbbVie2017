# This is a standard hello world Shiny App template
# It consists of one ui function, with accepts input function for building the ui and
# one server functions which accepts inputs from the ui and output function to generate a plot, result or anything elese

# install.packages('shiny')
library('shiny')

ui <- shinyUI(fluidPage(
  "Hello World"
  )
)
server <- shinyServer(function(input, output, session){
  
})
shinyApp(ui = ui, server = server)

