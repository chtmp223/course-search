#!/usr/bin/env Rscript
source('./search_app.R')

if (!require("testthat"))
  install.packages("testthat")

test_that("Create Corpus", {
  courses_db <- data.frame(title = c("hello", "test"))
  corpus <- suppressWarnings(CreateCorpus("fundamentals", courses_db))
  corpus_df <- data.frame(title = sapply(corpus, as.character), stringsAsFactors = FALSE)
  expect_equal(length(corpus_df$title), 3)
})

