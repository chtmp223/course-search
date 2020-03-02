# Set up libraries ----
library(shiny)
library(shinythemes)
library(shinyjs)
library(RSQLite)
library(DBI)
library(dplyr)
library(tidytext)
library(tm)

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
                                    textInput("query", "Enter a keyword: ", placeholder = ""), 
                                    br(), 
                                    sliderInput("num", "Number of results displayed: ", min= 0, max = 100, value = 10, step = 5),
                                    actionButton("queried", "Go to Results")
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
)


