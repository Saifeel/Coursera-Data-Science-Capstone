suppressPackageStartupMessages(c(
  library(shinythemes),
  library(shiny),
  library(shinyjs),
  library(tm),
  library(stringr),
  library(markdown),
  library(stylo)))

################################################################################

gram2 <- readRDS(file = "./df/gram2.RData")
gram3 <- readRDS(file = "./df/gram3.RData")
gram4 <- readRDS(file = "./df/gram4.RData")

################################################################################ 

tidyText <- function (rawInput) {
  tt <- tolower(rawInput)
  tt <- removePunctuation(tt)               
  tt <- removeNumbers(tt)
  tt <- stripWhitespace(tt)
  tt
}

################################################################################

mainInput <- function(rawText) {
  input0 <- tidyText(rawText)
  input0 <- txt.to.words(input0,preserve.case = TRUE)
  wc <- length(input0)
  if (wc > 2) {
    input1 <- input0[(wc-2):wc]
  }
  else if(wc == 2){
    input1 <- c(NA, input0)
  }
  else {
    input1 <- c(NA, NA, input0)
  }
  return(input1)
}

################################################################################

mainInputL <- function(rawText) {
  input00 <- tidyText(rawText)
  input00 <- txt.to.words(input00,preserve.case = TRUE)
  wc <- length(input00)
  if (wc > 1) {
    input01 <- input00[(wc-1):wc]
  }
  else if(wc == 1){
    input01 <- c("NA", input00)
  }
  else{
    input01 <- (NA)
  }
  return(input01)
}

################################################################################

wordPredictor <- function(input1){
  prediction1 <- as.character(gram4[gram4$w1==input1[1] & gram4$w2==input1[2] & gram4$w3==input1[3],]
                             [1:3,]$w4)
  searchEnd <- 4
  prediction2 <- NA 
  
  if(is.na(prediction1)) {
    searchEnd <- 3
    prediction1 <- as.character(gram3[gram3$w1==input1[2] & gram3$w2==input1[3],]
                               [1:3,]$w3)
    if(is.na(prediction1)) {
      searchEnd <- 2
      prediction1 <- as.character(gram2[gram2$w1==input1[3],]
                                 [1:3,]$w2)
      if(is.na(prediction1)){
        prediction1 <- "No predictions based on input"
        searchEnd <- 0       
      }
    }
  }
  x <- sum(is.na(prediction1))
  if(x >= 1){
    if(searchEnd == 4){
      prediction2 <- as.character(gram3[gram3$w1==input1[2] & gram3$w2==input1[3],]
                                  [1:3,]$w3)
    }
    else if(searchEnd == 3){
      prediction2 <- as.character(gram2[gram2$w1==input1[3],]
                                  [1:3,]$w2)
    }
    else { 
      prediction2 = NA 
    }
  }
  
  predictions <- c(prediction1, prediction2)
  predictFinal <- predictions %>% unique() %>% na.omit()
  predictFinal[1:3]
}

################################################################################

wordPredictorL <- function(input1, gram1){
  predictionL <- as.character(gram1[gram1$w1==input1[1] & gram1$w2==input1[2],][1,]$w3)
  
  if(is.na(predictionL)){
    predictionL <- "NA"
  }
  predictionL
}

################################################################################

mainFUN <- function(rawInput){
  mi <- mainInput(rawInput)
  p <- wordPredictor(mi)
  if(is.na(p[3]) == TRUE){
    p[3] <- "NA"
    if(is.na(p[2]) == TRUE){
      p[2] <- "NA"
    }
  }
  p
}

################################################################################

LmainFUN <- function(rawInput, gram1){
  mi <- mainInputL(rawInput)
  p <- wordPredictorL(mi, gram1)
  p
}

#################################################################################

switchFunc <- function(W, WL){
  for (i in 1:3){
    sw <- paste("sugg", i, sep = "")
    if (W[[i]] == "NA" | W[[i]] == "No predictions based on input"){
      shinyjs::disable(sw)
    }
    else {
      shinyjs::enable(sw)
    }
  }
  if (WL == "NA"){
    shinyjs::disable("sugg4")
  }
  else {
    shinyjs::enable("sugg4")
 }
  
  
}