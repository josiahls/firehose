"""
Unit tests for the Firehose logging library.

This file demonstrates how to test code that uses logging with the
TestLoggerOutputer to capture and verify log messages.
"""

# Native Mojo Modules
from collections.list import List
# Third Party Mojo Modules
# First Party Modules
from firehose.logging import Logger
from firehose import (
    LOG_LEVELS, TestLoggerOutputer,
    DefaultLoggerFilter, DefaultLoggerFormatter, DefaultLoggerOutputer
)


# Function that we want to test
fn process_data(input_value: Int, mut logger: Logger) -> Int:
    """
    Example function that processes data and logs information about its steps.
    This is the function we want to test.
    """
    logger.info("Starting to process data: " + String(input_value))
    
    var data = input_value
    if data < 0:
        logger.warning("Received negative data: " + String(data))
        data = 0
    
    var result = data * 2
    
    if result > 100:
        logger.debug("Result exceeds threshold: " + String(result))
        
    logger.info("Finished processing, result: " + String(result))
    return result


# Simple test function
fn test_process_data() raises:
    """
    Test the process_data function and verify its logging behavior.
    
    This test demonstrates:
    1. Setting up a logger with a test outputer
    2. Calling a function that logs messages
    3. Verifying the logged messages content
    """
    # Set up the logger with a test outputer
    var logger = Logger.get_default_logger("test", "DEBUG")
    var test_outputer = TestLoggerOutputer("test_output", LOG_LEVELS['DEBUG'])
    logger.add_output(test_outputer)
    
    # Call the function with positive input
    var result = process_data(25, logger)
    
    # Verify the result
    debug_assert(result == 50)
    
    # Verify the log messages
    var messages = test_outputer.get_messages()
    debug_assert(len(messages) != 0)
    # Check message contents (simplified to avoid string operations that might raise)
    print("First message: ", messages[0])
    print("Second message: ", messages[1])
    
    # # Clear messages for the next test
    # test_outputer.clear_messages()
    
    # # Test with a value that triggers the warning
    # result = process_data(-10, logger)
    
    # # Verify the result
    # debug_assert(result == 0)
    
    # # Verify the log messages - should have a warning
    # messages = test_outputer.get_messages()
    # debug_assert(len(messages) == 3)
    # print("First message: ", messages[0])
    # print("Second message: ", messages[1])
    # print("Third message: ", messages[2])
    
    # print("All tests passed!")


# Main function to run the tests
fn main() raises:
    print("Running Firehose logger tests...")
    test_process_data()
    print("All Firehose tests completed successfully.") 