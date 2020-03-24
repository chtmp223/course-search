#!/usr/bin/env Rscript

#' Server class of the Shiny App 
#'
#' @description
#' Backend of an RShiny app that allows user perform search for course titles on 
#' the given database using a keyword
#' 
#' * `RenderResult()` displays the result of the search (title - title score)

# Set up libraries ----
source('./helper_fct.R')
if (!require("RSQLite"))
  install.packages("RSQLite")

if (!require("DBI"))
  install.packages("DBI")

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
  # Import data from SQLite database via command line arg ----
  if (length(commandArgs(trailingOnly = TRUE))==0){
    db <- 'coursera.db'
  }
  else{
    db <- commandArgs(trailingOnly = TRUE)[1]
  }
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