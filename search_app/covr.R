library(covr)
library(codecov.R)
cov <- file_coverage("search_app/helper_fct.R", "search_app/test_search_app.R")
report(cov)