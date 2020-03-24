# !/usr/bin/python
# -*- coding: utf-8 -*-

# Created on 2020-03-24
# Comment: Create a Scrapy fake HTTP response from a HTML file

import os
from scrapy.http import HtmlResponse, Request

def fake_response(file_name, url=None):
    '''
    Create a Scrapy fake HTTP response from a HTML file
    Args: 
        file_name: The relative filename from the responses directory,
                      but absolute paths are also accepted.
        url: The URL of the response.
    Returns: 
        A scrapy HTTP response which can be used for unittesting.
    '''
    # Use default URL 
    if not url:
        url = 'https://www.coursera.org/courses'

    request = Request(url=url)

    if not file_name[0] == '/':
        responses_dir = os.path.dirname(os.path.realpath(__file__))
        file_path = os.path.join(responses_dir, file_name)
    else:
        file_path = file_name

    # Read HTML file and create fake response
    file_content = open(file_path, 'r').read()
    response = HtmlResponse(url=url,
        request=request,
        body=file_content, encoding = 'utf-8')
    return response

if __name__ == "__main__":
    response = fake_response('courses.html')
    print(response)