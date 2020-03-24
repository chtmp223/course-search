#!/usr/bin/env Rscript

#' Helper functions for server.R 
#'
#' @description
#' Helper functions for backend of an RShiny app that allows user 
#' perform search for course titles on the given database using a keyword
#' * `CreateCorpus()` creates a corpus
#' * `WeightTerm()` calculate the weight of each term in the title
#' * `TfIdf()` creates a TF-IDF matrix
#' * `TitleScore()` calculates the score for each title

if (!require("dplyr"))
  install.packages("dplyr")
if (!require("tidytext"))
  install.packages("tidytext")
if (!require("tm"))
  install.packages("tm")
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
#' @param title_list A vector containing all the titles
#' @return Weight of each term
#' @example
#' WeightTerm("fundamental", c("hello", "test"))
WeightTerm <- function(tfidf_row, title_list) {
  term_df <- sum(tfidf_row[1:length(title_list)] > 0)
  weight <- rep(0, length(tfidf_row))
  weight[tfidf_row > 0] <- (1 + log2(tfidf_row[tfidf_row > 0])) * log2(length(title_list) / term_df)
  return(weight)
}

#' Calculate TF-IDF ----
#'
#' @param corpus A corpus
#' @param title_list A vector containing all the titles
#' @return A TF-IDF matrix
#' @example
#' TfIdf(corpus, c("hello", "test"))
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
#' @param title_list A vector containing all the titles
#' @return a dataframe containing score for each title
#' @example
#' TitleScore(matrix, c(c("hello", "test")))
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
