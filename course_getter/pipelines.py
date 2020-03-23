# !/usr/bin/python
# -*- coding: utf-8 -*-

# Created on 2020-03-22
# Class: Course Getter Pipeline 
# Comment: Create and store scraped data in SQLite database 
# Documentation: https://docs.scrapy.org/en/latest/topics/item-pipeline.html

import sqlite3
from scrapy.exceptions import NotConfigured


class CourseGetterPipeline(object):

    def __init__(self, db):
        '''
        initialize connection and database table
        '''
        self.db_name = db
        self.create_connection()
        self.create_table()
    

    @classmethod
    def from_crawler(cls, crawler):
        '''
        get name for SQLite db
        '''
        db_settings = crawler.settings.getdict("DB_SETTINGS")
        if not db_settings:
            raise NotConfigured
        return cls(db_settings['db'])


    def create_connection(self): 
        '''
        establish connection to the database
        '''
        self.conn = sqlite3.connect(self.db_name)
        self.curr = self.conn.cursor()


    def create_table(self): 
        '''
        create and drop the table when appropriate
        '''
        self.curr.execute('''DROP TABLE IF EXISTS COURSES''')
        # change the field names when the Coursera page layout changes 
        self.curr.execute('''CREATE TABLE IF NOT EXISTS COURSES(
                id integer PRIMARY KEY AUTOINCREMENT,
                title text,
                partner text,
                rating text,
                rating_count text,
                enrollment text,
                level text
            )''' .format(self.db_name))


    def store_db(self, item):
        '''
        insert courses into the database
        '''
        # change the field names when the page layout changes 
        for i in range(min([len(item['title']),len(item['partner']), len(item['rating']), len(item['count']), len(item['enrollment']), len(item['level'])])): 
            self.curr.execute('''INSERT INTO COURSES(title, partner, rating, rating_count, enrollment, level)
                VALUES(?,?,?,?,?,?)''',(
                    item['title'][i], 
                    item['partner'][i], 
                    item['rating'][i], 
                    item['count'][i], 
                    item['enrollment'][i], 
                    item['level'][i]
                ))
        self.conn.commit()


    def process_item(self, item, spider):
        '''
        store and return item 
        '''
        self.store_db(item)
        return item
