#!/bin/bash

# Created on 2020-03-22
# @Author: Chau Pham
# Comment: Automate the project

# Scrape courses from coursera - using default url
# To save scraped data to a custom database, change DB_SETTINGS in settings.py
scrapy crawl courses

# Scrape courses from a custom page in Coursera (uncomment and change address to use)
#scrapy crawl courses -a address=https://www.coursera.org/courses

# run RShiny app for each available database file in the folder
FILES=`ls search_app/*.db`
for file in $FILES
do
    R -e 'shiny::runApp("search_app")' $file
done