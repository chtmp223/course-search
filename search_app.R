#!/usr/bin/env Rscript

search_app <- function(db) {
  # Set up libraries ----
  require(shiny)
  require(shinythemes)
  require(shinyjs)
  require(RSQLite)
  require(DBI)
  require(dplyr)
  require(tidytext)
  require(tm)
  require(shinyBS)
  
  shinyApp(
    #--------------------------------------------
    #---------------     UI    ------------------
    #--------------------------------------------
    ui<-tagList(tags$head(tags$link(rel = "icon", type = "image/x-icon",
                                    href = "https://images.app.goo.gl/LoiVQFgG2B7kECFz7")),
                
                useShinyjs(),
                navbarPage(title="Course Search", id = "tabs",
                           theme = shinytheme("flatly"),
                           
                           #Search tab panel ----
                           tabPanel("Search", 
                                    sidebarPanel(
                                        textInput("query", "Enter a keyword: ", placeholder = ""), 
                                        bsTooltip("query","Enter a single keyword","right"),
                                        br(), 
                                        sliderInput("num", "Number of results displayed: ", min= 0, max = 100, value = 10, step = 5),
                                        bsTooltip("num", "Choose the number of results you want to see", "right"),
                                        actionButton("queried", "Go to Results"),
                                        bsTooltip("queried", "Hit the button to see the results", "right")
                                    ),
                                    mainPanel(
                                        tabsetPanel(
                                            id = "tabset", 
                                            tabPanel(value = "courses", "Course List", 
                                                     br(), 
                                                     DT::dataTableOutput("courses")), 
                                            tabPanel(value = "result",  "Result", 
                                                     br(), 
                                                     tableOutput("result"))
                                        )
                                    )
                           
                           ))
    ),
    
    #--------------------------------------------
    #--------------    Server    ----------------
    #--------------------------------------------
    server <- (function(input, output, session){
      
      # Switch to tab "Result" when button is clicked ----
      observeEvent(input$queried,{
        updateTabsetPanel(session, "tabset",
                          selected = "result")
      })
      
      # Import data from SQLite database ----
      conn <- suppressWarnings(dbConnect(RSQLite::SQLite(), dbname = db)) 
      courses_db <- dbReadTable(conn,substr(db, 1,8))
      courses_db <- courses_db[, !(names(courses_db) %in% 'id')]
      dbDisconnect(conn)
      
      # Display courses list ----
      output$courses <- DT::renderDataTable({
        DT::datatable(courses_db, options = list(sDom  = '<"top">lrt<"bottom">ip'))
      })
      
      # Global variable ----
      title_list <- as.character(factor(courses_db$title))
      N.titles <- length(title_list)
      
      # Create corpus -----
      create_corpus <- function(query, dataset){
        title_list <- as.character(factor(dataset$title))
        query <- strsplit(query, " ")
        vector_title <- VectorSource(c(title_list, query))
        vector_title$Names <- c(names(title_list), "query")
        corpus <- Corpus(vector_title)
        corpus <- tm_map(corpus, removePunctuation)
        corpus <- tm_map(corpus, removeNumbers)
        corpus <- tm_map(corpus, tolower)
        corpus <- tm_map(corpus, stripWhitespace)
        return (corpus)
      }
      
      # Calculate weight per term ----
      weight_term <- function(tfidf_row) {
        term_df <- sum(tfidf_row[1:N.titles] > 0)
        weight <- rep(0, length(tfidf_row))
        weight[tfidf_row > 0] <- (1 + log2(tfidf_row[tfidf_row > 0])) * log2(N.titles/term_df)
        return(weight)
      }
      
      # Calculate TF-IDF ----
      tf_idf <- function(corpus){
        
        # Create term-title matrix 
        term_title <- as.matrix(TermDocumentMatrix(corpus, control = list
                                                   (weighting = function(x) weightTfIdf(x, normalize = FALSE))))
        
        # Create TF-IDF matrix
        tfidf_matrix <- t(apply(term_title, c(1), FUN = weight_term))
        colnames(tfidf_matrix) <- colnames(term_title)
        tfidf_matrix <- scale(tfidf_matrix, center = FALSE, scale = sqrt(colSums(tfidf_matrix^2)))
        return(tfidf_matrix)
      }
      
      # Calculate the title scores ----
      title_score <- function(tfidf_matrix){
        
        # Separate query and titles
        query_vector <- tfidf_matrix[, (N.titles+1)]
        tfidf_matrix <- tfidf_matrix[, 1:N.titles]
        
        # Calculate dot product
        title_scores <- t(query_vector) %*% tfidf_matrix
        results <- data.frame(title = title_list, score = t(title_scores))
        results <- results[order(results$score, decreasing = TRUE), ]
        return (results)
      }
      
      # Return the finished table ----
      render_result <- function(table_result){
        if (is.na(table_result)){
          table_result <- data.frame(Message = "Enter another keyword. For example: fundamentals")
        }
        else{
          table_result <- table_result[1:input$num,]
        }
        return (table_result)
      }
      
      # Render result -----
      output$result <- renderTable({
        corpus <- suppressWarnings(create_corpus(input$query, courses_db))
        result <- title_score(tf_idf(corpus))
        table_result <- result[result$score > 0.00,]
        table_result <- suppressWarnings(render_result(table_result))
        return (table_result)
      })
      
    })
  )
}

