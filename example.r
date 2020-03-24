library(shiny)
setwd("/Users/cpham/Downloads/")
runApp("Course-Search/search_app.R")

library(shinytest)
recordTest("Course-Search/search_app.R")
