#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

suppressWarnings(library(tm))
suppressWarnings(library(stringr))
suppressWarnings(library(quanteda))
suppressWarnings(library(dplyr))
suppressWarnings(library(plyr))
suppressWarnings(library(tidyr))
suppressWarnings(library(stylo))
suppressWarnings(library(data.table))
suppressWarnings(library(SnowballC))
suppressWarnings(library(wordcloud))
suppressWarnings(library(ggplot2))
suppressWarnings(library(scales))
suppressWarnings(library(shiny))
suppressWarnings(library(shinythemes))

bigrams <- readRDS("bigrams.RData");
trigrams <- readRDS("trigrams.RData");
quadgrams <- readRDS("quadgrams.RData");

mymessage <- as.character(NULL);

cleanInput <- function(inputtext){
    textInput <- tolower(inputtext)
    textInput <- removePunctuation(textInput)
    textInput <- removeNumbers(textInput)
    textInput <- str_replace_all(textInput, "[^[:alnum:]]", " ")
    textInput <- stripWhitespace(textInput)
    textInput <- txt.to.words.ext(textInput, language="English.all", preserve.case = TRUE)
    return(textInput)
}

matchBiGrams <- function(inputWord1)
{
    print(inputWord1)
    
    prediction <- c()
    result <- c()
    
    mymessage <<- "Prediction is being calculated using Bigram Tokenizer."
    result <- subset(bigrams, bigrams$word1 == inputWord1)

    matchBiGrams <- result
    #print(mymessage)
    return(matchBiGrams)
}

matchTriGrams <- function(inputWord1, inputWord2)
{
    print(inputWord1)
    print(inputWord2)
    
    prediction <- c()
    result <- c()
    
    mymessage <<- "Prediction is being calculated using Trigram Tokenizer."
    
    result <- subset(trigrams, trigrams$word1 == inputWord1 & trigrams$word2 == inputWord2)

    matchTriGrams <- result
    #print(mymessage)
    return(matchTriGrams)
}


matchQuadGrams <- function(inputWord1, inputWord2, inputWord3)
{
    print(inputWord1)
    print(inputWord2)
    print(inputWord3)
    
    prediction <- c()
    result <- c()
    
    mymessage <<- "Prediction is being calculated using Quadgram Tokenizer."
    
    result <- subset(quadgrams, quadgrams$word1 == inputWord1 & quadgrams$word2 == inputWord2 & quadgrams$word3 == inputWord3)
    matchQuadGrams <- result
    #print(mymessage)
    return(matchQuadGrams)
}

predictWord <- function(receivedWord){
    print(receivedWord)
    inputword  <- cleanInput(receivedWord)
    inputword
    inwordlength <- length(inputword)
    inwordlength
    
    #Initializing response
    prediction <- c()
    
    mymessage <<- ""
    
    #Two gram match
    if(inwordlength == 0){
        mymessage <<- "Please enter any word for next word prediction!..."
    }else if(inwordlength == 1){
        mymessage <<- "Prediction is being calculated using Bigram Tokenizer."
        prediction <- matchBiGrams(inputword)
    }else if(inwordlength == 2){
        input <- matrix(unlist(inputword), ncol=2, byrow=TRUE)
        mymessage <<- "Prediction is being calculated using Trigram Tokenizer."
        prediction <- matchTriGrams(input[,1], input[,2])
    }else if(inwordlength == 3){
        input <- matrix(unlist(inputword), ncol=3, byrow=TRUE)
        mymessage <<- "Prediction is being calculated using Quadgram Tokenizer."
        prediction <- matchQuadGrams(input[,1], input[,2], input[,3])
    }else if(inwordlength > 3){
        #Trimming input to the last three words
        inputword <- inputword[(inwordlength - 2):inwordlength]
        input <- matrix(unlist(inputword), ncol=3, byrow=TRUE)
        mymessage <<- "Prediction is being calculated using Quadgram Tokenizer."
        prediction <- matchQuadGrams(input[1], input[2], input[3])
    }
    mymessage <<- "Prediction is being calculated using Bigram Tokenizer."
    predictWord <- prediction[1:5,]
    return(predictWord)
}


# Define UI for application that draws a histogram
ui <- fluidPage(theme = shinytheme("spacelab"),
        
        # Application title
        strong(titlePanel("Coursera : Final Capstone Project : Next Word Prediction")),
        tags$hr(),
        
        sidebarLayout(
            sidebarPanel(
                tags$h4("Author: Vaishali Katkar"),
                tags$h4("Date: 03-Dec-2017"),
                hr(),
                textInput("inputString", "Enter any word to predict next word.",value = ""),        
                submitButton("Next Word"),
                hr(),
                tags$ul(
                    tags$li(tags$span("The prediction of words will be upto quadgrams and result will be displayed upto first five rows.")),
                    br(),
                    tags$li(tags$span("If more words are typed after quadgrams, it will consider the last three words entered as trigram and predict fourth gram.")),
                    br(),
                    tags$li(tags$span("If no words found then it will display value 'NA' in records."))
                )
            ),
            mainPanel(
                tags$div(
                    tabsetPanel(
                        tabPanel("Result", 
                                 tags$div(style = "color:brown",align="Center",
                                          strong(tableOutput("nextWord"))
                                 )
                        ),
                        tabPanel("Example", 
                                 strong(tags$ul(
                                             tags$li("If word 'as' is entered, then it will search in bigrams, with first keyword and return all the records with its frequency in decending order."),
                                             br(),
                                             tags$li("If word 'as well' is entered, then it will search in trigrams, with first two keywords and return all the records with its frequency in decending order."),
                                             br(),
                                             tags$li("If word 'as well as' is entered, then it will search in quadgrams, with first three keywords and return all the records with its frequency in decending order."),
                                             br(),
                                             tags$li("If more words than three words are entered, then it will take latest three words and search in quadgrams, to return all the records with its frequency in decending order.")
                                     )
                                 )
                        )
                    )
                )
            )
        )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    predictNextWord <- reactive(predictWord(input$inputString))
    #output$message <- renderText(mymessage)
    output$nextWord <- renderTable({predictNextWord()})
    observeEvent(input$reset, {input$inputString <- NULL})
}

# Run the application 
shinyApp(ui = ui, server = server)

