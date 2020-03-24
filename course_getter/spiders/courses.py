# !/usr/bin/python
# -*- coding: utf-8 -*-

# Created on 2020-03-22
# Class: Courses Spider 
# Comment: Initiate requests, specify fields to be scraped and stored to item model

import scrapy
import re
import sys
from ..items import CourseGetterItem


class CoursesSpider(scrapy.Spider):
    '''
    Initiate requests
    Specify fields to be scraped and stored to item model
    '''
    name = 'courses'

    def __init__(self, address='', *args, **kwargs):
        '''
        Start crawl requests to "https://www.coursera.org/courses"
        Args: 
            self: instance of the class
            address: custom url, specified in command line arg
        '''
        # process the entered url
        if address == '':
            print("Custom url is not specified or invalid. System will use default url instead.")
            self.start_urls = ["https://www.coursera.org/courses?query=&indices%5Bprod_all_products_term_optimization%5D%5Bpage%5D=" + str(i)+ "&indices%5Bprod_all_products_term_optimization%5D%5Bconfigure%5D%5BclickAnalytics%5D=true&indices%5Bprod_all_products_term_optimization%5D%5Bconfigure%5D%5BruleContexts%5D%5B0%5D=en&indices%5Bprod_all_products_term_optimization%5D%5Bconfigure%5D%5BhitsPerPage%5D=10&configure%5BclickAnalytics%5D=true" for i in range(1,101)]
        else: 
            self.start_urls = ['{!s}'.format(address)]
        super(CoursesSpider, self).__init__(*args, **kwargs)
        

    def parse(self, response):
        '''
        Write reponse to item model 
        Args: 
            self: instance of the class
            response: response object obtained from the request
        '''
        items = CourseGetterItem()

        # specify the location of the fields to be scraped on the web page
        titles = response.xpath('//h2[@class="color-primary-text card-title headline-1-text"]/text()').getall() 
        partners = response.css("span.partner-name::text").getall()  
        ratings = response.css("span.ratings-text::text").getall()  
        count = response.xpath('//span[@class="ratings-count"]/span/text()').getall()
        enrollment = response.css("span.enrollment-number::text").getall()  
        level = response.css("span.difficulty::text").getall()  

        # specify the field names in item model
        items['title'] = titles
        items['partner'] = partners
        items['rating'] = ratings
        items['count'] = count
        items['enrollment'] = enrollment
        items['level'] = level 

        yield items
        
