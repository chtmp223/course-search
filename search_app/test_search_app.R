#!/usr/bin/env Rscript
source('./helper_fct.R')

if (!require("testthat"))
  install.packages("testthat")

if (!require("covr"))
  install.packages("covr")

test_that("Create Corpus", {
  courses_db <- data.frame(title = c("hello", "test"))
  corpus <- suppressWarnings(CreateCorpus("fundamentals", courses_db))
  corpus_df <- data.frame(title = sapply(corpus, as.character), stringsAsFactors = FALSE)
  expect_equal(length(corpus_df$title), 3)
})

test_that("Weight Term", {
  tfidf_row <- c(1, 2, 3, 0, 0, 6)
  title_list <- c('hello', 'test', 'time', 'hehe')
  expect_equal(length(WeightTerm(tfidf_row, title_list)), 6)
})

test_that("TFIDF", {
  courses_db <- data.frame(title = c("hello", "test"))
  corpus <- suppressWarnings(CreateCorpus("fundamentals", courses_db))
  title_list <- c('hello', 'test')
  tfidf_mat <- TfIdf(corpus, title_list)
  expect_equal(tfidf_mat[,1][['hello']], 1)
  expect_equal(tfidf_mat[,2][['test']], 1)
})

test_that("Score Matrix", {
  courses_db <- data.frame(title = c("hello", "test"))
  corpus <- suppressWarnings(CreateCorpus("fundamentals", courses_db))
  title_list <- c('hello', 'test')
  tfidf_mat <- TfIdf(corpus, title_list)
  score_mat <- TitleScore(tfidf_mat, title_list)
  expect_equal(length(score_mat$title), length(title_list))
})


