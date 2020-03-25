[![Build Status](https://travis-ci.com/chtmp223/Course-Search.svg?branch=master)](https://travis-ci.com/chtmp223/Course-Search)
# Coursera-Search
Coursera Search is a system that allows user to perform course search based on titles in Coursera. This system will scrape course data from https://www.coursera.org/courses/ and store them in a SQLite database. The course data information includes course title, partner, rating, number of ratings, enrollment number, and difficulty level. The user can then search for courses by entering a title keyword in the web app, hit the search button and then browse the result.
A demo of the web app can be found at 


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
1. 


 **Usage**
 ----
 1. Install packages: 
    `$ pip install -r requirements.txt`
 2. Run `$ sh process.sh`
 3. Click on the localhost link (For example: `http://127.0.0.1:5893`)

**Discussion**
 ----
 Since this web app operates on a small database (~950 entries), I developed it with R and RShiny, which works well with small datasets. Right now, the app has the following limitations and suggestions for improvements: 
 1. This app only allows the user to enter one keyword 
 2. This app will run slowly on larger dataset -> develop another app with Python and Django framework. 
 3. This app only allows the user to search for titles -> include the course description, course link in the SQLite database. 
 4. This app is not mobile-friendly -> add css to the app 


**Contact**
----
1. Name: Chau Pham 
2. Email: chautm.pham@gmail.com