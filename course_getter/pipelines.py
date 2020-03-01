# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://docs.scrapy.org/en/latest/topics/item-pipeline.html

import sqlite3

class CourseGetterPipeline(object):

    def __init__(self):
        self.create_connection()
        self.create_table()
    

    def create_connection(self): 
        '''
        establish connection to the database
        '''
        self.conn = sqlite3.connect("coursera.db")
        self.curr = self.conn.cursor()


    def create_table(self): 
        '''
        create and drop the table when appropriate
        '''
        self.curr.execute('''DROP TABLE IF EXISTS coursera''')
        self.curr.execute('''CREATE TABLE IF NOT EXISTS coursera (
                id integer PRIMARY KEY AUTOINCREMENT,
                title text,
                partner text,
                rating text,
                rating_count text,
                enrollment text,
                level text
            )''')


    def store_db(self, item):
        '''
        insert courses into the database
        '''
        for i in range(min([len(item['title']),len(item['partner']), len(item['rating']), len(item['count']), len(item['enrollment']), len(item['level'])])): 
            self.curr.execute('''INSERT INTO coursera(title, partner, rating, rating_count, enrollment, level)
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
