suppressPackageStartupMessages(c(
    library(shinythemes),
    library(shiny),
    library(tm),
    library(stringr),
    library(markdown),
    library(stylo),
    library(shinyjs)))
## loading in prediction functions ##
source("./newPredict.R") 
## loading n-gram dataframes ##
gram2 <- readRDS(file = "./df/gram2.RData")
gram3 <- readRDS(file = "./df/gram3.RData")
gram4 <- readRDS(file = "./df/gram4.RData")

shinyServer(function(input, output, session) {
    ## creating empty data frame for prediction learning ##
    gram1 <- data.frame(1,1,1)
    colnames(gram1) <- c("w1", "w2", "w3")
   
    wordPrediction <- reactive({
        rawInput <- input$text
        wPredict <- mainFUN(rawInput)
        return(wPredict)
    }) 
    
    wordPredictionL <- reactive({
            rawInput <- input$text
            wPredictL <- LmainFUN(rawInput, gram1)
            return(wPredictL)
    }) 
    
    ## suggestion 1 button ##    
    textupdater1 <- reactive({
        I <- as.character(input$text) 
        W <- as.character(wordPrediction())
        observeEvent(input$sugg1, {updateTextInput(session, "text", value = paste(I, W[[1]]))})
    })
    ## suggestion 2 button ##
    textupdater2 <- reactive({
        I <- as.character(input$text) 
        W <- as.character(wordPrediction())
        observeEvent(input$sugg2, {updateTextInput(session, "text", value = paste(I, W[[2]]))})
    })
    ## suggestion 3 button ##
    textupdater3 <- reactive({
        I <- as.character(input$text) 
        W <- as.character(wordPrediction())
        observeEvent(input$sugg3, {updateTextInput(session, "text", value = paste(I, W[[3]]))})
    })
    ## suggestion 4 button ##
    textupdater4 <- reactive({
        I <- as.character(input$text) 
        WL <- as.character(wordPredictionL())
        observeEvent(input$sugg4, {updateTextInput(session, "text", value = paste(I, WL))})
    })
    ## suggestion add button ##
    textupdater5 <- reactive({
        I <- as.character(input$text) 
        WL <- as.character(input$text2) %>% tidyText()
        observeEvent(input$butt1, {updateTextInput(session, "text", value = paste(I, WL, sep = " "))})
        observeEvent(input$butt1, {updateTextInput(session, "text2", value = "")})
    })
        
    ## full output ##   
    fullText <- reactive({
        I <- as.character(input$text) 
        W <- as.character(wordPrediction())
        WL <- as.character(wordPredictionL())
        updateActionButton(session, "sugg1", label = W[[1]])
        updateActionButton(session, "sugg2", label = W[[2]])
        updateActionButton(session, "sugg3", label = W[[3]])
        updateActionButton(session, "sugg4", label = WL)
        switchFunc(W, WL)
        return(I)   
    })
        
    ## prediction learning ##     
    predictLearn <- reactive({
        sw <- input$butt1
        I <- isolate(input$text)
        newSugg <- isolate(input$text2)
        newSugg <- tidyText(newSugg)
        newSuggBody <- mainInputL(I)
        newSuggBody[3] <- newSugg
        gram1 <<- rbind(gram1, newSuggBody)
        return(gram1)
    }) 
        
    observeEvent(input$butt1, {predictLearn()
        textupdater5()})
    observeEvent(input$sugg1, {textupdater1()})
    observeEvent(input$sugg2, {textupdater2()})
    observeEvent(input$sugg3, {textupdater3()})
    observeEvent(input$sugg4, {textupdater4()})
    output$finalInput <- renderPrint(fullText())
    output$testDF <- renderDataTable(predictLearn())
})    
