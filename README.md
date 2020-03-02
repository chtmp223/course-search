# Coursera-Search

 **Overview**
 ----
 Coursera Search is a small-scaled web app that can be used to search for titles on Coursera. The link of the project can be founded here: https://coursera-search.shinyapps.io/course-search/ 

**Description**
 ----
- Used Scrapy to scrape courses data (course_getter) from https://www.coursera.org/courses/ and stored the result in a SQLite database (coursera.db)
- Built an RShiny web app (stored in folder course-search) to get the user's query and return ranked results (using TF-IDF weighting scheme on the database). 

 **Workflow**
 ----
 To run the application from your computer.
 1. On your terminal, cd to Course-Search/course-search/
 2. Type "scrapy crawl courses" to scrape https://www.coursera.org/courses/ (update coursera.db file).
 3. Open both ui.R and server.R in R-Studio, hit the 'Run' button on the top right of the code. 
 4. When you're in the app, enter a keyword, adjust result length and hit search.  

**Discussion**
 ----
 Since this web app operates on a small database (~950 entries), I developed it with R and RShiny, which works well with small datasets. Right now, the app has the following limitations and suggestions for improvements: 
 1. This app only allows the user to enter one keyword 
 2. This app will run slowly on larger dataset -> develop another app with Python and Django framework. 
 3. This app only allows the user to search for titles -> include the course description, course link in the SQLite database. 
 4. This app is not mobile-friendly -> add css to the app 
