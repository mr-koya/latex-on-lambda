import unittest
from src.app import handler

class TestLambdaHandler(unittest.TestCase):
    def test_lambda_handler(self):
        # Simulate an event and context
        event = {'latex': "\\section{Hello}This is a test of the LaTeX Lambda function."}
        context = {}

        # Call the Lambda handler
        result = handler(event, context)

        # Check the type of response and status code
        self.assertIsInstance(result, dict, "The handler must return a dictionary.")
        self.assertIn('statusCode', result, "Response dictionary must include a statusCode.")
        self.assertEqual(result['statusCode'], 200, "Status code should be 200 for successful processing.")

        # You might want to check other parts of the response as needed
        # For example:
        # self.assertIn('body', result, "Response should include a body.")
        # Additional checks for the body content can also be implemented.

if __name__ == '__main__':
    unittest.main()

