library(shiny)

shinyUI(navbarPage("Predictive text typing!",
                   tabPanel("Application",
                              mainPanel(
                                helpText("Start typing here. Observe how predictions change mid-word and after spaces."),
                                textInput("userInput", "User Input",value = ""),
                                h3("Suggestions"),
                                verbatimTextOutput("prediction"),
                                br(), br(), br(),
                                helpText("Author: staszz2"),
                                helpText("3/26/2017")
                              )
                   ),
                   tabPanel("Help",
                            mainPanel(
                              helpText("1. Start typing words."),
                              helpText("2. See the suggested next words..."),
                              helpText(" - 2a. Mid-word suggestions include autocomplete."),
                              helpText(" - 2b. Words followed by space only predict next word."),
                              br(),
                              helpText("TODO: convert suggestions into clickable buttons")
                            )
                   )
)
)