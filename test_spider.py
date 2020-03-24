import unittest
from course_getter.spiders import courses
from responses import fake_response_from_file

class SpiderTest(unittest.TestCase):

    def setUp(self):
        '''
        set up spider
        '''
        self.spider = courses.CoursesSpider()

    def _test_item_results(self, results, expected_length):
        count = 0
        permalinks = set()
        for item in results:
            self.assertIsNotNone(item['content'])
            self.assertIsNotNone(item['title'])
        self.assertEqual(count, expected_length)

    def test_parse(self):
        results = self.spider.parse(fake_response_from_file('osdir/sample.html'))
        self._test_item_results(results, 10)

if __name__ == "__main__":
    unittest.main()