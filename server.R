#short and sweet 

library(shiny)
source("./prediction.R")

shinyServer(function(input, output) {
  output$prediction <- renderPrint({
    cleanText <- processInput(input$userInput)
    resultVector <- predictNext(cleanText)
    resultVector
  });
}
)
