# !/usr/bin/python
# -*- coding: utf-8 -*-

# Created on 2020-03-22
# Class: Course Getter Item 
# Define the model for the scraped item 
# See documentation: https://docs.scrapy.org/en/latest/topics/items.html

import scrapy

class CourseGetterItem(scrapy.Item):
    '''
    define the fields for items - change when page layout changes 
    '''
    title = scrapy.Field()
    partner = scrapy.Field()
    rating = scrapy.Field()
    count = scrapy.Field()
    enrollment = scrapy.Field()
    level = scrapy.Field()
