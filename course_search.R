# Set up libraries ----
library(shiny)
library(shinythemes)
library(shinyjs)
library(RSQLite)
library(DBI)
library(dplyr)
library(tidytext)
library(tm)
library(Snowball)

#--------------------------------------------
#---------------     UI    ------------------
#--------------------------------------------
ui<-tagList(tags$head(tags$link(rel = "icon", type = "image/x-icon",
                                href = "https://images.app.goo.gl/LoiVQFgG2B7kECFz7")),

                    useShinyjs(),
                    navbarPage(title="Coursera Search", id = "tabs",
                    theme = shinytheme("flatly"),

                    #Search tab panel ----
                    tabPanel("Search", 
                        sidebarPanel(
                            textInput("query", "Enter keywords", placeholder = "") 
                        ),
                        mainPanel(
                            tabsetPanel(
                                tabPanel("Course List", 
                                        DT::dataTableOutput("courses")), 
                                tabPanel("Result", 
                                        tableOutput("result"))
                            )
                        )
                    ), 

                    # About the app ----
                    tabPanel("About", 
                        h1("About the app"), tags$hr(), 
                        p()
                    ))
)

#--------------------------------------------
#--------------    Server    ----------------
#--------------------------------------------
server <- (function(input, output, session){

    # Import data from SQLite database "coursera.db" ----
    conn <- dbConnect(RSQLite::SQLite(), dbname = "coursera.db")
    courses_db <- dbReadTable(conn,'coursera')
    courses_db <- courses_db[, !(names(courses_db) %in% 'id')]
    dbDisconnect(conn)

    # Calculate words' frequency and number of words in each title ----
    word_freq <- function(dataset){
        title <- as.character(factor(dataset$title))
        course_title <- tibble(course_title = title, title = title)

        # Number of times a word appears in the title
        course_words <- course_title %>%
            unnest_tokens(word, title, to_lower = FALSE) %>%
            count(course_title, word, sort = TRUE)
        
        # Number of words in the title
        total_words <- course_words %>% 
            group_by(course_title) %>% 
            summarize(total = sum(n))

        course_words <- left_join(course_words, total_words)
        return(course_words)
    }

    # Calculate TF-IDF ----
    tf_idf <- function(word_freq){

        # Rank the words and calculate the frequency
        freq_by_rank <- word_freq %>% 
            group_by(course_title) %>% 
            mutate(rank = row_number(), 
            `term frequency` = n/total)

        # Calculate TF-IDF
        tfidf_tibble <- freq_by_rank %>%
            bind_tf_idf(word, course_title, n)  

        return(tfidf_tibble) 
    }

    # Display courses list ----
    output$courses <- DT::renderDataTable({
        DT::datatable(courses_db, options = list(sDom  = '<"top">lrt<"bottom">ip'))
    })

    # Process query -----
    process_query <- function(query, doc.list){
        
    }

    # Render result -----
    output$result <- renderTable({
        process_query(input$query, )
    })


    # Testing ----
    wf <- word_freq(courses_db)
    tf <- tf_idf(wf)
    print(tf)
    
    
    

   
})

                      
# Create Shiny app ----
shinyApp(ui, server)
                   
            