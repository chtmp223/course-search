#!/usr/bin/env Rscript

#' Report test coverage for unit testing of helper 
#' functions (test_search_app.R)

if (!require("covr"))
  install.packages("covr")
cov <- file_coverage("search_app/helper_fct.R", "search_app/test_search_app.R")
report(cov)