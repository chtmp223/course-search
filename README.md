[![Build Status](https://travis-ci.com/chtmp223/Course-Search.svg?branch=master)](https://travis-ci.com/chtmp223/Course-Search)
# Coursera-Search
Coursera Search is a system that allows user to perform course search based on titles in Coursera. This system will scrape course data from https://www.coursera.org/courses/ and store them in a SQLite database. The course data information includes course title, partner, rating, number of ratings, enrollment number, and difficulty level. The user can then search for courses by entering a title keyword in the web app, hit the search button and then browse the result.


**Environment**
----
1. Python 3.8.2
2. Scrapy 1.8.0
3. SQLite 3.28.0
4. R 3.6.1
5. shiny 1.4.0
6. shinyjs 1.0
7. RSQLite 2.2.0
8. DBI 1.1.0
9. shinythemes 1.1.2
10. dplyr 0.8.3
11. tidytext 0.2.2
12. tm 0.7.7
13. shinyBS 0.61


**Project Structure**
----
1. course_getter: contains Scrapy project 
   a. spiders: 
      - courses.py: Initiate HTTP requests, specify fields to be scraped
   b. items.py: Define the model for scraped items
   c. middlewares.py: Define the model for spider middleware
   d. pipelines.py: Create and store scraped data in SQLite database 
   e. settings.py: Scrapy settings for course_getter project
2. responses: 
   a. courses.html: Manually downloaded from https://www.coursera.org/, used to 
                     create fake HTML responses for unit testing 
   b. response.py: Create a Scrapy fake HTTP response from a HTML file
3. search_app: 
   a. tests: Generated snapshot testing scripts for RShiny app 
   b. covr.R: Report test coverage for unit testing of helper functions (test_search_app.R)
   c. helper_fct.R: Helper functions for Rshiny app 
   d. server.R: Server class of RShiny App 
   e. test_search_app.R: Unit Test script for helper_fct.R
   f. ui.R: UI class of RShiny App 
4. .travis.yml: Script for Travis CI test.
5. DESCRIPTION: Required packages for the system to execute.
6. process.sh: Script to automate the project
7. requirements.txt: Required packages for the system to execute.
8. scrapy.cfg: Config file for Scrapy project
9. test_spider.py: Unit testing script for Scrapy spider


**Usage**
----
1. Install required packages: 
   `$ pip install -r requirements.txt`
2. Run `$ sh process.sh`
3. Click on the localhost link (For example: `http://127.0.0.1:5893`) to access the web app 


**Future work**
----
1. This app only allows the user to enter one keyword. 
- Proposal: update CreateCorpus() & TitleScore() in helper_fct.R such that it treates query as a list instead of a single character. 
2. This app only allows the user to search for titles.
- Proposal: update CreateCorpus() in helper_fct.R such that includes fields other than 'title'. 
3. Include code coverage report for test_search_app.R in travis CI. Right now it is 100%, but I have yet to find a way to run coverage report on test_search_app.R from command line.


**Maintenance**
----
1. Scenario 1: When `www.coursera.org/courses` change their page layout
- Proposal: Change content extraction paths in the parse function in `courses.py` to match the new layout
```
titles = response.xpath('//h2[@class="color-primary-text card-title headline-1-text"]/text()').getall() 
partners = response.css("span.partner-name::text").getall()  
ratings = response.css("span.ratings-text::text").getall()  
count = response.xpath('//span[@class="ratings-count"]/span/text()').getall()
enrollment = response.css("span.enrollment-number::text").getall()  
level = response.css("span.difficulty::text").getall()  
```

2. Scenario 2: When coursera moves to another website/When we use this tool to work on another page 
- Revise Scenario 1
- In `process.sh`, uncomment the following line and change the name of the link: 
```
# Scrape courses from a custom page in Coursera (uncomment and change address to use)
scrapy crawl courses -a address=https://www.coursera.org/courses
```

3. Scenario 3: store the database in a file different from `coursera.db`
- In `course_getter/settings.py`, change the name of the database (don't remove 'search_app'): 
```
DB_SETTINGS = {
    'db':"search_app/coursera.db"
}
```


**Contact**
----
1. Name: Chau Pham 
2. Email: chautm.pham@gmail.com