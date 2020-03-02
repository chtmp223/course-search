# Set up libraries ----
library(shiny)
library(shinythemes)
library(shinyjs)
library(RSQLite)
library(DBI)
library(dplyr)
library(tidytext)
library(tm)
library(shinyBS)

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
)


