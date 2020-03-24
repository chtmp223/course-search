# !/usr/bin/python
# -*- coding: utf-8 -*-

# Created on 2020-03-24
# Class: Spider Test
# Comment: Unit testing for parse function of spider

import unittest
from course_getter.spiders import courses
from responses.response import fake_response

class SpiderTest(unittest.TestCase):
    '''
    Unit testing for parse function of spider
    '''

    def setUp(self):
        '''
        Set up spider

        Arg: 
            self: instance of the class 
        '''
        self.spider = courses.CoursesSpider()


    def test_parse(self):
        '''
        Test the length of the parsed field with fake response file 

        Arg: 
            self: instance of the class 
        '''
        response = fake_response('courses.html')
        results = self.spider.parse(response)

        for field in results:
            self.assertEqual(len(field['title']), 10)
            self.assertEqual(len(field['partner']), 10)
            self.assertEqual(len(field['rating']), 10)
            self.assertEqual(len(field['count']), 10)
            self.assertEqual(len(field['enrollment']), 10)
            self.assertEqual(len(field['level']), 10)

if __name__ == "__main__":
    unittest.main()