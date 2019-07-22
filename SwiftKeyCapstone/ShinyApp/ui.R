suppressPackageStartupMessages(c(
    library(shinythemes),
    library(shiny),
    library(tm),
    library(stringr),
    library(markdown),
    library(stylo),
    library(dplyr),
    library(shinyjs)))

shinyUI(fluidPage(theme = shinytheme("darkly"), 
                  titlePanel("Coursera SwiftKey Data Science Capstone"),
                  useShinyjs(),
                  navlistPanel(
                      well = TRUE,
                      fluid = TRUE, 
                      widths = c(2, 10),
                   
                   ## Tab 1 - Text Prediction Demo  
                   
                   tabPanel("Next Word Predictor",
                            
                            fluidRow(
                              
                                column(3),
                                column(6,
                                       tags$div(textInput("text", 
                                                          label = h3("Enter text here:")),
                                                tags$span(style="color:grey",("Only supports English words!")),
                                                br(),
                                                tags$hr(),
                                                h3("Suggested next word:"),
                                                br(),
                                                actionButton("sugg1", label = "Suggestion 1"),
                                                actionButton("sugg2", label = "Suggestion 2"),
                                                actionButton("sugg3", label = "Suggestion 3"),
                                                actionButton("sugg4", label = "Suggestion 4"),
                                                tags$hr(),
                                                textInput("text2",
                                                          label = h4("Add Suggestion")),
                                                actionButton("butt1", label = "Add"),
                                                br(),
                                                tags$hr(),
                                                h4("Full Text:"),
                                                tags$em(tags$h4(textOutput("finalInput"))),
                                                align="center")
                                       ),
                                column(3)
                            )
                   ),
                   

                   ## Tab 2 - Documentation ##
                   
                   tabPanel("App Documentation",
                            fluidRow(
                                column(1, p(" ")),
                                column(10, includeMarkdown("./about.md")),
                                column(1, p(" "))
                      )
                    )
          )
        )

    )
