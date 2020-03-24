#!/usr/bin/env Rscript

#' Apply a function to each element of a vector
#'
#' @description
#' An RShiny app that allows user perform search for course titles on 
#' the given database using a keyword
#' 
#' * `CreateCorpus()` creates a corpus
#' * `WeightTerm()` calculate the weight of each term in the title
#' * `TfIdf()` creates a TF-IDF matrix
#' * `TitleScore()` calculates the score for each title
#' * `RenderResult()` displays the result of the search (title - title score)


# Set up libraries ----
if (!require("shiny"))
  install.packages("shiny")
if (!require("shinythemes"))
  install.packages("shinythemes")
if (!require("shinyjs"))
  install.packages("shinyjs")
if (!require("RSQLite"))
  install.packages("RSQLite")
if (!require("dplyr"))
  install.packages("dplyr")
if (!require("DBI"))
  install.packages("DBI")
if (!require("tidytext"))
  install.packages("tidytext")
if (!require("tm"))
  install.packages("tm")
if (!require("shinyBS"))
  install.packages("shinyBS")

#--------------------------------------------
#---------     Helper Functions    ----------
#--------------------------------------------
#' Create corpus -----
#'
#' @param query A string
#' @param dataset A SQLite table/A dataset
#' @return A corpus containing all the titles & query 
#' in a natural text format
#' @example
#' CreateCorpus("fundamental", data.frame(title = c("hello", "test")))
CreateCorpus <- function(query, dataset) {
  term_list <- as.character(factor(dataset$title))
  query <- strsplit(query, " ")
  vector_title <- VectorSource(c(term_list, query))
  vector_title$Names <- c(names(term_list), "query")
  corpus <- Corpus(vector_title)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, tolower)
  corpus <- tm_map(corpus, stripWhitespace)
  return(corpus)
}

#' Calculate weight per term ----
#'
#' @param tfidf_row A string
#' @return Weight of each term
#' @example
#' WeightTerm("fundamental")
WeightTerm <- function(tfidf_row, title_list) {
  term_df <- sum(tfidf_row[1:length(title_list)] > 0)
  weight <- rep(0, length(tfidf_row))
  weight[tfidf_row > 0] <- (1 + log2(tfidf_row[tfidf_row > 0])) * log2(length(title_list) / term_df)
  return(weight)
}

#' Calculate TF-IDF ----
#'
#' @param corpus A corpus
#' @return A TF-IDF matrix
#' @example
#' TfIdf(corpus)
TfIdf <- function(corpus, title_list) {
  
  # Create term-title matrix
  term_title <- as.matrix(TermDocumentMatrix(corpus, control = list
                                             (weighting = function(x) weightTfIdf(x, normalize = FALSE))))
  
  # Create TF-IDF matrix
  tfidf_matrix <- t(apply(term_title, c(1), FUN = WeightTerm, title_list))
  colnames(tfidf_matrix) <- colnames(term_title)
  tfidf_matrix <- scale(tfidf_matrix, center = FALSE, scale = sqrt(colSums(tfidf_matrix^2)))
  return(tfidf_matrix)
}

#' Calculate the title scores ----
#'
#' @param tfidf_matrix A matrix
#' @return a dataframe containing score for each title
#' @example
#' TitleScore(matrix)
TitleScore <- function(tfidf_matrix, title_list) {
  
  # Separate query and titles
  query_vector <- tfidf_matrix[, (length(title_list) + 1)]
  tfidf_matrix <- tfidf_matrix[, 1:length(title_list)]
  
  # Calculate dot product
  title_scores <- t(query_vector) %*% tfidf_matrix
  results <- data.frame(title = title_list, score = t(title_scores))
  results <- results[order(results$score, decreasing = TRUE), ]
  return(results)
}
  
# RShiny function ----
shinyApp(
  #--------------------------------------------
  #---------------     UI    ------------------
  #--------------------------------------------
  ui <- tagList(
    tags$head(tags$link(
      rel = "icon", type = "image/x-icon",
      href = "https://images.app.goo.gl/LoiVQFgG2B7kECFz7"
    )),
    
    useShinyjs(),
    navbarPage(
      title = "Course Search", id = "tabs",
      theme = shinytheme("flatly"),
      
      # Search tab panel ----
      tabPanel(
        "Search",
        sidebarPanel(
          textInput("query", "Enter a keyword: ", placeholder = ""),
          bsTooltip("query", "Enter a single keyword", "right"),
          br(),
          sliderInput("num", "Number of results displayed: ", min = 0, max = 100, value = 10, step = 5),
          bsTooltip("num", "Choose the number of results you want to see", "right"),
          actionButton("queried", "Go to Results"),
          bsTooltip("queried", "Hit the button to see the results", "right")
        ),
        mainPanel(
          tabsetPanel(
            id = "tabset",
            tabPanel(
              value = "courses", "Course List",
              br(),
              DT::dataTableOutput("courses")
            ),
            tabPanel(
              value = "result", "Result",
              br(),
              tableOutput("result")
            )
          )
        )
      )
    )
  ),
  
  #--------------------------------------------
  #--------------    Server    ----------------
  #--------------------------------------------
  server <- (function(input, output, session) {
    
    # Switch to tab "Result" when button is clicked ----
    observeEvent(input$queried, {
      updateTabsetPanel(session, "tabset",
                        selected = "result"
      )
    })
    
    #--------------------------------------------
    #-------------     Database    --------------
    #--------------------------------------------
    # Import data from SQLite database via command line arg ----
    db <- commandArgs(trailingOnly = TRUE)[1]
    conn <- suppressWarnings(dbConnect(RSQLite::SQLite(), dbname = db))
    courses_db <- dbReadTable(conn, "courses")
    courses_db <- courses_db[, !(names(courses_db) %in% "id")]
    dbDisconnect(conn)
    
    # Global variable - List of titles ----
    title_list <- as.character(factor(courses_db$title))
    
    # Display courses list ----
    output$courses <- DT::renderDataTable({
      DT::datatable(courses_db, options = list(sDom = '<"top">lrt<"bottom">ip'))
    })
    
    #' Return the finished table ----
    #'
    #' @param table_result A dataframe
    #' @return a dataframe containing the final result (title-score of title)
    #' @example
    #' RenderResult(table)
    RenderResult <- function(table_result) {
      if (is.na(table_result)) {
        table_result <- data.frame(Message = "Enter another keyword. For example: fundamentals")
      }
      else {
        table_result <- table_result[1:input$num, ]
      }
      return(table_result)
    }
    
    # Render result -----
    output$result <- renderTable({
      corpus <- suppressWarnings(CreateCorpus(input$query, courses_db))
      result <- TitleScore(TfIdf(corpus, title_list), title_list)
      table_result <- result[result$score > 0.00, ]
      table_result <- suppressWarnings(RenderResult(table_result))
      return(table_result)
    })
  })
)