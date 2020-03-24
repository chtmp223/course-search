# !/usr/bin/python
# -*- coding: utf-8 -*-

# Created on 2020-03-22
# Class: Scrapy Settings
# Scrapy settings for course_getter project

BOT_NAME = 'course_getter'

SPIDER_MODULES = ['course_getter.spiders']
NEWSPIDER_MODULE = 'course_getter.spiders'

# Obey robots.txt rules
ROBOTSTXT_OBEY = True

DB_SETTINGS = {
    'db':"search_app/coursera.db"
}
ITEM_PIPELINES = {
    'course_getter.pipelines.CourseGetterPipeline': 300,
}
