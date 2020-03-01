# -*- coding: utf-8 -*-
import scrapy
import re
from ..items import CourseGetterItem


class CoursesSpider(scrapy.Spider):
    name = 'courses'


    def start_requests(self):
        '''
        start crawling "https://www.coursera.org/courses"
        '''
        page_list = []
        for i in range(1,101):
            page_list.append("https://www.coursera.org/courses?query=&indices%5Bprod_all_products_term_optimization%5D%5Bpage%5D="+ str(i)+"&indices%5Bprod_all_products_term_optimization%5D%5Bconfigure%5D%5BclickAnalytics%5D=true&indices%5Bprod_all_products_term_optimization%5D%5Bconfigure%5D%5BruleContexts%5D%5B0%5D=en&indices%5Bprod_all_products_term_optimization%5D%5Bconfigure%5D%5BhitsPerPage%5D=10&configure%5BclickAnalytics%5D=true")
        self.index = 0
        urls = page_list
        for url in urls:
            # make a request to each url and call the parse function on the http response.
            yield scrapy.Request(url=url, callback=self.parse)


    def parse(self, response):
        '''
        write reponse to item model 
        '''
        items = CourseGetterItem()

        titles = response.xpath('//h2[@class="color-primary-text card-title headline-1-text"]/text()').getall() 
        partners = response.css("span.partner-name::text").getall()  
        ratings = response.css("span.ratings-text::text").getall()  
        count = response.xpath('//span[@class="ratings-count"]/span/text()').getall()
        enrollment = response.css("span.enrollment-number::text").getall()  
        level = response.css("span.difficulty::text").getall()  

        items['title'] = titles
        items['partner'] = partners
        items['rating'] = ratings
        items['count'] = count
        items['enrollment'] = enrollment
        items['level'] = level 

        yield items
        
